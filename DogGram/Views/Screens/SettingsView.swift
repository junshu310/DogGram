//
//  SettingsView.swift
//  DogGram
//
//  Created by 佐藤駿樹 on 2021/10/20.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @State var showSignOutError: Bool = false
    
    @Binding var userDisplayName: String
    @Binding var userBio: String
    @Binding var userProfilePicture: UIImage
    
    var body: some View {
        NavigationView {
            
            ScrollView(.vertical, showsIndicators: false) {
                
                //MARK: SECTION 1: DOGGRAM
                GroupBox {
                    HStack(alignment: .center, spacing: 10) {
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80, alignment: .center)
                            .cornerRadius(12)
                        
                        Text("DogGram is the #1 app for posting pictures of your dog and sharing them across the world. We are a dog-loving community and we're happy to have you!")
                            .font(.footnote)
                    }
                } label: {
                    SettingsLabelView(labelText: "DogGram", labelImage: "dot.radiowaves.left.and.right")
                }
                .padding()

                
                //MARK: SECTION 2: PROFILE
                GroupBox {
                    NavigationLink {
                        SettingsEditTextView(submissionText: userDisplayName, title: "Display Name", description: "You can edit your display name here. This will be seen by other users on your profile and on your posts!", placeholder: "Your display name here...", settingsEditTextOption: .displayName, profileText: $userDisplayName)
                    } label: {
                        SettingsRowView(leftImage: "pencil", text: "Display Name", color: Color.MyTheme.purpleColor)
                    }
                    
                    NavigationLink {
                        SettingsEditTextView(submissionText: userBio, title: "Profile Bio", description: "Your bio is a great place to let other users know a little about you. It will be shown on your profile only.", placeholder: "Your bio here...", settingsEditTextOption: .bio, profileText: $userBio)
                    } label: {
                        SettingsRowView(leftImage: "text.quote", text: "Bio", color: Color.MyTheme.purpleColor)
                    }

                    NavigationLink {
                        SettingsEditImageView(title: "Profile Picture", description: "Your profile picture will be shown on your profile and on your posts. Most users make it an image of themseleves or of their dog!", selectedImage: userProfilePicture, profileImage: $userProfilePicture)
                    } label: {
                        SettingsRowView(leftImage: "photo", text: "Profile Picture", color: Color.MyTheme.purpleColor)
                    }

                    Button {
                        signOut()
                    } label: {
                        SettingsRowView(leftImage: "figure.walk", text: "Sign out", color: Color.MyTheme.purpleColor)
                    }
                    .alert(isPresented: $showSignOutError) {
                        return Alert(title: Text("Error signing out 🥵"))
                    }
                    
                } label: {
                    SettingsLabelView(labelText: "Profile", labelImage: "person.fill")
                }
                .padding()

                
                //MARK: SECTION 3: APPLICATION
                GroupBox {
                    Button {
                        openCustomURL(urlString: "https://www.google.com")
                    } label: {
                        SettingsRowView(leftImage: "folder.fill", text: "Privacy Policy", color: Color.MyTheme.yellowColor)
                    }
                    
                    Button {
                        openCustomURL(urlString: "https://www.yahoo.com")
                    } label: {
                        SettingsRowView(leftImage: "folder.fill", text: "Terms & Conditions", color: Color.MyTheme.yellowColor)
                    }
                    
                    Button {
                        openCustomURL(urlString: "https://www.bing.com")
                    } label: {
                        SettingsRowView(leftImage: "globe", text: "DogGram's Website", color: Color.MyTheme.yellowColor)

                    }

                } label: {
                    SettingsLabelView(labelText: "Application", labelImage: "apps.iphone")
                }
                .padding()

                
                //MARK: SECTION 4: SIGN OFF
                GroupBox {
                    Text("DogGram was mad with love. \n All Rights Reserved \n Cool Apps Inc. \n Copyright 2021 ♥️")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
                .padding()
                .padding(.bottom, 40)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(leading:
                                    Button(action: {
                                        presentationMode.wrappedValue.dismiss()
                                    }, label: {
                                        Image(systemName: "xmark")
                                            .font(.title)
                                    })
                                    .accentColor(.primary)
            )
        }
        .accentColor(colorScheme == .light ? Color.MyTheme.purpleColor : Color.MyTheme.yellowColor)
    }
    
    //MARK: FUNCTION
    //URLを開く
    func openCustomURL(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    func signOut() {
        AuthService.instance.logOutUser { success in
            if success {
                print("Successfully logged out")
                
                //画面を閉じる
                self.presentationMode.wrappedValue.dismiss()
                
//                //UserDefaultsをアップデート
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                    //UserDefaultsから値を削除（項目漏れがないようにforEach文を回して削除）
//                    //全ての項目を取る
//                    let defaultsDictionary = UserDefaults.standard.dictionaryRepresentation()
//                    //key値を回す
//                    defaultsDictionary.keys.forEach { key in
//                        UserDefaults.standard.removeObject(forKey: key)
//                    }
//                }
            } else {
                print("Error logging out")
                self.showSignOutError.toggle()
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    
    @State static var testString: String = ""
    @State static var image: UIImage = UIImage(named: "dog1")!
    
    static var previews: some View {
        SettingsView(userDisplayName: $testString, userBio: $testString, userProfilePicture: $image)
            .preferredColorScheme(.dark)
    }
}
