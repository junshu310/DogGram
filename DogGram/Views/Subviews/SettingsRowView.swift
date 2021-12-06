//
//  SettingsRowView.swift
//  DogGram
//
//  Created by 佐藤駿樹 on 2021/10/20.
//

import SwiftUI

struct SettingsRowView: View {
    
    var leftImage: String
    var text: String
    var color: Color
    
    var body: some View {
        HStack {
            //背景をつける
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(color)
                
                Image(systemName: leftImage)
                    .font(.title3)
                    .foregroundColor(.white)
            }
            .frame(width: 36, height: 36, alignment: .center)
            
            Text(text)
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.headline)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 4)
    }
}

struct SettingsRowView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsRowView(leftImage: "heart.fill", text: "Row title", color: .red)
            .previewLayout(.sizeThatFits)
    }
}
