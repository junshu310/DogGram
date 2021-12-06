//
//  LazyView.swift
//  DogGram
//
//  Created by 佐藤駿樹 on 2021/10/30.
//

import Foundation
import SwiftUI

struct LazyView<Content: View>: View {
    
    var content: () -> Content
    
    var body: some View {
        self.content()
    }
}
