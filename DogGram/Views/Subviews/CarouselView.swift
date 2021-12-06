//
//  CarouselView.swift
//  DogGram
//
//  Created by 佐藤駿樹 on 2021/10/18.
//

import SwiftUI

struct CarouselView: View {
    
    @State var selection: Int = 1
    let maxCount: Int = 8
    //timerが動き続けるのを防ぐ
    @State var timerAdded: Bool = false
    
    var body: some View {
        //TabViewの生成(selection: ドットが移動)
        TabView(
            selection: $selection,
            content: {
                
                //ForEach(1~7まで、画像とタグを呼び出す)
                ForEach(1..<maxCount) { count in
                    Image("dog\(count)")
                        .resizable()
                        .scaledToFill()
                        .tag(count)
                }
                
//                Image("dog1")
//                    .resizable()
//                    .scaledToFill()
//                    .tag(0)
//                Image("dog2")
//                    .resizable()
//                    .scaledToFill()
//                    .tag(1)
//                Image("dog3")
//                    .resizable()
//                    .scaledToFill()
//                    .tag(2)
                
            })
            //tabViewのスタイル変更
            .tabViewStyle(PageTabViewStyle())
            //高さの設定
            .frame(height: 300)
            .animation(.default)
            .onAppear {
                if !timerAdded {
                    addTimer()
                }
            }
    }
    
    //MARK: FUNCTION
    //自動スクロールのためのタイマーを作る
    
    func addTimer() {
        
        timerAdded = true
        
        let timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { timer in
            
            if selection == (maxCount - 1) {
                selection = 1
            } else {
                selection += 1
            }
        }
        timer.fire()
    }
}

struct CarouselView_Previews: PreviewProvider {
    static var previews: some View {
        CarouselView()
            .previewLayout(.sizeThatFits)
    }
}
