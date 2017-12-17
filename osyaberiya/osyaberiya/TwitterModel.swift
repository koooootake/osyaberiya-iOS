//
//  TwitterModel.swift
//  osyaberiya
//
//  Created by koooootake on 2017/12/17.
//  Copyright © 2017年 koooootake. All rights reserved.
//

import Foundation

class TwitterModel: NSObject {
    
    static func login() {
        TWTRTwitter.sharedInstance().logIn(completion: { (session, error) in
            if session != nil {
                print("Success Twitter: ");
            } else {
                print("Error Twitter: ");
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
}
