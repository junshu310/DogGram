//
//  MessageView.swift
//  DogGram
//
//  Created by 佐藤駿樹 on 2021/10/18.
//

import SwiftUI

struct MessageView: View {
    
    @State var comment: CommentModel
    @State var profilePicture: UIImage = UIImage(named: "logo.loading")!
    
    var body: some View {
        HStack {
            //MARK: PROFILE IMAGE
            NavigationLink {
                LazyView {
                    ProfileView(isMyProfile: false, profileDisplayName: comment.username, profileUserID: comment.userID, posts: PostArrayObject(userID: comment.userID))
                }
            } label: {
                Image(uiImage: profilePicture)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40, alignment: .center)
                    .cornerRadius(20)
            }
            
            //VStack (.leading) = 左詰にする(viewのスタート地点をエッジにする)
            VStack(alignment: .leading, spacing: 4) {
                
                //MARK: USER NAME
                Text(comment.username)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                //MARK: CONTENT
                //背景色・丸角をつけ、吹き出し風にする
                Text(comment.content)
                    .padding(.all, 10)
                    .foregroundColor(.primary)
                    .background(Color.gray)
                    .cornerRadius(10)
            }
            
            Spacer(minLength: 0)
        }
        .onAppear {
            getProfileImage()
        }
    }
    
    // MARK: FUNCTION
    func getProfileImage() {
        ImageManager.instance.downloadProfileImage(userID: comment.userID) { image in
            if let image = image {
                self.profilePicture = image
            }
        }
    }
}

struct MessageView_Previews: PreviewProvider {
    
    static var comment: CommentModel = CommentModel(commentID: "", userID: "", username: "Shota", content: "This is a really cool photo.", date: Date())
    
    static var previews: some View {
        MessageView(comment: comment)
            //画面サイズの変更
            .previewLayout(.sizeThatFits)
    }
}
