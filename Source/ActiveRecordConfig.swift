//
//  ActiveRecordConfig.swift
//  ActiveRecord
//
//  Created by Kenji Tayama on 10/23/14.
//  Copyright (c) 2014 Shintaro Kaneko (http://kaneshinth.com). All rights reserved.
//

import Foundation

public class ActiveRecordConfig {

    /// Singleton instance.
    public class var sharedInstance: ActiveRecordConfig {
        struct Singleton {
            static let instance = ActiveRecordConfig()
        }
        return Singleton.instance
    }
    
    /**
    *  CoreDataStack implementation to use for the app or test.
    */
    public var coreDataStack: CoreDataStack?
}

