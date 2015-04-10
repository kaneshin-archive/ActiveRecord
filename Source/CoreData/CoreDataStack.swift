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

    
    /// true if migration was not necessary on launch or have performed migration
    var migrationNotRequiredConfirmed: Bool = false
    
    /// Main queue context
    public var defaultManagedObjectContext: NSManagedObjectContext? {
        assert(false, "must implement property defaultManagedObjectContext")
        return nil
    }

    /// Context for writing to the PersistentStore
    public var writerManagedObjectContext: NSManagedObjectContext? {
        assert(false, "must implement property writerManagedObjectContext")
        return nil
    }
    
    /// PersistentStoreCoordinator
    public var persistentStoreCoordinator: NSPersistentStoreCoordinator? {
        assert(false, "must implement property persistentStoreCoordinator")
        return nil
    }
    
    /// ManagedObjectModel
    public var managedObjectModel: NSManagedObjectModel? {
        assert(false, "must implement property managedObjectModel")
        return nil
    }

    /// Store URL
    public var storeURL: NSURL? {
        return nil
    }

    /**
    Instantiates the stack (defaultManagedObjectContext, writerManagedObjectContext, persistentStoreCoordinator, managedObjectModel). Typically this will trigger migration when needed.
    */
    func instantiateStack() {
        self.defaultManagedObjectContext
        self.migrationNotRequiredConfirmed = true
    }
    
    /**
    Check if migration is needed.
    
    :returns: true if migration is needed. false if not needed (includes case when persistent store is not found).
    */
    public func isRequiredMigration() -> Bool {
        var error: NSError? = nil

        if let storeURL = self.storeURL {
            // find the persistent store.
            if storeURL.checkResourceIsReachableAndReturnError(&error) == false {
                arprint("Persistent store not found : \(error?.localizedDescription)")
                return false
            }

            // check compatibility
            let sourceMetaData = NSPersistentStoreCoordinator.metadataForPersistentStoreOfType(NSSQLiteStoreType, URL: storeURL, error: &error)
            if let managedObjectModel = self.managedObjectModel {
                let isCompatible: Bool = managedObjectModel.isConfiguration(nil, compatibleWithStoreMetadata: sourceMetaData)
                if isCompatible {
                    self.migrationNotRequiredConfirmed = true
                }
                return !isCompatible
            } else {
                fatalError("Could not get managed object model")
            }
        }
        return false
    }
}


