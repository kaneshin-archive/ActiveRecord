// TestCoreDataStack.swift
//
// Copyright (c) 2015 Shintaro Kaneko
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