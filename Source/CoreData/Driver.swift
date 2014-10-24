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
    
    var coreDataStack : CoreDataStack
    
    let kMaxConcurrentOperationCount = 1
    var driverOperationQueue: DriverOperationQueue
    
    init(coreDataStack: CoreDataStack) {
        self.driverOperationQueue = DriverOperationQueue()
        self.driverOperationQueue.maxConcurrentOperationCount = kMaxConcurrentOperationCount
        self.coreDataStack = coreDataStack
    }
    
    
    
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
    
    :returns: array of managed objects. nil if an error occurred.
    */
    func read(entityName: String, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, offset: Int = 0, limit: Int = 0, context: NSManagedObjectContext?, error: NSErrorPointer) -> [AnyObject]? {
        if let context = context {
            var results: [AnyObject]? = nil
            var request = NSFetchRequest(entityName: entityName)
            if predicate != nil {
                request.predicate = predicate
            }
            if sortDescriptors != nil {
                request.sortDescriptors = sortDescriptors
            }
            if offset > 0 {
                request.fetchOffset = offset
            }
            if limit > 0 {
                request.fetchLimit = limit
            }
            return context.executeFetchRequest(request, error: error)
        } else {
            return nil
        }
    }
    
    /**
    Read Entity with fetchRequest
    
    :param: fetchRequest
    :param: context
    :param: error
    
    :returns: array of managed objects. nil if an error occurred.
    */
    func read(fetchRequest: NSFetchRequest, context: NSManagedObjectContext? = nil, error: NSErrorPointer) -> [AnyObject]? {
        let ctx = context != nil ? context : self.coreDataStack.context()
        var results: [AnyObject]? = nil

        if let ctx = ctx {
            return ctx.executeFetchRequest(fetchRequest, error: error)
        }
        return nil
    }
    
    /**
    Count Entities
    
    :param: entityName
    :param: predicate
    :param: context
    
    :returns:
    */
    func count(entityName: String, predicate: NSPredicate? = nil, context: NSManagedObjectContext?, error: NSErrorPointer) -> Int {
        if let context = context {
            var request = NSFetchRequest(entityName: entityName)
            if predicate != nil {
                request.predicate = predicate
            }
            return context.countForFetchRequest(request, error: error)
        } else {
            return 0
        }
    }
    
    /**
    Save for PSC
    
    :param: context
    */
    func recursiveSave(context: NSManagedObjectContext?, error: NSErrorPointer) {
        if let parentContext = context?.parentContext {
            parentContext.performBlock({ () -> Void in
                if parentContext.save(error) {
                    if parentContext == self.coreDataStack.defaultManagedObjectContext {
                        println("Merge to MainQueueContext")
                    } else if parentContext == self.coreDataStack.writerManagedObjectContext {
                        println("Data stored")
                    } else {
                        println("Recursive save \(parentContext)")
                    }
                    self.recursiveSave(parentContext, error: error)
                }
            })
        }
    }
    
    func save(context: NSManagedObjectContext?, error: NSErrorPointer) -> Bool {
        if let context = context {
            if context.hasChanges {
                context.performBlockAndWait({ () -> Void in
                    if context.save(error) {
                        self.recursiveSave(context, error: error)
                    }
                })
                if error.memory != nil {
                    println("Save failed : \(error.memory?.localizedDescription)")
                    return false
                } else {
                    println("Save Success")
                    return true
                }
            } else {
                println("Save Success (No changes)")
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
    
    func delete(#entityName: String, predicate: NSPredicate? = nil, context: NSManagedObjectContext, error: NSErrorPointer) {
        if let objects = read(entityName, predicate: predicate, context: context, error: error) as? [NSManagedObject] {
            for object: NSManagedObject in objects {
                delete(object)
            }
        }
    }
    
    func performBlockAndWait(#block: (Void -> Void)?) {
        if let block = block {
            self.coreDataStack.context()?.performBlockAndWait(block)
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
            let operation = DriverOperation { () -> Void in
                self.coreDataStack.context()?.performBlock({ () -> Void in
                    block(doSave: { () -> Void in
                        var objects: [AnyObject] = [AnyObject]()
                        let _objects: NSMutableSet = NSMutableSet()
                        
                        if let localContext = self.coreDataStack.context() {
                            _objects.addObjectsFromArray(localContext.insertedObjects.allObjects)
                            _objects.addObjectsFromArray(localContext.updatedObjects.allObjects)
                            _objects.addObjectsFromArray(localContext.deletedObjects.allObjects)
                            _objects.addObjectsFromArray(localContext.registeredObjects.allObjects)
                            objects = _objects.allObjects
                            
                            var error: NSError? = nil
                            
                            if localContext.obtainPermanentIDsForObjects(objects, error: &error) {
                                if error != nil {
                                    dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                                        faiure?(error: error)
                                        return
                                    })
                                } else {
                                    if self.save(localContext, error: &error) {
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
            self.driverOperationQueue.addOperation(operation)
        }

    }
}

// MARK: - Printable

extension Driver: Printable {
    override public var description: String {
        let description = "Stored URL: \(self.coreDataStack.storeURL)"
        return description
    }
}

class DriverOperationQueue: NSOperationQueue {
    override func addOperation(op: NSOperation) {
        println("Add Operation")
        if let lastOperation = self.operations.last as? NSOperation {
            op.addDependency(lastOperation)
        }
        super.addOperation(op)
    }
}

class DriverOperation: NSBlockOperation {
    
}
