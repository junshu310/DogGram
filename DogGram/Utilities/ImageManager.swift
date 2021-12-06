//
//  ImageManager.swift
//  DogGram
//
//  Created by 佐藤駿樹 on 2021/10/25.
//

import Foundation
import FirebaseStorage //画像ど動画を保存
import SwiftUI

let imageCache = NSCache<AnyObject, UIImage>()

class ImageManager {
    
    
    //MARK: PROPERTIES
    
    static let instance = ImageManager()
    
    //リファレンス
    private var REF_STOR = Storage.storage()
    
    
    
    //MARK: PUBLIC FUNCTIONS
    //アプリ内から呼び出す
    
    func uploadProfileImage(userID: String, image: UIImage) {
        
        // 画像を保存する場所のpathを取得
        let path = getProfileImagePath(userID: userID)
        
        // pathへ画像を保存
        // アップロードに時間がかかるためバックグラウンドスレッドに配置する
        DispatchQueue.global(qos: .userInteractive).async {
            self.uploadImage(path: path, image: image) { _ in }
        }
    }
    
    func uploadPostImage(postID: String, image: UIImage, handler: @escaping(_ success: Bool) -> ()) {
        
        // 画像を保存する場所のpathを取得
        let path = getPostImagePath(postID: postID)

        // pathへ画像を保存
        DispatchQueue.global(qos: .userInteractive).async {
            self.uploadImage(path: path, image: image) { success in
                // uploadの成功(true)or失敗(false)
                // メインスレッドに戻す
                DispatchQueue.main.async {
                    handler(success)
                }
            }
        }
    }
    
    func downloadProfileImage(userID: String, handler: @escaping (_ image: UIImage?) -> ()) {
        
        // 画像を保存する場所のpathを取得
        let path = getProfileImagePath(userID: userID)
        
        // pathから画像をダウンロード
        DispatchQueue.global(qos: .userInteractive).async {
            self.downloadImage(path: path) { returnedImage in
                DispatchQueue.main.async {
                    handler(returnedImage)
                }
            }
        }
    }
    
    func downloadPostImage(postID: String, handler: @escaping (_ image: UIImage?) -> ()) {
        
        // 画像を保存する場所のpathを取得
        let path = getPostImagePath(postID: postID)
        
        // pathから画像をダウンロード
        DispatchQueue.global(qos: .userInteractive).async {
            self.downloadImage(path: path) { returnedImage in
                DispatchQueue.main.async {
                    handler(returnedImage)
                }
            }
        }
    }
    
    //MARK: PRIVATE FUNCTIONS
    //このファイル内から呼び出す
    
    //プロフィール画像のpathを取得
    private func getProfileImagePath(userID: String) -> StorageReference {
        
        let userPath = "users/\(userID)/profile"
        let storagePath = REF_STOR.reference(withPath: userPath)
        return storagePath
    }
    
    
    private func getPostImagePath(postID: String) -> StorageReference {
        
        let postPath = "posts/\(postID)/1"
        let storagePath = REF_STOR.reference(withPath: postPath)
        return storagePath
    }
    
    
    // 指定されたpathにimageをアップロードする
    private func uploadImage(path: StorageReference, image: UIImage, handler: @escaping (_ success: Bool) -> ()) {
        
        //クロージャー(pathとimageに値が入る → 圧縮したimageデータを取得 → そのデータをpathへputData → handlerに値が入ってこの関数内の処理が終了)
        
        //画像を圧縮
        var compression: CGFloat = 1.0 // 0.05ずつ下げる
        let maxFileSize: Int = 240 * 240 // 画像の最大のサイズ
        let maxCompression: CGFloat = 0.05 // 最大の圧縮
        
        //オリジナルの画像データを取得
        guard var originalData = image.jpegData(compressionQuality: compression) else {
            print("Error getting data from image")
            handler(false)
            return
        }
        
        //compressionを指定
        while (originalData.count > maxFileSize) && (compression > maxCompression) {
            
            compression -= 0.05
            
            if let compressionData = image.jpegData(compressionQuality: compression) {
                //オリジナルデータが圧縮された物に上書きされていく
                originalData = compressionData
            }
            print(compression)
        }
        
        //圧縮が完了した画像データを取得
        guard let finalData = image.jpegData(compressionQuality: compression) else {
            print("Error getting data from image")
            handler(false)
            return
        }
        
        //メタデータを取得（jpegデータとして取得）
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        //データをpathへ保存
        path.putData(finalData, metadata: metadata) { _, error in
            
            //putDataが完了したら呼ばれる
            if let error = error {
                print("Error uploading image. \(error)")
                //handlerに値が入ってこの関数が完全に返される
                handler(false)
                return
                
            } else {
                print("Success uploading image.")
                handler(true)
                return
            }
            
        }
    }
    
    //pathから画像をダウンロード
    private func downloadImage(path: StorageReference, handler: @escaping (_ image: UIImage?) -> ()) {
        
        //既にprofileImageをダウンロード済みかどうか(キー値: 画像のpath)
        if let cachedImage = imageCache.object(forKey: path) {
            //profileImageをダウンロード済み
            print("Image found in cache")
            handler(cachedImage)
            return
        } else {
            //27 * 1024 * 1024 = データベースに保存できる最大のサイズ。　but,サイズはアップロードの際に圧縮されているので無関係
            path.getData(maxSize: 27 * 1024 * 1024) { returnedImageData, error in
                if let data = returnedImageData, let image = UIImage(data: data) {
                    // 画像のダウンロード成功
                    imageCache.setObject(image, forKey: path)
                    handler(image)
                    return
                } else {
                    print("Error getting data from path for image")
                    handler(nil)
                    return
                }
            }
        }
    }
}
