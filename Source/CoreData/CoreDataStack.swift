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

    /// Main queue context
    public var defaultManagedObjectContext: NSManagedObjectContext? {
        get {
            assert(false, "must implement property defaultManagedObjectContext")
            return nil
        }
        set {}
    }

    /// Context for writing to the PersistentStore
    public var writerManagedObjectContext: NSManagedObjectContext? {
        get {
            assert(false, "must implement property writerManagedObjectContext")
            return nil
        }
        set {}
    }
    
    /// PersistentStoreCoordinator
    public var persistentStoreCoordinator: NSPersistentStoreCoordinator? {
        get {
            assert(false, "must implement property persistentStoreCoordinator")
            return nil
        }
    }
    
    /// ManagedObjectModel
    public var managedObjectModel: NSManagedObjectModel? {
        get {
            assert(false, "must implement property managedObjectModel")
            return nil
        }
        set {}
    }

    /// Store URL
    public var storeURL: NSURL {
        get {
            return NSURL()
        }
        set {}
    }

    /**
    Returns a NSManagedObjectContext associated to currennt thread.
    Creates a new one if there aren't any yet.
    
    :returns: A managed object context associated to current thread.
    */
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
    

    /**
    Check if migration is needed.
    
    :returns: true if migration is needed. false if not needed (includes case when persistent store is not found).
    */
    public func isRequiredMigration() -> Bool {
        var error: NSError? = nil
        let storeURL = self.storeURL

        // find the persistent store.
        if storeURL.checkResourceIsReachableAndReturnError(&error) {
            println("Persistent store not found : \(error?.localizedDescription)")
            return false
        }
        
        // check compatibility
        let sourceMetaData = NSPersistentStoreCoordinator.metadataForPersistentStoreOfType(NSSQLiteStoreType, URL: storeURL, error: &error)
        if let managedObjectModel = self.managedObjectModel {
            let isCompatible: Bool = managedObjectModel.isConfiguration(nil, compatibleWithStoreMetadata: sourceMetaData)
            return isCompatible
        } else {
            fatalError("Could not get managed object model")
        }
    }
}


