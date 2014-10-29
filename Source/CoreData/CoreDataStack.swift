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
    public var storeURL: NSURL? {
        get {
            return nil
        }
        set {}
    }
    
    /**
    Check if migration is needed.
    
    :returns: true if migration is needed. false if not needed (includes case when persistent store is not found).
    */
    public func isRequiredMigration() -> Bool {
        var error: NSError? = nil

        if let storeURL = self.storeURL {
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
        return false
    }
}


