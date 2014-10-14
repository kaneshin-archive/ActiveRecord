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

public func context() -> NSManagedObjectContext? {
    return Driver.context()
}

public class ActiveRecord: NSObject {
    public class func context() -> NSManagedObjectContext? {
        return Driver.context()
    }
    /**
    Save
    
    Save context of main queue after save context of current thread.
    
    :returns: Success
    */
    public class func save() -> Bool {
        return Driver.sharedInstance.save(Driver.context())
    }
    
    /**
    Create
    
    :param: entityName
    
    :returns: EntityObject
    */
    public class func create(#entityName: String) -> AnyObject? {
        return Driver.sharedInstance.create(entityName, context: Driver.context())
    }
    
    /**
    Find
    
    :param: entityName
    :param: predicate
    
    :returns: Found Objects
    */
    public class func find(#entityName: String, predicate: NSPredicate? = nil) -> [AnyObject]? {
        return Driver.sharedInstance.read(entityName, predicate: predicate, sortDescriptor: nil, context: Driver.context())
    }
    
    /**
    Find
    
    :param: entityName
    :param: predicate
    :param: sortDescriptor
    
    :returns: Found Objects
    */
    public class func find(#entityName: String, predicate: NSPredicate? = nil, sortDescriptor: NSSortDescriptor? = nil) -> [AnyObject]? {
        return Driver.sharedInstance.read(entityName, predicate: predicate, sortDescriptor: sortDescriptor, context: Driver.context())
    }
    
    /**
    Find first object
    
    :param: entityName
    :param: predicate
    
    :returns: FirstObject of Found Objects
    */
    public class func findFirst(#entityName: String, predicate: NSPredicate? = nil, sortDescriptor: NSSortDescriptor? = nil) -> AnyObject? {
        return Driver.sharedInstance.read(entityName, predicate: predicate, sortDescriptor: sortDescriptor, context: Driver.context())?.first
    }
 
    /**
    Perform and Save (Sync) with ObtainParmanent
    
    :param: block
    */
    public class func performBlockAndWait(#block: (() -> Void)?) {
        Driver.sharedInstance.performBlockAndWait(block: block)
    }

    /**
    Perform and Save (Async) with ObtainParmanent
    
    :param: block
    :param: faiure
    */
    public class func performBlock(#block: (() -> Void)?,success: (() -> Void)?, faiure: ((error: NSError?) -> Void)?) {
        Driver.sharedInstance.performBlock(block: block, success: success, faiure: faiure)
    }
    
    /**
    Delete
    
    :param: object 
    */
    public class func delete(#object: NSManagedObject?) {
        Driver.sharedInstance.delete(object)
    }
}