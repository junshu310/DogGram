//
//  DataService.swift
//  DogGram
//
//  Created by 佐藤駿樹 on 2021/10/26.
//


//データベースからデータをアップロード、ダウンロードする
import Foundation
import SwiftUI
import FirebaseFirestore

class DataService {
    
    //MARK: PRORERTIES
    
    static let instance = DataService()
    
    private var REF_POSTS = DB_BASE.collection("posts")
    private var REF_REPOTRS = DB_BASE.collection("reports")
    
    @AppStorage(CurrentUserDafaults.userID) var currentUserID: String?
    
    //MARK: CREATE FUNCTIONS
    
    func uploadPost(image: UIImage, caption: String?, displayName: String, userID: String, handler: @escaping(_ success: Bool) -> ()) {
        
        //post documentを新規作成
        let document = REF_POSTS.document()
        let postID = document.documentID
        
        //画像をStorageにアップロード
        ImageManager.instance.uploadPostImage(postID: postID, image: image) { success in
            
            if success {
                //image data の Storageへのアップロード成功
                //データベースへpost dataをアップロード
                
                let postData: [String:Any] = [
                    DatabasePostField.postID: postID,
                    DatabasePostField.userID: userID,
                    DatabasePostField.displayName : displayName,
                    DatabasePostField.caption: caption,
                    DatabasePostField.dateCreated: FieldValue.serverTimestamp()
                ]
                
                document.setData(postData) { error in
                    if let error = error {
                        print("Error uploading data to post document. \(error)")
                        handler(false)
                        return
                    } else {
                        //アプリに返す
                        handler(true)
                        return
                    }
                }
                
            } else {
                print("Error uploading post image to firebase")
                handler(false)
                return
            }
        }
    }
    
    //レポートを匿名にするためuserIDは不要
    func uploadReport(reason: String, postID: String, handler: @escaping(_ success: Bool) -> ()) {
        
        let data: [String:Any] = [
            DatabaseReportsField.content : reason,
            DatabaseReportsField.postID : postID,
            DatabaseReportsField.dateCreated : FieldValue.serverTimestamp()
        ]
        
        //アプリと無関係なので、reportIDは必要ない
        REF_REPOTRS.addDocument(data: data) { error in
            if let error = error {
                print("Error uploading report. \(error)")
                handler(false)
                return
            } else {
                handler(true)
                return
            }
        }
    }
    
    func uploadComment(postID: String, content: String, displayName: String, userID: String, handler: @escaping(_ success: Bool, _ commentID: String?) -> ()) {
        
        //ドキュメントを作成
        let document = REF_POSTS.document(postID).collection(DatabasePostField.comments).document()
        let commentID = document.documentID
        
        let data: [String:Any] = [
            DatabaseCommentsField.commentID : commentID,
            DatabaseCommentsField.userID : userID,
            DatabaseCommentsField.content : content,
            DatabaseCommentsField.displayName : displayName,
            DatabaseCommentsField.dateCreated : FieldValue.serverTimestamp()
        ]
        
        document.setData(data) { error in
            if let error = error {
                print("Error uploading comment. \(error)")
                handler(false, nil)
                return
            } else {
                handler(true, commentID)
                return
            }
        }
    }
    
    
    //MARK: GET FUNCTIONS
    func downloadPostForUser(userID: String, handler: @escaping (_ posts: [PostModel]) -> ()) {
        
        //ログインしているuserIDとpostのuserIDが等しいもの
        REF_POSTS.whereField(DatabasePostField.userID, isEqualTo: userID).getDocuments { querySnapshot, error in
            //データベースからデータを取得完了した状態
            handler(self.getPostsFromSnapshot(querySnapshot: querySnapshot))
        }
    }
    
    func downloadPostsForFeed(handler: @escaping (_ posts: [PostModel]) -> ()) {
        //日付順に並び替えてgetする(descending = 降順)
        REF_POSTS.order(by: DatabasePostField.dateCreated, descending: true).limit(to: 50).getDocuments { querySnapshot, error in
            //データベースからデータを取得完了した状態
            handler(self.getPostsFromSnapshot(querySnapshot: querySnapshot))
        }
    }
    
