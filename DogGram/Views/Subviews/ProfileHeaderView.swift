//
//  ProfileHeaderView.swift
//  DogGram
//
//  Created by 佐藤駿樹 on 2021/10/19.
//

import SwiftUI

struct ProfileHeaderView: View {
    
    @Binding var profileDisplayName: String
    @Binding var profileImage: UIImage
    @ObservedObject var postArray: PostArrayObject
    @Binding var profileBio: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            
            //MARK: PROFILE IMAGE
            Image(uiImage: profileImage)
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 120, alignment: .center)
                .cornerRadius(60)
            
            //MARK: USER NAME
            Text(profileDisplayName)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            //MARK: BIO
            if profileBio != "" { //bioが空の時は無視
                Text(profileBio)
                    .font(.body)
                    .fontWeight(.regular)
                    .multilineTextAlignment(.center)
            }
            
            HStack(alignment: .center, spacing: 20) {
                
                //MARK: POSTS
                VStack {
                    Text(postArray.postCountString)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    //区切り線
                    Capsule()
                        .fill(Color.gray)
                        .frame(width: 20, height: 2, alignment: .center)
                    
                    Text("Posts")
                        .font(.callout)
                        .fontWeight(.medium)
                }
                
                //MARK: LIKES
                VStack {
                    Text(postArray.likeCountString)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    //区切り線
                    Capsule()
                        .fill(Color.gray)
                        .frame(width: 20, height: 2, alignment: .center)
                    
                    Text("Likes")
                        .font(.callout)
                        .fontWeight(.medium)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

struct ProfileHeaderView_Previews: PreviewProvider {
    
    @State static var name: String = "Shota"
    @State static var image: UIImage = UIImage(named: "dog1")!
    
    static var previews: some View {
        ProfileHeaderView(profileDisplayName: $name, profileImage: $image, postArray: PostArrayObject(shuffled: false), profileBio: $name)
            .previewLayout(.sizeThatFits)
    }
}
