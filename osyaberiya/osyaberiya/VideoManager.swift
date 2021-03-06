//
//  VideoModel.swift
//  osyaberiya
//
//  Created by koooootake on 2017/12/16.
//  Copyright © 2017年 koooootake. All rights reserved.
//

import Foundation

class VideoManager: NSObject {
    
    static let shared = VideoManager()
    var fileName: String?
    var filePath: String?
    
    private override init() {
        super.init()
    }
    
    func set(fileName:String, filePath: String) {
        self.fileName = fileName
        self.filePath = filePath
    }
    
    func getFileURL() -> URL? {
        guard let filePath = self.filePath else {
            return nil
        }
        let url = URL(fileURLWithPath: filePath)
        return url
    }
    
    func getURL() -> URL? {
        guard
            let filePath = self.filePath,
            let url = URL(string: filePath) else {
            return nil
        }
        return url
    }
}
