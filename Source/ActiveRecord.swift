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

// MARK: - Setup

public class ActiveRecord: NSObject {
    
    
    class var driver: Driver? {
        if let coreDataStack = ActiveRecordConfig.sharedInstance.coreDataStack {
        let driver = Driver(coreDataStack: coreDataStack)
            return driver
        } else {
            return nil
        }
    }
    
    /**
    For perform in background queue (Don't do asynchronous processing in block)
    
    :param: block
    :param: faiure
    */
    public class func performBackgroundBlock(#block: (() -> Void)?, success: (() -> Void)?, faiure: ((error: NSError?) -> Void)?) {
        if let driver = self.driver {
            driver.driverOperationQueue.addOperationWithBlock { () -> Void in
                driver.performBlock(block: block, success: success, faiure: faiure)
            }
        }
    }
    
    /**
    For peform in background queue : Manually call timing of save.(Directed to asynchronous processing in block)
   
    :param: block
    :param: faiure
    */
    public class func performBackgroundBlockWaitSave(#block: ((doSave: (() -> Void)) -> Void)?, success: (() -> Void)?, faiure: ((error: NSError?) -> Void)?) {
        if let driver = self.driver {
            driver.driverOperationQueue.addOperationWithBlock { () -> Void in
                driver.performBlockWaitSave(block: block, success: success, faiure: faiure)
            }
        }
    }

    /**
    For perform in background queue
    
    :param: block
    :param: faiure
    */
    public class func performBackgroundBlockAndWait(#block: (Void -> Void)?) {
        if let driver = self.driver {
            driver.driverOperationQueue.addOperationWithBlock { () -> Void in
                driver.performBlockAndWait(block: block)
            }
        }
    }
}


public extension NSManagedObject {
    
    public class func create(#entityName: String) -> NSManagedObject? {
        return ActiveRecord.driver?.create(entityName, context: ActiveRecord.driver?.coreDataStack.context())
    }
    
    public func save() {
        ActiveRecord.driver?.save(self.managedObjectContext)
    }
    
    public func delete() {
        ActiveRecord.driver?.delete(self)
    }
    
    public class func find(#entityName: String, predicate: NSPredicate? = nil) -> [AnyObject]? {
        return ActiveRecord.driver?.read(entityName, predicate: predicate, context: ActiveRecord.driver?.coreDataStack.context())
    }
    
    public class func findFirst(#entityName: String, predicate: NSPredicate? = nil) -> AnyObject? {
        if let objects = ActiveRecord.driver?.read(entityName, predicate: predicate, context: ActiveRecord.driver?.coreDataStack.context()) {
            return objects.first
        }
        return nil
    }
    
    public class func count(#entityName: String, predicate: NSPredicate? = nil) -> Int {
        if let driver = ActiveRecord.driver {
            return driver.count(entityName, predicate: predicate, context: ActiveRecord.driver?.coreDataStack.context())
        } else {
            return 0;
        }
    }
    
}

public extension NSManagedObjectContext {
    public func save() {
        ActiveRecord.driver?.save(self)
    }
    
    public class func save() {
        ActiveRecord.driver?.save(ActiveRecord.driver?.coreDataStack.context())
    }
    
    public class func context() -> NSManagedObjectContext? {
        return ActiveRecord.driver?.coreDataStack.context()
    }
}



