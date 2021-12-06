//
//  SignUpView.swift
//  DogGram
//
//  Created by 佐藤駿樹 on 2021/10/20.
//

import SwiftUI

struct SignUpView: View {
    
    @State var showOnboarding: Bool = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            
            Spacer()
            
            Image("logo.transparent")
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100, alignment: .center)
            
            Text("You're not signed in! 😟")
                .font(.largeTitle)
                .fontWeight(.bold)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .foregroundColor(Color.MyTheme.purpleColor)
            
            Text("Click the button below to create an account and join the fun!")
                .font(.headline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(Color.MyTheme.purpleColor)
            
            Button {
                showOnboarding.toggle()
            } label: {
                Text("Sign in / Sign up".uppercased())
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding()
                    .frame(height: 60)
                    .frame(maxWidth: .infinity)
                    .background(Color.MyTheme.purpleColor)
                    .cornerRadius(12)
                    .shadow(radius: 12)
            }
            .accentColor(Color.MyTheme.yellowColor)

            Spacer()
            Spacer()
        }
        
        .padding(.all, 40)
        .background(Color.MyTheme.yellowColor)
        .ignoresSafeArea(.all)
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView()
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
