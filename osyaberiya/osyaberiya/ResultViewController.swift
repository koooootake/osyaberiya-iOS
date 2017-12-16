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
import TwitterKit

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
    var playerItem: AVPlayerItem!
    var videoPlayer: AVPlayer!
    var fileUrl: URL?
    let errorMessage = "@osyaberiyaまでお問い合わせください"

    override func viewDidLoad() {
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 219/255.0, green: 77/255.0, blue: 96/255.0, alpha: 1.0)
        
        guard let fileUrl = VideoModel.shared.getFileURL() else {
            let alert = UIAlertController.show(title: "動画のURLが無効です", message: "")
            self.present(alert, animated: true, completion: nil)
            return
        }
        let avAsset = AVURLAsset(url: fileUrl)
 
        playerItem = AVPlayerItem(asset: avAsset)
        videoPlayer = AVPlayer(playerItem: playerItem)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
        playerView.layer.addSublayer(layer)
        
        videoPlayer.play()
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
            TWTRTwitter.sharedInstance().logIn(completion: { (session, error) in
                if session != nil {
                    print("Success Twitter: ");
                } else {
                    print("Error Twitter: ");
                }
            })
        }
    }
    
    @IBAction func facebook(_ sender: Any) {
    }
    
    // 動画をダウンロードして保存
    @IBAction func save(_ sender: Any) {
        guard let url = VideoModel.shared.getURL() else {
            let alert = UIAlertController.show(title: "動画のURLが無効です", message: "")
            self.present(alert, animated: true, completion: nil)
            return
        }
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            (data, response, error) in

            if let error = error {
                let alert = UIAlertController.show(title: "通信に失敗しました", message: "")
                self.present(alert, animated: true, completion: nil)
                print("Error session　: \(error)")
                return
            }
            
            guard
                let data = data,
                let searchPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last else {
                self.videoSaveErrorAlert()
                print("Error data or Path")
                return
            }

            let tmpSearchPath = searchPath + "/tmp.mp4"
            let tmpUrl = URL(fileURLWithPath: tmpSearchPath)
            try? data.write(to: tmpUrl)
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: tmpUrl)
            }) { saved, error in
                if saved {
                    let alert = UIAlertController.show(title: "動画を保存しました", message: "")
                    self.present(alert, animated: true, completion: nil)
                    print("Sucsess save video")
                } else {
                    self.videoSaveErrorAlert()
                }
            }
        })
        task.resume()
    }
    
    private func videoSaveErrorAlert() {
        let alert = UIAlertController.show(title: "動画の保存に失敗しました", message: "繰り返し失敗する場合は\n\(self.errorMessage)")
        self.present(alert, animated: true, completion: nil)
    }


    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
