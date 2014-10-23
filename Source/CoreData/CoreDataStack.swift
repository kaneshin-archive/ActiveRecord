//
//  CoreDataStack.swift
//  ActiveRecord
//
//  Created by Kenji Tayama on 10/23/14.
//  Copyright (c) 2014 Shintaro Kaneko (http://kaneshinth.com). All rights reserved.
//

import Foundation
import CoreData

public class CoreDataStack: NSObject {

    public override init() {
        super.init()
    }
    
    public var defaultManagedObjectContext: NSManagedObjectContext? {
        get {
            assert(false, "must implement property defaultManagedObjectContext")
            return nil
        }
        set {}
    }

    public var writerManagedObjectContext: NSManagedObjectContext? {
        get {
            assert(false, "must implement property writerManagedObjectContext")
            return nil
        }
        set {}
    }
    
    public var persistentStoreCoordinator: NSPersistentStoreCoordinator? {
        get {
            assert(false, "must implement property persistentStoreCoordinator")
            return nil
        }
    }
    
    public var managedObjectModel: NSManagedObjectModel? {
        get {
            assert(false, "must implement property managedObjectModel")
            return nil
        }
        set {}
    }

    public var storeURL: NSURL {
        get {
            assert(false, "must implement property storeURL")
            return NSURL()
        }
        set {}
    }

    func context() -> NSManagedObjectContext? {
        if NSThread.isMainThread() {
            return self.defaultManagedObjectContext
        } else {
            let kNSManagedObjectContextThreadKey = "kNSManagedObjectContextThreadKey"
            let threadDictionary = NSThread.currentThread().threadDictionary
            if let context = threadDictionary?[kNSManagedObjectContextThreadKey] as? NSManagedObjectContext {
                return context
            } else {
                let context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
                context.parentContext = self.defaultManagedObjectContext
                context.mergePolicy = NSOverwriteMergePolicy
                threadDictionary?.setObject(context, forKey: kNSManagedObjectContextThreadKey)
                return context
            }
        }
    }
    
    
}


