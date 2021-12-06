//
//  ProfileView.swift
//  DogGram
//
//  Created by 佐藤駿樹 on 2021/10/19.
//

import SwiftUI

struct ProfileView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var isMyProfile: Bool
    @State var profileDisplayName: String
    var profileUserID: String
    @State var profileBio: String = ""
    
    @State var profileImage: UIImage = UIImage(named: "logo.loading")!
    
    var posts: PostArrayObject
    
    @State var showSettings: Bool = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ProfileHeaderView(profileDisplayName: $profileDisplayName, profileImage: $profileImage, postArray: posts, profileBio: $profileBio)
            
            Divider()
            
            ImageGridView(posts: posts)
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing:
                                Button(action: {
                                    showSettings.toggle()
                                }, label: {
                                    Image(systemName: "line.horizontal.3")
                                })
                                .accentColor(colorScheme == .light ? Color.MyTheme.purpleColor : Color.MyTheme.yellowColor)
                                // (条件 ? trueの時 : falseの時)
                                .opacity(isMyProfile ? 1.0 : 0.0)
        )
        .onAppear(perform: {
            getProfileImage()
            getAdditionalProfileInfo()
        })
        .sheet(isPresented: $showSettings) {
            SettingsView(userDisplayName: $profileDisplayName, userBio: $profileBio, userProfilePicture: $profileImage)
                .preferredColorScheme(colorScheme)
        }
    }
    
    //MARK: FUNCTION
    func getProfileImage() {
        ImageManager.instance.downloadProfileImage(userID: profileUserID) { image in
            if let image = image {
                self.profileImage = image
            }
        }
    }
    
    func getAdditionalProfileInfo() {
        AuthService.instance.getUserInfo(forUserID: profileUserID) { name, bio in
            if let name = name {
                self.profileDisplayName = name
            }
            if let bio = bio {
                self.profileBio = bio
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView(isMyProfile: true, profileDisplayName: "Shota", profileUserID: "", posts: PostArrayObject(userID: ""))
        }
    }
}
