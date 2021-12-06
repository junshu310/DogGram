//
//  PostArrayObject.swift
//  DogGram
//
//  Created by 佐藤駿樹 on 2021/10/18.
//

import Foundation

class PostArrayObject: ObservableObject {
    
    @Published var dataArray = [PostModel]()
    @Published var postCountString = "0"
    @Published var likeCountString = "0"
    
    /// USED FOR SINGLE SELECTION
    init(post: PostModel) {
        self.dataArray.append(post)
    }
    
    
    /// USED FOR GETTING POSTS FOR PROFILE
    init(userID: String) {
        
        print("GET POSTS FOR USER ID \(userID)")
        DataService.instance.downloadPostForUser(userID: userID) { posts in
            //投稿を日付順に並び替え
            let sortedPosts = posts.sorted { post1, post2 in
                //比較してdateが大きい(新しい)ものを返す
                return post1.dateCreate > post2.dateCreate
            }
            self.dataArray.append(contentsOf: sortedPosts)
            self.updataCount()
        }
    }
    
    /// USED FOR FEED
    init(shuffled: Bool) {
        
        print("GET POSTS FOR FEED. SHUFFLED: \(shuffled)")
        DataService.instance.downloadPostsForFeed { posts in
            if shuffled {
                let shuffledPosts = posts.shuffled()
                self.dataArray.append(contentsOf: shuffledPosts)
            } else {
                self.dataArray.append(contentsOf: posts)
            }
        }
    }
    
    func updataCount() {
        
        //postCount
        self.postCountString = "\(self.dataArray.count)"
        
        //likeCountを取り出した配列を作る(map = 配列を新しい型に変換(マッピング))
        let likeCountArray = dataArray.map { existingPost -> Int in
            return existingPost.likeCount
        }
        //Int型の配列の中身を合計する(最初は0で、全てプラスする)
        let sumOfLikeCountArray = likeCountArray.reduce(0, +)
        self.likeCountString = "\(sumOfLikeCountArray)"
    }
}
