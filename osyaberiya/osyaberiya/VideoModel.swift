//
//  VideoModel.swift
//  osyaberiya
//
//  Created by koooootake on 2017/12/16.
//  Copyright © 2017年 koooootake. All rights reserved.
//

import Foundation

class VideoModel: NSObject {
    
    static let shared = VideoModel()
    var filePath: String?
    
    private override init() {
        super.init()
    }
    
    func set(filePath: String) {
        self.filePath = filePath
    }
    
    func get() -> String {
        guard let filePath = self.filePath else {
            return ""
        }
        return filePath
    }
}
