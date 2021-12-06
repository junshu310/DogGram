//
//  CommentModel.swift
//  DogGram
//
//  Created by 佐藤駿樹 on 2021/10/18.
//

import Foundation
import SwiftUI

struct CommentModel: Identifiable, Hashable {
    
    var id = UUID()
    var commentID: String //データベース内でのコメントID
    var userID: String
    var username: String
    var content: String
    var date: Date
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
