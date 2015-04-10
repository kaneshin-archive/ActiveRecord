// CoreDataStack.swift
//
// Copyright (c) 2014 Shintaro Kaneko
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

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
                Debug.print("Persistent store not found : \(error?.localizedDescription)")
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


