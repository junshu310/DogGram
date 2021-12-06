//
//  ImageGridView.swift
//  DogGram
//
//  Created by 佐藤駿樹 on 2021/10/19.
//

import SwiftUI

struct ImageGridView: View {
    
    //このviewがよばれる度に、PostArrayObjectをpostsとして観察する
    @ObservedObject var posts: PostArrayObject
    
    var body: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
            ],
            alignment: .center,
            spacing: nil,
            pinnedViews: []) {
                //投稿データをfor文にかける
                ForEach(posts.dataArray, id: \.self) { post in
                    NavigationLink {
                        //画面遷移先(FeedViewのある特定のPost)
                        FeedView(posts: PostArrayObject(post: post), title: "Post")
                    } label: {
                        //一覧表示
                        PostView(post: post, showHeaderAndFooter: false, addheartAnimationToView: false)
                    }
                }
//                .padding(.bottom)
            }
    }
}

struct ImageGridView_Previews: PreviewProvider {
    static var previews: some View {
        ImageGridView(posts: PostArrayObject(shuffled: true))
            .previewLayout(.sizeThatFits)
    }
}
