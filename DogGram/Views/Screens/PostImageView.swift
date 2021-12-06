//
//  PostImageView.swift
//  DogGram
//
//  Created by 佐藤駿樹 on 2021/10/19.
//

import SwiftUI

struct PostImageView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage(CurrentUserDafaults.userID) var currentUserID: String?
    @AppStorage(CurrentUserDafaults.displayName) var currentUserDisplayName: String?
    
    @State var captionText: String = ""
    @Binding var imageSelected: UIImage
    
    @State var showAlert: Bool = false
    @State var postUploadedSuccessfully: Bool = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack {
                Button {
                    //閉じる
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.title)
                        .padding()
                }
                .accentColor(.primary)
                
                Spacer()
            }

            ScrollView(.vertical, showsIndicators: false) {
                
                Image(uiImage: imageSelected)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200, alignment: .center)
                    .cornerRadius(12)
                    //写真が枠を超えた場合に備えて
                    .clipped()
                
                TextField("Add your caption here..", text: $captionText)
                    .padding()
                    .frame(height: 60)
                    .frame(maxWidth: .infinity)
                    .background(colorScheme == .light ? Color.MyTheme.beigeColor : Color.MyTheme.purpleColor)
                    .cornerRadius(12)
                    .font(.headline)
                    .padding(.horizontal)
                    //
                    .autocapitalization(.sentences)
                
                Button {
                    //投稿
                    postPicture()
                } label: {
                    Text("Post Picture!".uppercased())
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding()
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(colorScheme == .light ? Color.MyTheme.purpleColor : Color.MyTheme.yellowColor)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .accentColor(colorScheme == .light ? Color.MyTheme.yellowColor : Color.MyTheme.purpleColor)
            }
            .alert(isPresented: $showAlert) { () -> Alert in
                getAlert()
            }
        }
    }
    
    //MARK: FUNCTION
    
    func postPicture() {
        print("POST PICTURE TO DATABASE HERE")
        
        //userID, displayNameがアプリ内に保存されているか(ログイン状態かどうか)
        guard let userID = currentUserID, let displayName = currentUserDisplayName else {
            print("Error getting userID or displayname while posting image")
            return
        }
        
        DataService.instance.uploadPost(image: imageSelected, caption: captionText, displayName: displayName, userID: userID) { success in
            self.postUploadedSuccessfully = success
            self.showAlert.toggle()
        }
    }
    
    func getAlert() -> Alert {
        
        //投稿成功
        if postUploadedSuccessfully {
            return Alert(title: Text("Successfully uploaded post! 🥳"), message: nil, dismissButton: .default(Text("OK"), action: {
                self.presentationMode.wrappedValue.dismiss()
            }))
        } else {
            return Alert(title: Text("Error uploading post 😭"))
        }
    }
}

struct PostImageView_Previews: PreviewProvider {
    
    @State static var image = UIImage(named: "dog1")!
    
    static var previews: some View {
        PostImageView(imageSelected: $image)
            .preferredColorScheme(.dark)
    }
}
