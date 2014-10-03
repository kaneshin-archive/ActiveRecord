// Driver.swift
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

class Driver: NSObject {
    
    class var sharedInstance: Driver {
        struct Singleton {
            static let instance = Driver()
        }
        return Singleton.instance
    }
    
    class func defaultContext() -> NSManagedObjectContext {
        var context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = Driver.sharedInstance.persistentStoreCoordinator
        return context
    }
    
    class func context() -> NSManagedObjectContext {
        var context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        context.parentContext = Driver.defaultContext()
        return context
    }
    
    // MARK: -
    
    private var automaticallyDeleteStoreOnMismatch: Bool = true
    
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

    
    lazy var applicationDocumentsDirectory: NSURL = {
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
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
            } else {
                coordinator = nil
            }
        }
        return coordinator
    }()
    
    lazy var defaultManagedObjectContext: NSManagedObjectContext? = {
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - CRUD
    
    func create(entityName: String, context: NSManagedObjectContext? = nil) -> AnyObject? {
        if let moc = (context ?? self.defaultManagedObjectContext) {
            return NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: moc) as AnyObject?
        }
        return nil
    }
    
    func read(entityName: String, predicate: NSPredicate? = nil, context: NSManagedObjectContext? = nil) -> [AnyObject]? {
        var results: [AnyObject]? = nil
        if let moc = (context ?? self.defaultManagedObjectContext) {
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
    
    func save(context: NSManagedObjectContext? = nil) -> NSError? {
        if let moc = (context ?? self.defaultManagedObjectContext) {
            if moc.hasChanges {
                moc.performBlock({ () -> Void in
                    var error: NSError? = nil
                    if !moc.save(&error) {
                        // return error
                    }
                    if let parent = moc.parentContext {
                        parent.performBlock({ () -> Void in
                            if !moc.save(&error) {
                            }
                        })
                    }
                })
            }
        }
        return nil
    }
    
    func delete(object: NSManagedObject) {
        if let moc = object.managedObjectContext {
            moc.deleteObject(object)
        }
    }
    
    func delete(entityName: String, predicate: NSPredicate? = nil, context: NSManagedObjectContext? = nil) {
        if let moc = (context ?? self.defaultManagedObjectContext) {
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
    override var description: String {
        let description = "Stored URL: \(self.storeURL)"
        return description
    }
}

