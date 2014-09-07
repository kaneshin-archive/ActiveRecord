// ActiveRecord.swift
//
// Copyright (c) 2014 Shintaro Kaneko (http://kaneshinth.com)
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

// MARK: - CoreData driver

public class Driver {
    
    public class var sharedInstance: Driver {
        struct Singleton {
            static let instance = Driver()
        }
        return Singleton.instance
    }
    
    private var storeName: String? = nil
    private var automaticallyDeleteStoreOnMismatch: Bool = true

    lazy var defaultStoreName: String = {
        var defaultName: String? = nil
        if self.storeName != nil && self.storeName != "" {
            defaultName = self.storeName!
        } else {
            defaultName = NSBundle.mainBundle().objectForInfoDictionaryKey(String(kCFBundleNameKey)) as? String
            if defaultName == nil {
                defaultName = "DefaultStore.sqlite"
            }
        }
        if !defaultName!.hasSuffix("sqlite") {
            defaultName = defaultName?.stringByAppendingPathExtension("sqlite")
        }
        return defaultName!
    }()

    public func setup(storeName: String) {
        self.storeName = storeName
    }
    
    // MARK: - CoreData stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls.last as NSURL
    }()
    
    lazy var storeURL: NSURL = {
        return self.applicationDocumentsDirectory.URLByAppendingPathComponent(self.defaultStoreName)
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        return NSManagedObjectModel.mergedModelFromBundles(nil)
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.storeURL
        var error: NSError? = nil
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            if self.automaticallyDeleteStoreOnMismatch {
                NSFileManager.defaultManager().removeItemAtURL(url, error: nil)
                if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
                    coordinator = nil
                }
            }
        }
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - CoreData Saving

    private func save (context: NSManagedObjectContext? = nil) {
        if let moc = (context != nil ? context! : self.managedObjectContext) {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
            }
        }
    }
    
    // MARK: - CRUD
    
    private func create(entityName: String, context: NSManagedObjectContext? = nil) -> AnyObject? {
        if let moc = (context != nil ? context! : self.managedObjectContext) {
            return NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: moc) as AnyObject?
        }
        return nil
    }
    
    private func read(entityName: String, predicate: NSPredicate? = nil, context: NSManagedObjectContext? = nil) -> [AnyObject]? {
        var results: [AnyObject]? = nil
        if let moc = (context != nil ? context! : self.managedObjectContext) {
            var error: NSError? = nil
            var request = NSFetchRequest(entityName: entityName)
            if predicate != nil {
                request.predicate = predicate
            }
            results = moc.executeFetchRequest(request, error: &error)
            if results == nil {
            }
        }
        return results
    }
    
    private func delete(object: NSManagedObject, context: NSManagedObjectContext? = nil) {
        if let moc = (context != nil ? context! : self.managedObjectContext) {
            moc.deleteObject(object)
        }
    }
    
    private func delete(entityName: String, predicate: NSPredicate? = nil, context: NSManagedObjectContext? = nil) {
        if let moc = (context != nil ? context! : self.managedObjectContext) {
            if let objects = read(entityName, predicate: predicate, context: moc) as? [NSManagedObject] {
                for object: NSManagedObject in objects {
                    delete(object)
                }
            }
        }
    }
    
}

// MARK: - Printable

extension Driver: Printable {
    public var description: String {
        let description = "Stored URL: \(self.storeURL)"
        return description
    }
}

// MARK: - Setup

public func setup(storeName: String) {
    Driver.sharedInstance.setup(storeName)
}

public func managedObjectContext() -> NSManagedObjectContext? {
    return Driver.sharedInstance.managedObjectContext
}

// MARK: - Active Record

public func create(entityName: String) -> AnyObject? {
    return Driver.sharedInstance.create(entityName)
}

public func find(entityName: String) -> [AnyObject]? {
    return Driver.sharedInstance.read(entityName)
}

public func find(entityName: String, predicate: NSPredicate? = nil) -> [AnyObject]? {
    return Driver.sharedInstance.read(entityName, predicate: predicate)
}

public func findFirst(entityName: String, predicate: NSPredicate? = nil) -> AnyObject? {
    if let objects = Driver.sharedInstance.read(entityName, predicate: predicate) {
        return objects.first
    }
    return nil
}

public func delete(object: NSManagedObject) {
    Driver.sharedInstance.delete(object, context: object.managedObjectContext)
}

public func delete(entityName: String) {
    Driver.sharedInstance.delete(entityName)
}

public func delete(entityName: String, predicate: NSPredicate? = nil) {
    Driver.sharedInstance.delete(entityName, predicate: predicate)
}

public func save(context: NSManagedObjectContext? = nil) {
    Driver.sharedInstance.save(context: context)
}
