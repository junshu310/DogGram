//
//  PostModel.swift
//  DogGram
//
//  Created by 佐藤駿樹 on 2021/10/17.
//

import Foundation
import SwiftUI

struct PostModel: Identifiable, Hashable {
    
    var id = UUID()
    var postID: String
    var userID: String
    var username: String
    var caption: String?
    var dateCreate: Date
    var likeCount: Int
    var likedByUser: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
