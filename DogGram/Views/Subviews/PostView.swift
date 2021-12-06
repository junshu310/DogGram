//
//  PostView.swift
//  DogGram
//
//  Created by 佐藤駿樹 on 2021/10/16.
//

import SwiftUI

struct PostView: View {
    
    @State var post: PostModel
    //高さを決める（headr, footerの表示・非表示）
    var showHeaderAndFooter: Bool
    
    @State var animateLike: Bool = false
    @State var addheartAnimationToView: Bool
    
    @State var showActionSheet: Bool = false
    @State var actionSheetType: PostActionSheetOption = .general
    
    @State var profileImage: UIImage = UIImage(named: "logo.loading")!
    @State var postImage: UIImage = UIImage(named: "logo.loading")!
    
    @AppStorage(CurrentUserDafaults.userID) var currentUserID: String?
    
    @State var alertTitle: String = ""
    @State var alertMessage: String = ""
    @State var showAlert: Bool = false
    
    enum PostActionSheetOption {
        case general
        case reporting
    }
    
    var body: some View {
        
        // MARK: HEADER
        //垂直方向に並べる
        VStack(alignment: .center, spacing: 0) {
            
            if showHeaderAndFooter {
                //水平方向に並べる
                HStack {
                    
                    //プロフィール画面に遷移
                    NavigationLink {
                        //不必要なデータを呼び出しているのを防ぐ(LazyView)
                        LazyView(content: {
                            ProfileView(isMyProfile: false, profileDisplayName: post.username, profileUserID: post.userID, posts: PostArrayObject(userID: post.userID))
                        })
                    } label: {
                        Image(uiImage: profileImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 30, height: 30, alignment: .center)
                            .cornerRadius(15)
                        
                        Text(post.username)
                            .font(.callout)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Button {
                        showActionSheet.toggle()
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.headline)
                    }
                    .accentColor(.primary)
                    .actionSheet(isPresented: $showActionSheet) {
                        getActionSheet()
                    }
                }
                .padding(.all, 6)
            }
            
            // MARK: IMAGE
            
            ZStack {
                Image(uiImage: postImage)
                    .resizable()
                    .scaledToFit()
                    //ダブルタップでlike
                    .onTapGesture(count: 2) {
                        if !post.likedByUser {
                            likePost()
                            AnalyticsService.instance.likePostDoubleTap()
                        }
                    }
                
                if addheartAnimationToView {
                    LikeAnimationView(animate: $animateLike)
                }
            }
            
            // MARK: FOOTER
            if showHeaderAndFooter {
                // (spacing: 配置したもの同士の間隔)
                HStack(alignment: .center, spacing: 20) {
                    
                    Button {
                        if post.likedByUser {
                            //likeの時 => unlikeになる
                            unlikePost()
                        } else {
                            //unlikeの時 => likeになる
                            likePost()
                            AnalyticsService.instance.likePostHeartPressed()
                        }
                    } label: {
                        Image(systemName: post.likedByUser ? "heart.fill" : "heart")
                            .font(.title3)
                    }
                    .accentColor(post.likedByUser ? .red : .primary)
                    
                    //MARK: COMMENT ICON
                    //NavigationLinkによる画面遷移
                    NavigationLink {
                        CommentsView(post: post)
                    } label: {
                        Image(systemName: "bubble.middle.bottom")
                            .font(.title3)
                            //navigationLinkのディフォルト色がグレー
                            .foregroundColor(.primary)
                    }
                    
                    Button {
                        sharePost()
                    } label: {
                        Image(systemName: "paperplane")
                            .font(.title3)
                    }
                    .accentColor(.primary)
                    
                    Spacer()
                }
                .padding(.all, 6)
                
                if let caption = post.caption {
                    HStack{
                        Text(caption)
                        Spacer(minLength: 0)
                    }
                    .padding(.all, 6)
                }
            }
        }
        //画面が表示されたタイミングで画像を読み込み(=画面に表示されていないデータは読み込まない)
        .onAppear {
            getImages()
        }
        .alert(isPresented: $showAlert) {
            return Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    //MARK: FUNCTION
    
    func likePost() {
        
        guard let userID = currentUserID else {
            print("Cannnot find userID while liking post")
            return
        }
        
        //取得しているpostの情報を書き換える
        let updatedPost = PostModel(postID: post.postID, userID: post.userID, username: post.username, caption: post.caption, dateCreate: post.dateCreate, likeCount: post.likeCount + 1, likedByUser: true)
        
        self.post = updatedPost
        
        //いいねをした時に画像上のlikeAnimationを起動(true)
        animateLike = true
        //animationが終了する0.5秒後にanimetionを非表示(false)にする
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            animateLike = false
        }
        
        //データベースを更新
        DataService.instance.likePost(postID: post.postID, currentUserID: userID)
    }
    
    
    func unlikePost() {
        
        guard let userID = currentUserID else {
            print("Cannnot find userID while unlikeng post")
            return
        }
        
        let updatedPost = PostModel(postID: post.postID, userID: post.userID, username: post.username, caption: post.caption, dateCreate: post.dateCreate, likeCount: post.likeCount - 1, likedByUser: false)
        
        self.post = updatedPost
        
        //データベースを更新
        DataService.instance.unlikePost(postID: post.postID, currentUserID: userID)
    }
    
    func getImages() {
        
        //プロフィール画像をダウンロード
        ImageManager.instance.downloadProfileImage(userID: post.userID) { image in
            if let image = image {
                self.profileImage = image
            }
        }
        
        //投稿画像をダウンロード
        ImageManager.instance.downloadPostImage(postID: post.postID) { image in
            if let image = image {
                self.postImage = image
            }
        }
    }
    
    func getActionSheet() -> ActionSheet {
        
        switch self.actionSheetType {
            
        case .general:
            return ActionSheet(title: Text("What would you like to do?"), message: nil, buttons: [
                
                .cancel(),
                
                .destructive(Text("Report"), action: {
                    // reportのアクションシートが開く状態
                    self.actionSheetType = .reporting
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        //アクションシートを切り替える
                        self.showActionSheet.toggle()
                    }
                }),
                
                .default(Text("Learn more..."), action: {
                    print("LEARN MORE PRESSED")
                })
            ])
            
        case .reporting:
            return ActionSheet(title: Text("Why are you reporting this post?"), message: nil, buttons: [
                
                .cancel({
                    // 次アクションシートを開く時には .general
                    self.actionSheetType = .general
                }),
                
                .destructive(Text("This is inappropriate"), action: {
                    reportPost(reason: "This is inappropriate")
                }),
                
                .destructive(Text("This is spam"), action: {
                    reportPost(reason: "This is spam")
                }),
                
                .destructive(Text("It made me uncomfortable"), action: {
                    reportPost(reason: "It made me uncomfortable")
                })
            ])
        }
    }
    
