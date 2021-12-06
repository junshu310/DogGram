//
//  AuthService.swift
//  DogGram
//
//  Created by 佐藤駿樹 on 2021/10/24.
//

// Used to Authenticate users in Firebase（アカウント生成）
// Used to handle User accounts in Firebase（アカウントを取り出す＝ログイン）

import Foundation
import FirebaseAuth
import FirebaseFirestore // Database

let DB_BASE = Firestore.firestore()

class AuthService {
    
    
    //MARK: PROPERTIES
    
    static var instance = AuthService()
    
    //ユーザーのレファレンス（コレクション名）
    private var REF_USERS = DB_BASE.collection("users")
    
    
    //MARK: AUTH USER FUNCTION
    
    //databaseにログイン
    func logInUserToFirebase(credential: AuthCredential, handler: @escaping (_ providerID: String?, _ isError: Bool, _ isNewUser: Bool?, _ userID: String?) -> ()) {
        
        //サインイン
        Auth.auth().signIn(with: credential) { result, error in
            
            //エラーのチェック
            if error != nil {
                print("Error logging in to Firebase")
                handler(nil, true, nil, nil)
                return
            }
            
            //プロバイダーIDのチェック
            guard let providerID = result?.user.uid else {
                print("Error getting provide ID")
                handler(nil, true, nil, nil)
                return
            }
            
            //firebaseへの接続成功（既存のユーザー or 新規ユーザーかをチェック）
            self.checkIfUserExistsInDatabase(providerID: providerID) { returnedUserID in
                
                if let userID = returnedUserID {
                    // 既存のユーザー → ログイン
                    handler(providerID, false, false, userID)
                } else {
                    // 新規ユーザー → onboardingのnew userへ
                    handler(providerID, false, true, nil)
                }
            }
            
            
//            handler(providerID, false)
        }
    }
    
    
    //ログアウト
    func logOutUser(handler: @escaping (_ success: Bool) -> ()) {
        
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error \(error)")
            handler(false)
            return
        }
        
        handler(true)
        
        //UserDefaultsをアップデート
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            //UserDefaultsから値を削除（項目漏れがないようにforEach文を回して削除）
            
            //全ての項目を取る
            let defaultsDictionary = UserDefaults.standard.dictionaryRepresentation()
            //key値を回す
            defaultsDictionary.keys.forEach { key in
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
    }
    
    
    //ログイン情報を元にappにつなげる(UIに適応)
    func logInUserToApp(userID: String, handler: @escaping (_ success: Bool) -> ()) {
        
        //ユーザー情報を取得
        getUserInfo(forUserID: userID) { name, bio in
            
            if let name = name, let bio = bio {
                
                print("Success getting user ingo while loggin in")
                handler(true)
            
                //ログイン成功後、ユーザー情報をアプリ内に保存（userDefaults）
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    UserDefaults.standard.set(userID, forKey: CurrentUserDafaults.userID)
                    UserDefaults.standard.set(name, forKey: CurrentUserDafaults.displayName)
                    UserDefaults.standard.set(bio, forKey: CurrentUserDafaults.bio)
                }
                
            } else {
                print("Error getting user info while loggin in")
                handler(false)
            }
        }
    }
    
    
    func createNewUserInDatabase(name: String, email: String, providerID: String, provider: String, profileImage: UIImage, handler: @escaping (_ userID: String?) -> ()) {
        
        //Set up a user document with the user Collection（documentをセットアップ）
        let document = REF_USERS.document()
        let userID = document.documentID
        
        // Storageにプロフィール画像をアップロード
        ImageManager.instance.uploadProfileImage(userID: userID, image: profileImage)
        
        // Firestoreにプロフィールデータをアップロード
        let userData: [String: Any] = [
            DatabaseUserField.displayName : name,
            DatabaseUserField.email : email,
            DatabaseUserField.providerID : providerID,
            DatabaseUserField.provider : provider,
            DatabaseUserField.userID : userID,
            DatabaseUserField.bio : "",
            DatabaseUserField.dateCreated : FieldValue.serverTimestamp()
        ]
        
        //setData
        document.setData(userData) { error in
            
            if let error = error {
                //ERROR
                print("Error uploading data to user document \(error)")
                handler(nil)
            } else {
                //SUCCESS
                handler(userID)
            }
        }
    }
    
    private func checkIfUserExistsInDatabase(providerID: String?, handler: @escaping(_ existingUserID: String?) -> ()) {
        // UserIDが返って来れば、databese内にユーザーが存在する
        
        REF_USERS.whereField(DatabaseUserField.providerID, isEqualTo: providerID).getDocuments { querySnapshot, error in
            
            if let snapshot = querySnapshot, snapshot.count > 0, let document = snapshot.documents.first {
                //SUCCESS
                let existingUserID = document.documentID
                handler(existingUserID)
                return
            } else {
                //ERROR, NEW USER
                handler(nil)
                return
            }
        }
    }
    
    
    //MARK: GET USER FUMCTION
    
    func getUserInfo(forUserID userID: String, handler: @escaping (_ name: String?, _ bio: String?) -> ()) {
        
        //userIDからユーザー情報を取得
        REF_USERS.document(userID).getDocument { documentSnapshot, error in
            
            if let document = documentSnapshot,
               let name = document.get(DatabaseUserField.displayName) as? String,
               let bio = document.get(DatabaseUserField.bio) as? String {
                
                print("Success getting user info")
                handler(name, bio)
                return
                
            } else {
                print("Error getting user info")
                handler(nil, nil)
                return
            }
        }
    }
    
    
    //MARK: UPDATE USER FUNCTIONS
    
    func updateUserDisplayName(userID: String, displayName: String, handler: @escaping (_ success: Bool) -> ()) {
        
        //userIDを元にDB内のユーザー名の更新
        let data: [String:Any] = [
            DatabaseUserField.displayName : displayName
        ]
        
        REF_USERS.document(userID).updateData(data) { error in
            if let error = error {
                print("Error updating user display name. \(error)")
                handler(false)
                return
            } else {
                handler(true)
                return
            }
        }
    }
    
    func updateUserBio(userID: String, bio: String, handler: @escaping (_ success: Bool) -> ()) {
        
        //userIDを元にDB内のユーザー名の更新
        let data: [String:Any] = [
            DatabaseUserField.bio : bio
        ]
        
        REF_USERS.document(userID).updateData(data) { error in
            if let error = error {
                print("Error updating user bio. \(error)")
                handler(false)
                return
            } else {
                handler(true)
                return
            }
        }
    }
}
