//
//  FeedView.swift
//  DogGram
//
//  Created by 佐藤駿樹 on 2021/10/16.
//

import SwiftUI

struct FeedView: View {
    
    @ObservedObject var posts: PostArrayObject
    var title: String
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            //表示部分のみ読み込む
            LazyVStack {
                ForEach(posts.dataArray, id: \.self) { post in
                    PostView(post: post, showHeaderAndFooter: true, addheartAnimationToView: true)
                }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FeedView(posts: PostArrayObject(shuffled: false), title: "Feed")
        }
    }
}
