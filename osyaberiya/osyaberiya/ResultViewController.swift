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
    
    override func viewDidLoad() {
        //ナビゲーションバーレイアウト
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        //ボタンレイアウト
        LayoutViewModel.dropShadow(view: twitterButton)
        LayoutViewModel.dropShadow(view: facebookButton)
        LayoutViewModel.dropShadow(view: saveButton)
        LayoutViewModel.dropShadow(view: closeButton)
        
        //動画設定
        guard let fileUrl = VideoManager.shared.getFileURL() else {
            videoLoadErrorAlert(message: "URLが無効")
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
        
        //動画設定
        let videoPlayerView = AVPlayerView(frame: playerView.bounds)
        guard let layer = videoPlayerView.layer as? AVPlayerLayer else {
            videoLoadErrorAlert(message: "AVPlayerLayerError")
            return
        }
        layer.videoGravity = .resizeAspectFill
        layer.player = videoPlayer
        layer.masksToBounds = true
        layer.cornerRadius = 10
        layer.borderWidth = 2.0
        layer.borderColor = UIColor.white.cgColor
        playerView.layer.addSublayer(layer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
            guard let url = VideoManager.shared.getURL() else {
                videoLoadErrorAlert(message: "URLが無効")
                return
            }
            TwitterViewModel.share(url: url, vc: self)
        } else {// ログインしていない時
            TwitterViewModel.login()
        }
    }
    
    @IBAction func facebook(_ sender: Any) {
        if FBSDKAccessToken.current() != nil {// ログインしている時
            //カメラロール判定
            guard requestPhotoLibrary() else { return }
            
            ResultViewModel.saveVideo(completion: { (isSucsess, title, message) in
                if isSucsess {
                    guard let url = ResultViewModel.shareUrl() else {
                        self.videoLoadErrorAlert(message: "URLが無効")
                        return
                    }
                    FacebookViewModel.share(url: url, vc: self)
                } else {
                    let alert = UIAlertController.show(title: title, message: message)
                    self.present(alert, animated: true, completion: nil)
                }
            })
        } else {// ログインしていない時
            FacebookViewModel.login(vc: self)
        }
    }
    
    // 動画をダウンロードして保存
    @IBAction func save(_ sender: Any) {
        LayoutViewModel.buttonAnimation(button: saveButton)
        
        //カメラロール判定
        guard requestPhotoLibrary() else { return }
        
        ResultViewModel.saveVideo(completion: { (isSucsess, title, message) in
            let alert = UIAlertController.show(title: title, message: message)
            self.present(alert, animated: true, completion: nil)
        })
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
    
    private func videoLoadErrorAlert(message: String) {
        let alert = UIAlertController.show(title: "動画の読み込みに失敗しました", message:"\(UtilModel.contactMessage)\n\(message)" )
        self.present(alert, animated: true, completion: nil)
    }
    
    //フォト許可
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
