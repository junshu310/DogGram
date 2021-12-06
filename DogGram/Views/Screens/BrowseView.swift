//
//  BrowseView.swift
//  DogGram
//
//  Created by 佐藤駿樹 on 2021/10/18.
//

import SwiftUI

struct BrowseView: View {
    
    var posts: PostArrayObject
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            CarouselView()
            ImageGridView(posts: posts)
        }
        .navigationTitle("Browse")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct BrowseView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            BrowseView(posts: PostArrayObject(shuffled: true))
        }
    }
}
