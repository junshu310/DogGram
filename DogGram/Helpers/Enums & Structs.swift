//
//  Enums & Structs.swift
//  DogGram
//
//  Created by 佐藤駿樹 on 2021/10/25.
//

import Foundation

struct DatabaseUserField { // データベース内のユーザードキュメントを持ったフィールド
    
    static let displayName = "display_name"
    static let email = "email"
    static let providerID = "provider_id"
    static let provider = "provider"
    static let userID = "user_id"
    static let bio = "bio"
    static let dateCreated = "date_created"
}

struct DatabasePostField { // データベース内のポストドキュメントを持ったフィールド
    
    static let postID = "post_id"
    static let userID = "user_id"
    static let displayName = "display_name"
    static let caption = "caption"
    static let dateCreated = "date_created"
    static let likeCount = "like_count" // Int
    static let likedBy = "liked_by" // array
    static let comments = "comments" // sub-collection
}

struct DatabaseCommentsField { // Post DocumentのComment SUBCollectionフィールド
    
    static let commentID = "comment_id"
    static let displayName = "display_name"
    static let userID = "user_id"
    static let content = "content"
    static let dateCreated = "date_created"
}

struct DatabaseReportsField { // データベース内のレポートドキュメントを持ったフィールド
    
    static let content = "content"
    static let postID = "post_id"
    static let dateCreated = "date_created"
}

struct CurrentUserDafaults { //アプリ内でuserDefaultsで保存した用
    
    static let displayName = "display_name"
    static let bio = "bio"
    static let userID = "user_id"
}


enum SettingsEditTextOption {
    case displayName
    case bio
}
