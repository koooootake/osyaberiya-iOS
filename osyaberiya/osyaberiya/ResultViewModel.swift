//
//  TwitterModel.swift
//  osyaberiya
//
//  Created by koooootake on 2017/12/17.
//  Copyright © 2017年 koooootake. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import Photos

class ResultViewModel: NSObject {
    
    static func saveVideo(completion: @escaping (_ isSucsess: Bool, _ title: String, _ message: String) -> Void) {
        
        guard let url = VideoManager.shared.getURL() else {
            completion(false, "動画のURLが無効です", UtilModel.contactMessage)
            return
        }
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            (data, response, error) in
            
            if let error = error {
                completion(false, "通信に失敗しました🙅‍♂️", "\(error)")
                return
            }
            
            guard
                let data = data,
                let searchPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last else {
                    completion(false, "動画の保存に失敗しました", UtilModel.contactMessage)
                    return
            }
            
            let name = VideoManager.shared.fileName
            let tmpSearchPath = searchPath + "/\(name ?? "tmp")"
            let tmpUrl = URL(fileURLWithPath: tmpSearchPath)
            try? data.write(to: tmpUrl)
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: tmpUrl)
            }) { saved, error in
                if saved {
                    completion(true, "動画を保存しました🎉", "")
                } else {
                    completion(true, "動画の保存に失敗しました", UtilModel.contactMessage)
                }
            }
        })
        task.resume()
    }
    
    static func getLastVideo() -> PHAsset? {
        let assets: PHFetchResult = PHAsset.fetchAssets(with: .video, options: nil)
        guard let asset = assets.lastObject else {
            return nil
        }
        return asset
    }
    
    static func shareUrl() -> URL? {
        let asset = ResultViewModel.getLastVideo()
        guard let identifier = asset?.localIdentifier else {
            return nil
        }
        let id = identifier.prefix(36)
        let url = "assets-library://asset/asset.MP4?id=\(id)&ext=MP4"
        print("url : \(url)")
        guard let videoUrl = URL(string: url) else {
            return nil
        }
        
        return videoUrl
    }
}

class TwitterViewModel: NSObject {
    
    static func login() {
        TWTRTwitter.sharedInstance().logIn(completion: { (session, error) in
            if session != nil {
                print("Success Twitter Login")
            } else {
                print("Error Twitter Login")
            }
        })
    }
    
    static func logout() -> String {
        let sessionStore = TWTRTwitter.sharedInstance().sessionStore
        if let session = sessionStore.session() {
            sessionStore.logOutUserID(session.userID)
            guard let str = session.debugDescription else {
                return ""
            }
            return String(describing: str)
        }
        return ""
    }
    
    static func share(url: URL, vc: UIViewController) {
        let composer = TWTRComposerViewController(initialText: "#おしゃべりや", image: nil, videoURL: url)
        vc.present(composer, animated: true, completion: nil)
    }
}

class FacebookViewModel: NSObject {
    
    static func login(vc: UIViewController) {
        let loginManager = FBSDKLoginManager()
        loginManager.logIn(withPublishPermissions: nil, from: vc) { (result, error) in
            if let error = error {
                print("Error Facebook Login : \(error)")
                return
            }
            if let result = result {
                if result.isCancelled {
                    print("Cancell Facebook Login")
                    return
                } else {
                    print("Sucsess Facebook Login")
                    
                }
            }
        }
    }
    
    static func share(url: URL, vc: UIViewController) {
        //ビデオシェア
        let content = FBSDKShareVideoContent()
        guard let video = FBSDKShareVideo(videoURL: url) else {
            return
        }
        content.video = video
        DispatchQueue.main.async {
            FBSDKShareDialog.show(from: vc, with: content, delegate: nil)
        }
    }
}
