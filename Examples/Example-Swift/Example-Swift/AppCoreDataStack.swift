//
//  AppCoreDataStack.swift
//  Example-Swift
//
//  Created by Kenji Tayama on 10/23/14.
//  Copyright (c) 2014 Shintaro Kaneko (http://kaneshinth.com). All rights reserved.
//

import Foundation
import CoreData
import ActiveRecord

class AppCoreDataStack : CoreDataStack {
    
    override init() {
        super.init()
    }

    /// Main queue context
    private lazy var lazyDefaultManagedObjectContext: NSManagedObjectContext? = {
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.parentContext = self.writerManagedObjectContext
        managedObjectContext.mergePolicy = NSOverwriteMergePolicy
        
        return managedObjectContext
    }()
    
    override var defaultManagedObjectContext: NSManagedObjectContext? {
        get {
            return self.lazyDefaultManagedObjectContext
        }
        set {}
    }
    
    
    /// For Background Thread Context to Save.
    private lazy var lazyWriterManagedObjectContext: NSManagedObjectContext? = {
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        managedObjectContext.mergePolicy = NSOverwriteMergePolicy
        return managedObjectContext
    }()

    override var writerManagedObjectContext: NSManagedObjectContext? {
        get {
            return self.lazyWriterManagedObjectContext
        }
        set { }
    }
    
    /// PersistentStoreCoordinator
    lazy var lazyPersistentStoreCoordinator: NSPersistentStoreCoordinator? = {

        if let managedObjectModel = self.managedObjectModel {
            var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
            let url = self.storeURL
            var error: NSError? = nil
            if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
                if self.automaticallyDeleteStoreOnMismatch {
                    NSFileManager.defaultManager().removeItemAtURL(url, error: nil)
                    if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
                        coordinator = nil
                    }
                } else {
                    coordinator = nil
                }
            }
            return coordinator
        }
        return nil;
    }()
    
    override var persistentStoreCoordinator: NSPersistentStoreCoordinator? {
        get {
            return self.lazyPersistentStoreCoordinator
        }
        set { }
    }
    
    
    /// ManagedObjectModel
    lazy var lazyManagedObjectModel: NSManagedObjectModel = {
        return NSManagedObjectModel.mergedModelFromBundles(nil)!
    }()
    
    override var managedObjectModel: NSManagedObjectModel? {
        get {
            return self.lazyManagedObjectModel
        }
        set { }
    }
    
    /// StoreURL
    lazy var lazyStoreURL: NSURL = {
        return self.applicationDocumentsDirectory.URLByAppendingPathComponent(self.defaultStoreName)
    }()

    override var storeURL: NSURL {
        get {
            return self.lazyStoreURL
        }
        set { }
    }

    
    private let automaticallyDeleteStoreOnMismatch: Bool = true
    
    /// detault store name
    lazy var defaultStoreName: String = {
        var defaultName = NSBundle.mainBundle().objectForInfoDictionaryKey(String(kCFBundleNameKey)) as? String
        if defaultName == nil {
            defaultName = "DefaultStore.sqlite"
        }
        if !(defaultName!.hasSuffix("sqlite")) {
            defaultName = defaultName?.stringByAppendingPathExtension("sqlite")
        }
        return defaultName!
    }()

    /// applicationDocumentsDirectory
    lazy var applicationDocumentsDirectory: NSURL = {
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls.last as NSURL
    }()
    
    
    
}