    //データを取得完了後呼ばれるので、escapingの必要なし
    private func getPostsFromSnapshot(querySnapshot: QuerySnapshot?) -> [PostModel] {
        var postArray = [PostModel]()
        if let snapshot = querySnapshot, snapshot.count > 0 {
            
            //投稿を一つずつ取り出す
            for document in snapshot.documents {
                //空判定
                if let userID = document.get(DatabasePostField.userID) as? String,
                   let displayName = document.get(DatabasePostField.displayName) as? String,
                   let timestamp = document.get(DatabasePostField.dateCreated) as? Timestamp {
                    
                    let postID = document.documentID
                    //nilの場合もある
                    let caption = document.get(DatabasePostField.caption) as? String
                    //timestampをdateに変換
                    let date = timestamp.dateValue()
                    
                    let likeCount = document.get(DatabasePostField.likeCount) as? Int ?? 0
                    var likedByUser: Bool = false
                    if let userIDArray = document.get(DatabasePostField.likedBy) as? [String], let userID = currentUserID {
                        //bool値で返される
                        likedByUser = userIDArray.contains(userID)
                    }
                    
                    let newPost = PostModel(postID: postID, userID: userID, username: displayName, caption: caption, dateCreate: date, likeCount: likeCount, likedByUser: likedByUser)
                    postArray.append(newPost)
                }
            }
            return postArray
            
        } else {
            print("No documents in snapshot found for this user")
            return postArray
        }
    }
    
    func downloadComment(postID: String, handler: @escaping (_ comments: [CommentModel]) -> ()) {
        
        //postIDからcommentsを取得、 descending: false(降順)
        REF_POSTS.document(postID).collection(DatabasePostField.comments).order(by: DatabaseCommentsField.dateCreated, descending: false).getDocuments { querySnapshot, error in
            handler(self.getCommentsFromSnapshot(querySnapshot: querySnapshot))
        }
    }
    
    private func getCommentsFromSnapshot(querySnapshot: QuerySnapshot?) -> [CommentModel] {
        var commentArray = [CommentModel]()
        if let snapshot = querySnapshot, snapshot.documents.count > 0 {
            
            for document in snapshot.documents {
                
                if let userID = document.get(DatabaseCommentsField.userID) as? String,
                   let displayName = document.get(DatabaseCommentsField.displayName) as? String,
                   let content = document.get(DatabaseCommentsField.content) as? String,
                   let timestamp = document.get(DatabaseCommentsField.dateCreated) as? Timestamp {

                    let date = timestamp.dateValue()
                    let commentID = document.documentID
                    let newComment = CommentModel(commentID: commentID, userID: userID, username: displayName, content: content, date: date)
                    commentArray.append(newComment)
                }
            }
            return commentArray
        } else {
            print("No comments in document for this post")
            return commentArray
        }
    }
    
    
    //MARK: UPDATE FUNCTION
    func likePost(postID: String, currentUserID: String) {
        //Update the post count
        //Updata the array of users who liked the post
        
        let increment: Int64 = 1
        let data: [String:Any] = [
            DatabasePostField.likeCount : FieldValue.increment(increment),
            DatabasePostField.likedBy : FieldValue.arrayUnion([currentUserID])
        ]
        
        REF_POSTS.document(postID).updateData(data)
    }
    
    func unlikePost(postID: String, currentUserID: String) {
        //Update the post count
        //Updata the array of users who liked the post
        
        let increment: Int64 = -1
        let data: [String:Any] = [
            DatabasePostField.likeCount : FieldValue.increment(increment),
            DatabasePostField.likedBy : FieldValue.arrayRemove([currentUserID])
        ]
        
        REF_POSTS.document(postID).updateData(data)
    }
    
    func updateDisplayNameOnPosts(userID: String, displayName: String) {
        
        //userのpostをダウンロード
        downloadPostForUser(userID: userID) { posts in
            //一つずつ更新
            for post in posts {
                self.updatePostDisplayName(postID: post.postID, displayName: displayName)
            }
        }
    }
    
    private func updatePostDisplayName(postID: String, displayName: String) {
        
        //postIDを元にデータを更新
        let data: [String: Any] = [
            DatabasePostField.displayName : displayName
        ]
        REF_POSTS.document(postID).updateData(data)
    }
}
