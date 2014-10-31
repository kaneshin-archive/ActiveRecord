//
//  TestCoreDataStack.swift
//  ActiveRecord
//
//  Created by Kenji Tayama on 10/24/14.
//  Copyright (c) 2014 Shintaro Kaneko (http://kaneshinth.com). All rights reserved.
//

import Foundation
import CoreData
import ActiveRecord

class TestCoreDataStack : CoreDataStack {
    
    override init() {
        super.init()
    }

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
    
    /// Main queue context
    override var defaultManagedObjectContext: NSManagedObjectContext? {
        get {
            return self.lazyDefaultManagedObjectContext
        }
        set {}
    }
    
    
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

    /// Context for writing to the PersistentStore
    override var writerManagedObjectContext: NSManagedObjectContext? {
        get {
            return self.lazyWriterManagedObjectContext
        }
        set { }
    }
    
    
    lazy var lazyPersistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        if let managedObjectModel = self.managedObjectModel {
            var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
            var error: NSError? = nil

            if coordinator?.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil, error: &error) == true {
                println("could not add persistent store : \(error?.localizedDescription)")
            }
            return coordinator
        }
        return nil;
    }()
    
    /// PersistentStoreCoordinator
    override var persistentStoreCoordinator: NSPersistentStoreCoordinator? {
        get {
            return self.lazyPersistentStoreCoordinator
        }
        set { }
    }
    
    
    lazy var lazyManagedObjectModel: NSManagedObjectModel? = {
        let testsBundle: NSBundle = NSBundle(forClass: self.dynamicType)
        let modelURL: NSURL? = testsBundle.URLForResource("ActiveRecordTests", withExtension: "momd")
        if let managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL!) {
            return managedObjectModel
        }
        return nil
    }()
    
    /// ManagedObjectModel
    override var managedObjectModel: NSManagedObjectModel? {
        get {
            return self.lazyManagedObjectModel
        }
        set { }
    }
}