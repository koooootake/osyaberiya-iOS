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

    override func viewDidLoad() {
        guard let fileUrl = VideoModel.shared.getFileURL() else {
            return
        }
        let avAsset = AVURLAsset(url: fileUrl)
 
        playerItem = AVPlayerItem(asset: avAsset)
        videoPlayer = AVPlayer(playerItem: playerItem)
        
        let videoPlayerView = AVPlayerView(frame: CGRect(x: 0, y: 0, width: playerView.frame.width, height: playerView.frame.height))
        
        guard let layer = videoPlayerView.layer as? AVPlayerLayer else {
            return
        }
        layer.player = videoPlayer
        playerView.layer.addSublayer(layer)

        videoPlayer.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        videoPlayer.pause()
    }
    
    @IBAction func twitter(_ sender: Any) {
        if TWTRTwitter.sharedInstance().sessionStore.hasLoggedInUsers() {// ログインしている時
            guard let url = VideoModel.shared.getURL() else {
                return
            }
            let composer = TWTRComposerViewController(initialText: "#おしゃべりや", image: nil, videoURL: url)
            present(composer, animated: true, completion: nil)
        } else {// ログインしていない時
            TWTRTwitter.sharedInstance().logIn(completion: { (session, error) in
                if (session != nil) {
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
            return
        }
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            (data, response, error) in

            if let error = error {
                print("Error session　: \(error)")
                return
            }
            
            guard let data = data else {
                print("Error data")
                return
            }
            
            let searchPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
            let tmpSearchPath = searchPath + "/tmp.mp4"
            let tmpUrl = URL(fileURLWithPath: tmpSearchPath)
            try? data.write(to: tmpUrl)
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: tmpUrl)
            }) { saved, error in
                if saved {
                    self.showAlert(title: "動画を保存しました", message: "")
                    print("Save video")
                }
            }
        })
        
        task.resume()
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }

    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