    //postIDとreasonを元に
    func reportPost(reason: String) {
        print("REPORT POST NOW")
        
        DataService.instance.uploadReport(reason: reason, postID: post.postID) { success in
            if success {
                self.alertTitle = "Reported!"
                self.alertMessage = "Thanks for reporting this post. We will review it shortly and take the appropriate action!"
                self.showAlert.toggle()
            } else {
                self.alertTitle = "Error"
                self.alertMessage = "There was an error uploading the report. Please restart the app and try again."
                self.showAlert.toggle()
            }
        }
    }
    
    func sharePost() {
        
        let message = "Check out this post on DogGram!"
        let image = postImage
        let link = URL(string: "https://www.google.com")!
        
        let activityVC = UIActivityViewController(activityItems: [message, image, link], applicationActivities: nil)
        
        let viewController = UIApplication.shared.windows.first?.rootViewController
        viewController?.present(activityVC, animated: true, completion: nil)
    }
}


struct PostView_Previews: PreviewProvider {
    
    static var post: PostModel = PostModel(postID: "", userID: "", username: "Shota", caption: "This is a test caption", dateCreate: Date(), likeCount: 0, likedByUser: false)
    
    static var previews: some View {
        PostView(post: post, showHeaderAndFooter: true, addheartAnimationToView: true)
            //画面サイズ
            .previewLayout(.sizeThatFits)
    }
}
