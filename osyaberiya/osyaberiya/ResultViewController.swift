//
//  AVPlayerViewController.swift
//  osyaberiya
//
//  Created by koooootake on 2017/12/16.
//  Copyright © 2017年 koooootake. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMedia
import Photos
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit

class AVPlayerView: UIView {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}

class ResultViewController: UIViewController {
    
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var settingButton: UIBarButtonItem!
    
    var playerItem: AVPlayerItem!
    var videoPlayer: AVPlayer!
    var fileUrl: URL?
    let errorMessage = "@osyaberiyaまでお問い合わせください"
    
    override func viewDidLoad() {
        // ナビゲーションを透明にする処理
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        LayoutModel.dropShadow(view: twitterButton)
        LayoutModel.dropShadow(view: facebookButton)
        LayoutModel.dropShadow(view: saveButton)
        LayoutModel.dropShadow(view: closeButton)
        
        guard let fileUrl = VideoModel.shared.getFileURL() else {
            let alert = UIAlertController.show(title: "動画のURLが無効です", message: "")
            self.present(alert, animated: true, completion: nil)
            return
        }
        let avAsset = AVURLAsset(url: fileUrl)
        playerItem = AVPlayerItem(asset: avAsset)
        videoPlayer = AVPlayer(playerItem: playerItem)
        
        self.view.backgroundColor = UIColor.clear
        self.view.alpha = 0.0
        settingButton.tintColor = UIColor.clear
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let videoPlayerView = AVPlayerView(frame: playerView.bounds)
        
        guard let layer = videoPlayerView.layer as? AVPlayerLayer else {
            let alert = UIAlertController.show(title: "動画の表示に失敗しました", message: "")
            self.present(alert, animated: true, completion: nil)
            return
        }
        layer.videoGravity = .resizeAspectFill
        layer.player = videoPlayer
        layer.masksToBounds = true
        layer.cornerRadius = 10
        layer.borderWidth = 2.0
        layer.borderColor = UIColor.white.cgColor
        playerView.layer.addSublayer(layer)
        
        //アニメーション
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseIn], animations: {
            self.view.alpha = 1.0
            self.settingButton.tintColor = UIColor.white
        }, completion: { _ in
            self.videoPlayer.play()
        })
    }
    
    @IBAction func replay(_ sender: Any) {
        videoPlayer.seek(to: CMTimeMakeWithSeconds(0, Int32(NSEC_PER_SEC)))
        videoPlayer.play()
    }
    
    @IBAction func twitter(_ sender: Any) {
        if TWTRTwitter.sharedInstance().sessionStore.hasLoggedInUsers() {// ログインしている時
            guard let url = VideoModel.shared.getURL() else {
                let alert = UIAlertController.show(title: "動画のURLが無効です", message: "")
                self.present(alert, animated: true, completion: nil)
                return
            }
            let composer = TWTRComposerViewController(initialText: "#おしゃべりや", image: nil, videoURL: url)
            present(composer, animated: true, completion: nil)
        } else {// ログインしていない時
            TwitterModel.login()
        }
    }
    
    @IBAction func facebook(_ sender: Any) {
        if FBSDKAccessToken.current() != nil {// ログインしている時
            saveVideo(completion: { isSucsess in
                if isSucsess {
                    self.fbPost()
                }
            })
        } else {// ログインしていない時
            let loginManager = FBSDKLoginManager()
            loginManager.logIn(withPublishPermissions: ["publish_actions"], from: self) { (result, error) in
                if let error = error {
                    print("Error : \(error)")
                    return
                }
                if let result = result {
                    if result.isCancelled {
                        print("Cancell")
                        return
                    } else {
                        print("Sucsess Login :")
                        
                    }
                }
            }
        }
    }
    
    private func fbPost() {
        //最後に保存したVideoのassetURLを取得
        let asset = self.getLastVideo()
        guard let identifier = asset?.localIdentifier else {
            let alert = UIAlertController.show(title: "動画の読み込みに失敗しました", message: errorMessage)
            self.present(alert, animated: true, completion: nil)
            return
        }
        let id = identifier.prefix(36)
        let url = "assets-library://asset/asset.MP4?id=\(id)&ext=MP4"
        print("url : \(url)")
        let videoUrl = URL(string: url)
        
        //ビデオシェア
        let content = FBSDKShareVideoContent()
        guard let video = FBSDKShareVideo(videoURL: videoUrl) else {
            let alert = UIAlertController.show(title: "動画の読み込みに失敗しました", message: errorMessage)
            self.present(alert, animated: true, completion: nil)
            return
        }
        content.video = video
        DispatchQueue.main.async {
            FBSDKShareDialog.show(from: self, with: content, delegate: nil)
        }
    }
    // 動画をダウンロードして保存
    @IBAction func save(_ sender: Any) {
        LayoutModel.buttonAnimation(button: saveButton)
        saveVideo(completion: { isSucsess in
            if isSucsess {
                let alert = UIAlertController.show(title: "動画を保存しました", message: "")
                self.present(alert, animated: true, completion: nil)
            }
            
        })
    }
    
    private func saveVideo(completion: @escaping (_ isSucsess: Bool) -> Void) {
        //カメラロール判定
        guard requestPhotoLibrary() else {
            return
        }
        
        guard let url = VideoModel.shared.getURL() else {
            let alert = UIAlertController.show(title: "動画のURLが無効です", message: "")
            self.present(alert, animated: true, completion: nil)
            completion(false)
            return
        }
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            (data, response, error) in
            
            if let error = error {
                let alert = UIAlertController.show(title: "通信に失敗しました", message: "")
                self.present(alert, animated: true, completion: nil)
                print("Error session　: \(error)")
                completion(false)
                return
            }
            
            guard
                let data = data,
                let searchPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last else {
                    self.videoSaveErrorAlert()
                    print("Error data or Path")
                    completion(false)
                    return
            }
            
            let name = VideoModel.shared.fileName
            let tmpSearchPath = searchPath + "/\(name ?? "tmp")"
            let tmpUrl = URL(fileURLWithPath: tmpSearchPath)
            try? data.write(to: tmpUrl)
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: tmpUrl)
            }) { saved, error in
                if saved {
                    print("Sucsess save video : \(tmpUrl)")
                    completion(true)
                    
                } else {
                    self.videoSaveErrorAlert()
                    print("Error save")
                    completion(false)
                }
            }
        })
        task.resume()
    }
    
    private func getLastVideo() -> PHAsset? {
        let assets: PHFetchResult = PHAsset.fetchAssets(with: .video, options: nil)
        guard let asset = assets.lastObject else {
            return nil
        }
        return asset
    }
    
    private func videoSaveErrorAlert() {
        let alert = UIAlertController.show(title: "動画の保存に失敗しました", message: "繰り返し失敗する場合は\n\(self.errorMessage)")
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func close(_ sender: Any) {
        //アニメーション
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseIn], animations: {
            self.view.alpha = 0.0
            self.settingButton.tintColor = UIColor.clear
        }, completion: { _ in
            
            self.dismiss(animated: true, completion: nil)
            //同時押し対策
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    private func requestPhotoLibrary() -> Bool {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            return true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({_ in })
            return false
        case .denied,.restricted:
            let alert = UIAlertController.show(title: "カメラロールへのアクセスが\n許可されていません", message: "端末の設定から\nおしゃべりやの写真のアクセスを許可してください\nお願いします🙏")
            self.present(alert, animated: true, completion: nil)
            return false
        }
    }
}
