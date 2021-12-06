//
//  SettingsEditTextView.swift
//  DogGram
//
//  Created by 佐藤駿樹 on 2021/10/20.
//

import SwiftUI


struct SettingsEditTextView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @State var submissionText: String = ""
    @State var title: String
    @State var description: String
    @State var placeholder: String
    @State var settingsEditTextOption: SettingsEditTextOption
    @Binding var profileText: String
    
    @AppStorage(CurrentUserDafaults.userID) var currentUserID: String?
    
    @State var showSuccessAlert: Bool = false
    
    let haptics = UINotificationFeedbackGenerator()
    
    var body: some View {
        VStack {
            HStack {
                Text(description)
                Spacer(minLength: 0)
            }
            
            TextField(placeholder, text: $submissionText)
                .padding()
                .frame(height: 60)
                .frame(maxWidth: .infinity)
                .background(colorScheme == .light ? Color.MyTheme.beigeColor : Color.MyTheme.purpleColor)
                .cornerRadius(12)
                .font(.headline)
                .autocapitalization(.sentences)
            
            Button {
                if textIsAppropriate() {
                    saveText()
                }
            } label: {
                Text("Save".uppercased())
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding()
                    .frame(height: 60)
                    .frame(maxWidth: .infinity)
                    .background(colorScheme == .light ? Color.MyTheme.purpleColor : Color.MyTheme.yellowColor)
                    .cornerRadius(12)
            }
            .accentColor(colorScheme == .light ? Color.MyTheme.yellowColor : Color.MyTheme.purpleColor)

            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .navigationTitle(title)
        .alert(isPresented: $showSuccessAlert) {
            return Alert(title: Text("Saved! 🥳"), message: nil, dismissButton: .default(Text("OK"), action: {
                dismissView()
            }))
        }
    }
    
    //MARK: FUNCTION
    
    func dismissView() {
        self.haptics.notificationOccurred(.success)
        self.presentationMode.wrappedValue.dismiss()
    }
    
    func textIsAppropriate() -> Bool {
        //不適切なコメントでないかをチェックする
        
        //不適切な言葉がないか調べる（一例）
        let badWordArray: [String] = ["shit", "ass"]
        let words = submissionText.components(separatedBy: " ")
        for word in words {
            if badWordArray.contains(word) {
                return false
            }
        }
        
        //コメントが3文字以上か調べる
        if submissionText.count < 3 {
            return false
        }
        
        return true
    }
    
    func saveText() {
        
        guard let userID = currentUserID else { return }
        
        switch settingsEditTextOption {
        case .displayName:
            
            // プロフィールのUIを更新
            self.profileText = submissionText //submissionTextはBindingされてないので前の画面では更新されない
            
            // UserDefaultsを更新
            UserDefaults.standard.set(submissionText, forKey: CurrentUserDafaults.displayName)
            
            // ユーザーの全ての投稿を更新
            DataService.instance.updateDisplayNameOnPosts(userID: userID, displayName: submissionText)
            
            // DB内のユーザーのプロフィールを更新
            AuthService.instance.updateUserDisplayName(userID: userID, displayName: submissionText) { success in
                if success {
                    self.showSuccessAlert.toggle()
                }
            }
            
            break
        case .bio:
            
            // プロフィールのUIを更新
            self.profileText = submissionText
            
            // UserDefaultsを更新
            UserDefaults.standard.set(submissionText, forKey: CurrentUserDafaults.bio)

            // DB内のユーザーのプロフィールを更新
            AuthService.instance.updateUserBio(userID: userID, bio: submissionText) { success in
                if success {
                    self.showSuccessAlert.toggle()
                }
            }
        }
    }
}

struct SettingsEditTextView_Previews: PreviewProvider {
    
    @State static var test: String = ""
    
    static var previews: some View {
        NavigationView {
            SettingsEditTextView(title: "Test Title", description: "This is a discription", placeholder: "Test Placeholder", settingsEditTextOption: .displayName, profileText: $test)
                .preferredColorScheme(.dark)
        }
    }
}
