//
//  DogGramApp.swift
//  DogGram
//
//  Created by 佐藤駿樹 on 2021/10/16.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

@main
struct DogGramApp: App {
    
    init() {
        
        FirebaseApp.configure()
        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID // For Google sign in
        
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    GIDSignIn.sharedInstance().handle(url) // For Google sign in
                }
        }
    }
}

