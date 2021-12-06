//
//  UploadView.swift
//  DogGram
//
//  Created by 佐藤駿樹 on 2021/10/19.
//

import SwiftUI
import UIKit

struct UploadView: View {
    
    @State var showImagePicker: Bool = false
    @State var imageSelected: UIImage = UIImage(named: "logo")!
    @State var sourceType: UIImagePickerController.SourceType = .camera
    
    @State var showPostImageView: Bool = false
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        //z方向(後の記述が上になる)
        ZStack {
            //垂直方向
            VStack {
                Button {
                    sourceType = UIImagePickerController.SourceType.camera
                    showImagePicker.toggle()
                } label: {
                    //大文字にする
                    Text("Take photo".uppercased())
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.MyTheme.yellowColor)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .background(Color.MyTheme.purpleColor)
                
                Spacer(minLength: 0)
                
                Button {
                    sourceType = UIImagePickerController.SourceType.photoLibrary
                    showImagePicker.toggle()
                } label: {
                    //大文字にする
                    Text("Import photo".uppercased())
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.MyTheme.purpleColor)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .background(Color.MyTheme.yellowColor)
            }
            .sheet(isPresented: $showImagePicker) {
                //シートが閉じる時
                segueToPostImageView()
            } content: {
                ImagePicker(imageSelected: $imageSelected, sourceType: $sourceType)
                    .preferredColorScheme(colorScheme)
                    //navigationItemの色の変更
                    .accentColor(colorScheme == .light ? Color.MyTheme.purpleColor : Color.MyTheme.yellowColor)
            }

            
            //中央のロゴ
            Image("logo.transparent")
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100, alignment: .center)
                .shadow(radius: 12)
                .fullScreenCover(isPresented: $showPostImageView) {
                    PostImageView(imageSelected: $imageSelected)
                        //新しく表示する画面に対してもダークモードを適応する
                        .preferredColorScheme(colorScheme)
                }
        }
        //safeAreaを無視
        .edgesIgnoringSafeArea(.top)
    }
    
    //MARK: FUNCTION
    func segueToPostImageView() {
        
        //選択した写真をもとに、投稿画面へ遷移(その際に、遅延させて画面の切り替えをする)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showPostImageView.toggle()
        }
    }
}

struct UploadView_Previews: PreviewProvider {
    static var previews: some View {
        UploadView()
            .preferredColorScheme(.dark)
    }
}
