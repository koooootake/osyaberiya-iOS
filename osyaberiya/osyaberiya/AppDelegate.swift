//
//  AppDelegate.swift
//  osyaberiya
//
//  Created by koooootake on 2017/12/16.
//  Copyright © 2017年 koooootake. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //Fabric
        Fabric.with([Crashlytics.self])
        
        //Facebook
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        //Twitter
        guard
            let filePath = Bundle.main.path(forResource: "Info.plist", ofType: nil),
            let infoDic = NSMutableDictionary(contentsOfFile: filePath),
            let twKey = infoDic["TwitterKey"] as? String,
            let twSecret = infoDic["TwitterSecret"] as? String else {
                return true
        }
        TWTRTwitter.sharedInstance().start(withConsumerKey: twKey, consumerSecret: twSecret)
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if TWTRTwitter.sharedInstance().application(app, open:url, options: options) {
            return true
        }
        
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: sourceApplication, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
    
}

