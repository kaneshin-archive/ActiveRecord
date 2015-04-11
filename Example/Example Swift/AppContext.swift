// AppCoreDataStack.swift
//
// Copyright (c) 2014 Kenji Tayama
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

class AppContext: NSObject, Context {

    private let automaticallyDeleteStoreOnMismatch: Bool = true

    override init() {
        super.init()
    }

    /// Main queue context

    var defaultManagedObjectContext: NSManagedObjectContext? {
        return self.lazyDefaultManagedObjectContext
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

    /// Context for writing to the PersistentStore

    var writerManagedObjectContext: NSManagedObjectContext? {
        return self.lazyWriterManagedObjectContext
    }

    private lazy var lazyWriterManagedObjectContext: NSManagedObjectContext? = {
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        managedObjectContext.mergePolicy = NSOverwriteMergePolicy
        return managedObjectContext
    }()

    /// PersistentStoreCoordinator

    var persistentStoreCoordinator: NSPersistentStoreCoordinator? {
        return self.lazyPersistentStoreCoordinator
    }

    lazy var lazyPersistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        if let managedObjectModel = self.managedObjectModel {
            var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
            var error: NSError? = nil
            if let url = self.storeURL {
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
            }
            return coordinator
        }
        return nil;
    }()
    
    /// ManagedObjectModel

    var managedObjectModel: NSManagedObjectModel? {
        return self.lazyManagedObjectModel
    }

    lazy var lazyManagedObjectModel: NSManagedObjectModel = {
        return NSManagedObjectModel.mergedModelFromBundles(nil)!
    }()

    /// Store URL

    var storeURL: NSURL? {
        return self.lazyStoreURL
    }

    lazy var lazyStoreURL: NSURL = {
        return self.applicationDocumentsDirectory.URLByAppendingPathComponent(self.defaultStoreName)
    }()

    
    /// default store name
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

    /// Application's document directory
    lazy var applicationDocumentsDirectory: NSURL = {
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls.last as! NSURL
    }()
    
    
    
}