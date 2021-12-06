//
//  SignInWithAppleButtonCustom.swift
//  DogGram
//
//  Created by 佐藤駿樹 on 2021/10/20.
//

import Foundation
import SwiftUI
import AuthenticationServices

struct SignInWithAppleButtonCustom: UIViewRepresentable {
    
    //SwiftUI用にAppleSignInボタンを作る
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        return ASAuthorizationAppleIDButton(type: .default, style: .black)
    }
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) { }
}
