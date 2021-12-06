//
//  CommentsView.swift
//  DogGram
//
//  Created by 佐藤駿樹 on 2021/10/18.
//

import SwiftUI

struct CommentsView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @State var submissionText: String = ""
    @State var commentArray = [CommentModel]()
    
    var post: PostModel
    
    @State var profilePicture: UIImage = UIImage(named: "logo.loading")!
    
    @AppStorage(CurrentUserDafaults.userID) var currentUserID: String?
    @AppStorage(CurrentUserDafaults.displayName) var currentUserDisplayName: String?
    
    var body: some View {
        VStack {
            
            //コメント一覧用　scrollView
            ScrollView {
                //commentArrayから一つずつデータを取り出す
                ForEach(commentArray, id: \.self) { comment in
                    //MessageViewに反映
                    MessageView(comment: comment)
                }
            }
            
            //コメント送信用　textField
            HStack {
                Image(uiImage: profilePicture)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40, alignment: .center)
                    .cornerRadius(20)
                
                //TextField(title: プレイスホルダー(String型), text: ?分からない?)
                TextField("Add a comment here...", text: $submissionText)
                
                //送信ボタン
                Button {
                    if textIsAppropriate() {
                        addComment()
                    }
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.title2)
                }
                .accentColor(colorScheme == .light ? Color.MyTheme.purpleColor : Color.MyTheme.yellowColor)
            }
            .padding(.all, 6)
        }
        .padding(.horizontal)
        .navigationTitle("Comments")
        .navigationBarTitleDisplayMode(.inline)
        //初めて画面が描画されるタイミングで呼ばれる
        .onAppear {
            getComments()
            getProfilePicture()
        }
    }
    
    //MARK: FUNCTION
    
    func getProfilePicture() {
        
        guard let userID = currentUserID else { return }
        
        ImageManager.instance.downloadProfileImage(userID: userID) { image in
            if let image = image {
                self.profilePicture = image
            }
        }
    }
    
    //コメントを取得する関数
    func getComments() {
        
        //ダウンロードの重複を防ぐため、配列を空判定する
        guard self.commentArray.isEmpty else { return }
        print("GET COMMENTS FORM DATABASE")
        //先頭にpostのcaptionを入れる
        if let caption = post.caption, caption.count > 1 {
            let captionComment = CommentModel(commentID: "", userID: post.userID, username: post.username, content: caption, date: post.dateCreate)
            self.commentArray.append(captionComment)
        }
        
        DataService.instance.downloadComment(postID: post.postID) { comments in
            self.commentArray.append(contentsOf: comments)
        }
    }
    
    func textIsAppropriate() -> Bool {
        //不適切なコメントでないかをチェックする
        
        //不適切な言葉がないか調べる（一例）
        let badWordArray: [String] = ["shit", "ass"]
        let words = submissionText.components(separatedBy: " ")
        for word in words {
            if badWordArray.contains(word) {
                return false
            }
        }
        
        //コメントが3文字以上か調べる
        if submissionText.count < 3 {
            return false
        }
        
        return true
    }
    
    func addComment() {
        
        guard let userID = currentUserID, let displayName = currentUserDisplayName else { return }
        
        DataService.instance.uploadComment(postID: post.postID, content: submissionText, displayName: displayName, userID: userID) { success, commentID in
            
            if success, let commentID = commentID {
                let newComments = CommentModel(commentID: commentID, userID: userID, username: displayName, content: submissionText, date: Date())
                self.commentArray.append(newComments)
                self.submissionText = ""
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
    }
}

struct CommentsView_Previews: PreviewProvider {
    
    static let post = PostModel(postID: "asdf", userID: "asdf", username: "asdf", dateCreate: Date(), likeCount: 0, likedByUser: false)
    
    static var previews: some View {
        NavigationView {
            CommentsView(post: post)
                .preferredColorScheme(.dark)
        }
    }
}
