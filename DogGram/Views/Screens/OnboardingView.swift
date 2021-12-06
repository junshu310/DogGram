//
//  OnboardingView.swift
//  DogGram
//
//  Created by 佐藤駿樹 on 2021/10/20.
//

import SwiftUI
import FirebaseAuth

struct OnboardingView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State var showOnboardingPart2: Bool = false
    @State var showError: Bool = false
    
    //ユーザー情報を渡す用の変数
    @State var displayName: String = ""
    @State var email: String = ""
    @State var providerID: String = ""
    @State var provider: String = ""
    
    var body: some View {
        VStack(spacing: 10) {
            
            Image("logo.transparent")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100, alignment: .center)
                .shadow(radius: 12)
            
            Text("Welcome to DogGram!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color.MyTheme.purpleColor)
            
            Text("DogGram is the #1 app for posting pictures of your dog and sharing them across the world. We are a dog-loving community and we're happy to have you!")
                .font(.headline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(Color.MyTheme.purpleColor)
                .padding()
            
            //MARK: SIGN IN WITH APPLE
            Button {
//                showOnboardingPart2.toggle()
                showError.toggle()
            } label: {
                SignInWithAppleButtonCustom()
                    .frame(height: 60)
                    .frame(maxWidth: .infinity)
            }
            
            //MARK: SIGN IN WITH GOOGLE
            Button {
                SignInWithGoogle.instance.startSignInWithGoogleFlow(view: self)
            } label: {
                HStack {
                    Image(systemName: "globe")
                    Text("Sign in with Google")
                }
                .frame(height: 60)
                .frame(maxWidth: .infinity)
                .background(Color(.sRGB, red: 222/255, green: 82/255, blue: 70/255, opacity: 1.0))
                .cornerRadius(4)
                .font(.system(size: 23, weight: .medium, design: .default))
            }
            .accentColor(Color.white)
            
            Button {
                //画面を閉じる
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Continue as guest".uppercased())
                    .font(.headline)
                    .fontWeight(.medium)
                    .padding()
            }
            .accentColor(.black)

        }
        .padding(.all, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.MyTheme.beigeColor)
        .ignoresSafeArea(.all)
        .fullScreenCover(isPresented: $showOnboardingPart2, onDismiss: {
            // 次の画面を開いたタイミングでこの画面を閉じる
            self.presentationMode.wrappedValue.dismiss()
        }, content: {
            OnboardingViewPart2(displayName: $displayName, email: $email, providerID: $providerID, provider: $provider)
        })
        .alert(isPresented: $showError) {
            return Alert(title: Text("Error signing in 😭"))
        }
    }
    
    //MARK: FUNCTION
    
    func connectToFirebase(name: String, email: String, provider: String, credential: AuthCredential) {
        
        //callback(login)
        AuthService.instance.logInUserToFirebase(credential: credential) { providerID, isError, isNewUser, returnedUserID  in
            
            if let newUser = isNewUser {
                if newUser {
                    //新規ユーザー
                    if let providerID = providerID, !isError {
                        //SUCCESS
                        // New user, ログイン(ユーザー)情報を変数に代入(Part2に続く)
                        self.displayName = name
                        self.email = email
                        self.providerID = providerID
                        self.provider = provider
                        self.showOnboardingPart2.toggle()
                    } else {
                        //ERROR
                        print("Error getting provider ID from log in user to Firebase")
                        self.showError.toggle()
                    }
                } else {
                    //既存のユーザー
                    if let userId = returnedUserID {
                        //SUCCESS, LOG IN TO APP
                        AuthService.instance.logInUserToApp(userID: userId) { success in
                            if success {
                                print("Successful log in existing user")
                                //ログイン成功(画面を閉じる)
                                self.presentationMode.wrappedValue.dismiss()
                            } else {
                                //ERROR
                                print("Error logging existing user into our app")
                                self.showError.toggle()
                            }
                        }
                    } else {
                        //ERROR
                        print("Error getting provider ID from log in user to Firebase")
                        self.showError.toggle()
                    }
                }
            } else {
                //ERROR
                print("Error getting into from log in user to Firebase")
                self.showError.toggle()
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
