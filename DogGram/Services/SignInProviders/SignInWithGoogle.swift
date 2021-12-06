//
//  SignInWithGoogle.swift
//  DogGram
//
//  Created by 佐藤駿樹 on 2021/10/24.
//

import Foundation
import SwiftUI
import GoogleSignIn
import FirebaseAuth

class SignInWithGoogle: NSObject, GIDSignInDelegate {
    
    static let instance = SignInWithGoogle()
    var onboardingView: OnboardingView!
    
    func startSignInWithGoogleFlow(view: OnboardingView) {
        //ログイン画面を表示
        self.onboardingView = view
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().presentingViewController = UIApplication.shared.windows.first?.rootViewController
        GIDSignIn.sharedInstance().presentingViewController.modalPresentationStyle = .fullScreen
        GIDSignIn.sharedInstance().signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        //サインイン成功時
        if let error = error {
            //エラー画面を表示(ON)
            print("ERROR SIGNING IN TO GOOGLE: \(error)")
            self.onboardingView.showError.toggle()
            return
        }
        
        //googleアカウント情報から取得
        let fullName: String = user.profile.name
        let email: String = user.profile.email
        
        //ログイン情報？
        let idToken: String = user.authentication.idToken
        let accessToken: String = user.authentication.accessToken
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
//        print("SIGN IN TO FIREBASE NOW. WITH NAME: \(fullName) and EMAIL: \(email)")
        self.onboardingView.connectToFirebase(name: fullName, email: email, provider: "google", credential: credential)
    }
    
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
        //エラー画面を表示(ON)
        print("USER DISCONNECTED FROM GOOGLE")
        self.onboardingView.showError.toggle()
    }
}
