//
//  ContentView.swift
//  DogGram
//
//  Created by 佐藤駿樹 on 2021/10/16.
//

import SwiftUI

struct ContentView: View {
    
    //ダークモードの管理
    @Environment(\.colorScheme) var colorScheme
    
    //@AppStorage: userDefaultsを呼び出す用
    @AppStorage(CurrentUserDafaults.userID) var currentUserID: String?
    @AppStorage(CurrentUserDafaults.displayName) var currentDisplayName: String?
    
    let feedPosts = PostArrayObject(shuffled: false)
    let browsePosts = PostArrayObject(shuffled: true)
    
    var body: some View {
        // TabViewの生成
        TabView {
            // １つ目のタブ
            NavigationView {
                //navigationViewに投稿用の画面を表示する
                FeedView(posts: feedPosts, title: "Feed")
            }
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Feed")
                }
            
            // ２つ目のタブ
            NavigationView {
                BrowseView(posts: browsePosts)
            }
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Browse")
                }
            
            // ３つ目のタブ
            UploadView()
                .tabItem {
                    Image(systemName: "square.and.arrow.up.fill")
                    Text("Upload")
                }
            
            // ４つ目のタブ
            ZStack { //tabに影響を与えないため
                if let userID = currentUserID, let displayName = currentDisplayName {
                    NavigationView {
                        ProfileView(isMyProfile: true, profileDisplayName: displayName, profileUserID: userID, posts: PostArrayObject(userID: userID))
                    }
                } else {
                    SignUpView()
                }
            }
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
        //ダークモードに対応させる
        .accentColor(colorScheme == .light ? Color.MyTheme.purpleColor : Color.MyTheme.yellowColor)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
