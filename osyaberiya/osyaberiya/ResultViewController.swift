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
    var playerItem : AVPlayerItem!
    var videoPlayer : AVPlayer!

    override func viewDidLoad() {

        let path = VideoModel.shared.get()
        let fileUrl = URL(fileURLWithPath: path)
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
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
