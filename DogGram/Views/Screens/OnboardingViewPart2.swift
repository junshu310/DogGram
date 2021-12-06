//
//  OnboardingViewPart2.swift
//  DogGram
//
//  Created by 佐藤駿樹 on 2021/10/20.
//

import SwiftUI

struct OnboardingViewPart2: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    //ユーザー情報を受け取る
    @Binding var displayName: String
    @Binding var email: String
    @Binding var providerID: String
    @Binding var provider: String
    
    @State var showImagePicker: Bool = false
    
    // For image picker
    @State var imageSelected: UIImage = UIImage(named: "logo")!
    @State var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    @State var showError: Bool = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            
            Text("What's your name?")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color.MyTheme.yellowColor)
            
            TextField("Add your name here...", text: $displayName)
                .padding()
                .frame(height: 60)
                .frame(maxWidth: .infinity)
                .background(Color.MyTheme.beigeColor)
                .foregroundColor(.black)
                .cornerRadius(12)
                .font(.headline)
                .autocapitalization(.sentences)
                .padding(.horizontal)
            
            Button {
                //画像と登録する(ImagePickerを表示)
                showImagePicker.toggle()
            } label: {
                Text("Finish: Add profile picture")
                    .font(.headline)
                    .fontWeight(.bold)
                    .frame(height: 60)
                    .frame(maxWidth: .infinity)
                    .background(Color.MyTheme.yellowColor)
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
            .accentColor(Color.MyTheme.purpleColor)
            //textFieldが空の時、非表示にする
            .opacity(displayName != "" ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 1.0))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.MyTheme.purpleColor)
        .ignoresSafeArea(.all)
        .sheet(isPresented: $showImagePicker, onDismiss: createProfile, content: {
            ImagePicker(imageSelected: $imageSelected, sourceType: $sourceType)
        })
        .alert(isPresented: $showError) {
            return Alert(title: Text("Error creating profile 😤"))
        }
    }
    
    //MARK: FUNCTION
    
    func createProfile() {
        print("CREATE PROFILE NOW")
        
        AuthService.instance.createNewUserInDatabase(name: displayName, email: email, providerID: providerID, provider: provider, profileImage: imageSelected) { returnedUserID in
            //SUCCES
            if let userID = returnedUserID {
                //SUCCESS
                print("Successfully created new user in database.")
                
                AuthService.instance.logInUserToApp(userID: userID) { success in
                    if success {
                        print("User logged in")
                        //画面を閉じる(多くのシートを開いているので、少し遅延させる)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    } else {
                        print("Error logging in")
                        self.showError.toggle()
                    }
                }
                
            } else {
                //ERROR
                print("Error creating user in Database")
                self.showError.toggle()
            }
        }
    }
}

struct OnboardingViewPart2_Previews: PreviewProvider {
    
    @State static var testString: String = "Test"
    
    static var previews: some View {
        OnboardingViewPart2(displayName: $testString, email: $testString, providerID: $testString, provider: $testString)
    }
}
