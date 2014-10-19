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

/**
*  http://www.cocoanetics.com/2012/07/multi-context-coredata/
*/


import Foundation
import CoreData

class Driver: NSObject {
    
    class var sharedInstance: Driver {
        struct Singleton {
            static let instance = Driver()
        }
        return Singleton.instance
    }
    
    let kMaxConcurrentOperationCount = 1
    var performOperationQueue: PerformOperationQueue
    
    override init() {
        self.performOperationQueue = PerformOperationQueue()
        self.performOperationQueue.maxConcurrentOperationCount = kMaxConcurrentOperationCount
        super.init()
    }
    
    /// Main queue context
    lazy var defaultManagedObjectContext: NSManagedObjectContext? = {
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.parentContext = self.writerManagedObjectContext
        managedObjectContext.mergePolicy = NSOverwriteMergePolicy

        return managedObjectContext
    }()
    
    /// For Background Thread Context to Save.
    private lazy var writerManagedObjectContext: NSManagedObjectContext? = {
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        managedObjectContext.mergePolicy = NSOverwriteMergePolicy
        return managedObjectContext
    }()
    
    /**
    Get current thread context
    
    :returns: Current thread context
    */
    func context() -> NSManagedObjectContext? {
        if NSThread.isMainThread() {
            return Driver.sharedInstance.defaultManagedObjectContext
        } else {
            let kNSManagedObjectContextThreadKey = "kNSManagedObjectContextThreadKey"
            let threadDictionary = NSThread.currentThread().threadDictionary
            if let context = threadDictionary?[kNSManagedObjectContextThreadKey] as? NSManagedObjectContext {
                return context
            } else {
                let context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
                context.parentContext = Driver.sharedInstance.defaultManagedObjectContext
                context.mergePolicy = NSOverwriteMergePolicy
                threadDictionary?.setObject(context, forKey: kNSManagedObjectContextThreadKey)
                return context
            }
        }
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

    ///
    lazy var applicationDocumentsDirectory: NSURL = {
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls.last as NSURL
    }()
    
    /// StoreURL
    lazy var storeURL: NSURL = {
        return self.applicationDocumentsDirectory.URLByAppendingPathComponent(self.defaultStoreName)
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        return NSManagedObjectModel.mergedModelFromBundles(nil)!
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
    
    // MARK: - CRUD
    
    /**
    Create Entity
    
    :param: entityName
    :param: context
    
    :returns:
    */
    func create(entityName: String, context: NSManagedObjectContext?) -> NSManagedObject? {
        if let context = context {
            return NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: context) as? NSManagedObject
        } else {
            return nil
        }
    }
    
    /**
    Read Entity
    
    :param: entityName
    :param: predicate
    :param: sortDescriptor
    :param: context
    
    :returns:
    */
    func read(entityName: String, predicate: NSPredicate? = nil, sortDescriptor: NSSortDescriptor? = nil, context: NSManagedObjectContext?) -> [AnyObject]? {
        if let context = context {
            var results: [AnyObject]? = nil
            var error: NSError? = nil
            var request = NSFetchRequest(entityName: entityName)
            if predicate != nil {
                request.predicate = predicate
            }
            if sortDescriptor != nil {
                request.predicate = predicate
            }
            results = context.executeFetchRequest(request, error: &error)
            if results == nil {
            }
            return results
        } else {
            return nil
        }
    }
    
    /**
    Count Entities
    
    :param: entityName
    :param: predicate
    :param: context
    
    :returns:
    */
    func count(entityName: String, predicate: NSPredicate? = nil,context: NSManagedObjectContext?) -> Int {
        if let context = context {
            var results: [AnyObject]? = nil
            var error: NSError? = nil
            var request = NSFetchRequest(entityName: entityName)
            if predicate != nil {
                request.predicate = predicate
            }
            return context.countForFetchRequest(request, error: &error)
        } else {
            return 0
        }
    }
    
    /**
    Save for PSC
    
    :param: context
    */
    func recursiveSave(context: NSManagedObjectContext?) {
        if let parentContext = context?.parentContext {
            var error: NSError? = nil
            parentContext.performBlock({ () -> Void in
                if parentContext.save(&error) {
                    if parentContext == self.defaultManagedObjectContext {
                        println("Merge to MainQueueContext")
                    } else if parentContext == self.writerManagedObjectContext {
                        println("Data stored")
                    } else {
                        println("Recursive save \(parentContext)")
                    }
                    self.recursiveSave(parentContext)
                }
            })
        }
    }
    
    func save(context: NSManagedObjectContext?) -> Bool {
        if let context = context {
            if context.hasChanges {
                var error: NSError? = nil
                context.performBlockAndWait({ () -> Void in
                    if context.save(&error) {
                        self.recursiveSave(context)
                    }
                })
                if error != nil {
                    println("Save failed : \(error)")
                    return false
                } else {
                    println("Save Success")
                    return true
                }
            } else {
                println("Save Success")
                return true
            }
        } else {
            println("Save failed : context is nil")
            return false
        }
    }

    func delete(object: NSManagedObject?) {
        if let object = object {
            if let context = object.managedObjectContext {
                context.deleteObject(object)
            }
        }
    }
    
    func delete(#entityName: String, predicate: NSPredicate? = nil, context: NSManagedObjectContext) {
        if let objects = read(entityName, predicate: predicate, context: context) as? [NSManagedObject] {
            for object: NSManagedObject in objects {
                delete(object)
            }
        }
    }
    
    func performBlockAndWait(#block: (Void -> Void)?) {
        if let block = block {
            Driver.sharedInstance.context()?.performBlockAndWait(block)
        }
    }
    
    func performBlock(#block: (() -> Void)?, success: (() -> Void)?, faiure: ((error: NSError?) -> Void)?) {
        self.performBlockWaitSave(block: { (doSave) -> Void in
            block?()
            doSave()
        }, success: success, faiure: faiure)
    }
    
    func performBlockWaitSave(#block: ((doSave: (() -> Void)) -> Void)?, success: (() -> Void)?, faiure: ((error: NSError?) -> Void)?) {
        if let block = block {
            let operation = PerformOperation { () -> Void in
                self.context()?.performBlock({ () -> Void in
                    block(doSave: { () -> Void in
                        var objects: [AnyObject] = [AnyObject]()
                        let _objects: NSMutableSet = NSMutableSet()
                        
                        if let localContext = self.context() {
                            _objects.addObjectsFromArray(localContext.insertedObjects.allObjects)
                            _objects.addObjectsFromArray(localContext.updatedObjects.allObjects)
                            _objects.addObjectsFromArray(localContext.deletedObjects.allObjects)
                            _objects.addObjectsFromArray(localContext.registeredObjects.allObjects)
                            objects = _objects.allObjects
                            
                            var error: NSError?
                            
                            if localContext.obtainPermanentIDsForObjects(objects, error: &error) {
                                if error != nil {
                                    dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                                        faiure?(error: error)
                                        return
                                    })
                                } else {
                                    if self.save(localContext) {
                                        dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                                            success?()
                                            return
                                        })
                                    }
                                }
                            } else {
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    faiure?(error: error)
                                    return
                                })
                            }
                        }
                    })
                })
                return
            }
            self.performOperationQueue.addOperation(operation)
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

class PerformOperationQueue: NSOperationQueue {
    override func addOperation(op: NSOperation) {
        println("Add Operation")
        if let lastOperation = self.operations.last as? NSOperation {
            op.addDependency(lastOperation)
        }
        super.addOperation(op)
    }
}

class PerformOperation: NSBlockOperation {
    
}
