//
//  AnalyticsService.swift
//  DogGram
//
//  Created by 佐藤駿樹 on 2021/11/06.
//

import Foundation
import FirebaseAnalytics

class AnalyticsService {
    
    static let instance = AnalyticsService()
    
    func likePostDoubleTap() {
        Analytics.logEvent("like_double_tap", parameters: nil)
    }
    
    func likePostHeartPressed() {
        Analytics.logEvent("like_heart_clicked", parameters: nil)
    }
}
