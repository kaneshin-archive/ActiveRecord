//
//  AppDelegate.swift
//  Example
//
//  Created by Shintaro Kaneko on 9/8/14.
//  Copyright (c) 2014 kaneshinth.com. All rights reserved.
//

import UIKit
import ActiveRecord

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }

    func applicationWillTerminate(application: UIApplication) {
        ActiveRecord.save()
    }

}

