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
        self.coreDataStack = coreDataStack
        self.driverOperationQueue = DriverOperationQueue(parentContext: coreDataStack.defaultManagedObjectContext)
        self.driverOperationQueue.maxConcurrentOperationCount = kMaxConcurrentOperationCount
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
    func read(entityName: String, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, offset: Int? = 0, limit: Int? = 0, context: NSManagedObjectContext?, error: NSErrorPointer) -> [NSManagedObject]? {
        if let context = context {
            var results: [AnyObject]? = nil
            var request = NSFetchRequest(entityName: entityName)
            if predicate != nil {
                request.predicate = predicate
            }
            if sortDescriptors != nil {
                request.sortDescriptors = sortDescriptors
            }
            if let offset = offset {
                if offset > 0 {
                    request.fetchOffset = offset
                }
            }
            if let limit = limit {
                if limit > 0 {
                    request.fetchLimit = limit
                }
            }
            return context.executeFetchRequest(request, error: error) as [NSManagedObject]?
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
    func read(fetchRequest: NSFetchRequest, context: NSManagedObjectContext? = nil, error: NSErrorPointer) -> [NSManagedObject]? {
        let ctx = context != nil ? context : self.context()
        var results: [AnyObject]? = nil

        if let ctx = ctx {
            return ctx.executeFetchRequest(fetchRequest, error: error) as [NSManagedObject]?
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
    
    /**
    Recursively save parent contexts
    
    :param: context Context to retrieve parents from.
    :param: error
    */
    private func recursiveSave(context: NSManagedObjectContext?, error: NSErrorPointer) {
        if let parentContext = context?.parentContext {
            if (parentContext == self.coreDataStack.writerManagedObjectContext) {
                parentContext.performBlock({ () -> Void in
                    if parentContext.save(error) {
                        if parentContext == self.coreDataStack.writerManagedObjectContext {
                            println("Data stored")
                        }
                        self.recursiveSave(parentContext, error: error)
                    }
                })
            } else {
                parentContext.performBlockAndWait({ () -> Void in
                    if parentContext.save(error) {
                        if parentContext == self.coreDataStack.defaultManagedObjectContext {
                            println("Merge to MainQueueContext")
                        } else {
                            println("Recursive save \(parentContext)")
                        }
                        
                        self.recursiveSave(parentContext, error: error)
                    }
                })
            }
        }
    }
    
    /**
    Save context and recursively save all parent contexts
    
    :param: context
    :param: error
    
    :returns: true if success
    */
    func save(context: NSManagedObjectContext?, error: NSErrorPointer) -> Bool {
        if error == nil {
            var err: NSError? = nil
            return self.save(context, error: &err)
        }
                
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

    /**
    Delete a managed object
    
    :param: object managed object
    */
    func delete(#object: NSManagedObject?) {
        if let object = object {
            if let context = object.managedObjectContext {
                context.deleteObject(object)
            }
        }
    }
    
    /**
    Delete all managed objects using predicate
    
    :param: entityName
    :param: predicate
    :param: context
    :param: error
    */
    func delete(#entityName: String, predicate: NSPredicate? = nil, context: NSManagedObjectContext, error: NSErrorPointer) {
        if let objects = read(entityName, predicate: predicate, context: context, error: error) {
            for object: NSManagedObject in objects {
                delete(object: object)
            }
        }
    }
    
    /**
    Peform block in background queue and save
    
    :param: block
    :param: saveSuccess
    :param: saveFailure
    :param: waitUntilFinished
    */
    func saveWithBlock(#block: (() -> Void)?, saveSuccess: (() -> Void)?, saveFailure: ((error: NSError?) -> Void)?, waitUntilFinished:Bool = false) {
        self.saveWithBlockWaitSave(block: { (save) -> Void in
            block?()
            save()
        }, saveSuccess: saveSuccess, saveFailure: saveFailure, waitUntilFinished: waitUntilFinished)
    }
    
    /**
    Perform block in background queue and save and wait till done.
    
    :param: block
    :param: error error pointer
    
    :returns: true if success
    */
    func saveWithBlockAndWait(#block: (() -> Void)?, error: NSErrorPointer) -> Bool {
        var result: Bool = true
        var _error = error
        self.saveWithBlock(block: block, saveSuccess: { () -> Void in
        }, saveFailure: { (error) -> Void in
            result = false
            _error.memory = error
        }, waitUntilFinished: true)
        return result
    }
    
    /**
    Perform in background queue and save (Manually call timing of save.)
    
    :param: block             Block to perform. Call save() to invoke save.
    :param: saveSuccess
    :param: saveFailure
    :param: waitUntilFinished
    */
    func saveWithBlockWaitSave(#block: ((save: (() -> Void)) -> Void)?, saveSuccess: (() -> Void)?, saveFailure: ((error: NSError?) -> Void)?, waitUntilFinished:Bool = false) {
        if let block = block {
            let operation = DriverOperation { () -> Void in
                var localContext = self.driverOperationQueue.context
                block(save: { () -> Void in
                    var error: NSError? = nil
                    if localContext.obtainPermanentIDsForObjects(localContext.insertedObjects.allObjects, error: &error) {
                        if error != nil {
                            dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                                saveFailure?(error: error)
                                return
                            })
                        } else {
                            if self.save(localContext, error: &error) {
                                dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                                    saveSuccess?()
                                    return
                                })
                            }
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            saveFailure?(error: error)
                            return
                        })
                    }
                })
                return
            }
            
            if waitUntilFinished {
                self.driverOperationQueue.addOperations([operation], waitUntilFinished: true)
            } else {
                self.driverOperationQueue.addOperation(operation)
            }
        }
    }
    
    /**
    Peform block in background queue and save
    
    :param: block
    :param: waitUntilFinished
    */
    func performBlock(#block: (() -> Void)?, completion: (() -> Void)?, waitUntilFinished: Bool = false) {
        if let block = block {
            let operation = DriverOperation { () -> Void in
                block()
                if let completion = completion {
                    dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                        completion()
                    })
                }
                return
            }
            
            if waitUntilFinished {
                self.driverOperationQueue.addOperations([operation], waitUntilFinished: true)
            } else {
                self.driverOperationQueue.addOperation(operation)
            }
        }
    }
    
    /**
    
    Returns a NSManagedObjectContext associated to currennt operation queue.
    Operation queues should be a Main Queue or a DriverOperationQueue
    
    :returns: A managed object context associated to current operation queue.
    */
    func context() -> NSManagedObjectContext? {
        if let queue = NSOperationQueue.currentQueue() {
            if queue == NSOperationQueue.mainQueue() {
                return self.coreDataStack.defaultManagedObjectContext
            } else if queue.isKindOfClass(DriverOperationQueue) {
                return self.driverOperationQueue.context
            }
        }
        
        // temporarily use "context for current thread"
        // context associated to thread
        if NSThread.isMainThread() {
            return self.coreDataStack.defaultManagedObjectContext
        } else {
            let kNSManagedObjectContextThreadKey = "kNSManagedObjectContextThreadKey"
            let threadDictionary = NSThread.currentThread().threadDictionary
            if let context = threadDictionary?[kNSManagedObjectContextThreadKey] as? NSManagedObjectContext {
                return context
            } else {
                let context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
                context.parentContext = self.coreDataStack.defaultManagedObjectContext
                context.mergePolicy = NSOverwriteMergePolicy
                threadDictionary?.setObject(context, forKey: kNSManagedObjectContextThreadKey)
                return context
            }
        }
        

// temporarily comment out assert
//        assert(false, "Managed object context not found. Managed object contexts should be created in an DriverOperationQueue.")
//        return nil
    }
    
    /**
    
    Returns the default Managed Object Context for use in Main Thread.
    
    :returns: The default Managed Object Context
    */
    func mainContext() -> NSManagedObjectContext? {
        return self.coreDataStack.defaultManagedObjectContext
    }
}
    

// MARK: - Printable

extension Driver: Printable {
    override var description: String {
        let description = "Stored URL: \(self.coreDataStack.storeURL)"
        return description
    }
}

/**
*  Operation Queue to use when performing blocks in background
*/
class DriverOperationQueue: NSOperationQueue {
    
    /// Managed Object Context associated to this Operation Queue
    var context: NSManagedObjectContext
    
    /**
    Initialize with parent Managed Object Context. It will be the parent of the context which will be associated to this Operation Queue.
    
    :param: parentContext The parent of the context which will be associated to this Operation Queue.
    
    :returns:
    */
    init(parentContext: NSManagedObjectContext?) {
        let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        context.parentContext = parentContext
        context.mergePolicy = NSOverwriteMergePolicy
        self.context = context
        super.init()
    }
    
    /**
    Add an Operaion to this Operaion Queue. Operations will run in serial.
    
    :param: op Operation
    */
    override func addOperation(op: NSOperation) {
        println("Add Operation")
        if let lastOperation = self.operations.last as? NSOperation {
            op.addDependency(lastOperation)
        }
        super.addOperation(op)
    }
}

/**
*  Operation to use with DriverOperationQueue
*/
class DriverOperation: NSBlockOperation {
    
}
