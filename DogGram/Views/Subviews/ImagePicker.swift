//
//  ImagePicker.swift
//  DogGram
//
//  Created by 佐藤駿樹 on 2021/10/19.
//

import Foundation
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var imageSelected: UIImage
    @Binding var sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        //pickerをカスタマイズ。coordinatorを別で関数として準備する
        picker.delegate = context.coordinator
        //sourceTypeを設定
        picker.sourceType = sourceType
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: UIViewControllerRepresentableContext<ImagePicker>) { }
    
    func makeCoordinator() -> ImagePickerCoordinator {
        return ImagePickerCoordinator(parent: self)
    }
    
    class ImagePickerCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
        let parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        //画像を選択完了後に呼ばれる
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            //編集完了もしくは、オリジナルの画像をUIImage型としてインスタンス化
            if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                //画像を選択
                parent.imageSelected = image
                //画面を閉じる
                parent.presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
