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
    return Driver.sharedInstance.context()
}

public extension NSManagedObject {
    public class func create(#entityName: String) -> NSManagedObject? {
        return Driver.sharedInstance.create(entityName, context: Driver.sharedInstance.context())
    }
    
    public func save() {
        Driver.sharedInstance.save(self.managedObjectContext)
    }
    
    public func delete() {
        Driver.sharedInstance.delete(self)
    }
    
    public class func find(#entityName: String, predicate: NSPredicate? = nil) -> [AnyObject]? {
        return Driver.sharedInstance.read(entityName, predicate: predicate, context: Driver.sharedInstance.context())
    }
    
    public class func findFirst(#entityName: String, predicate: NSPredicate? = nil) -> AnyObject? {
        if let objects = Driver.sharedInstance.read(entityName, predicate: predicate, context: Driver.sharedInstance.context()) {
            return objects.first
        }
        return nil
    }
    
    public class func count(#entityName: String, predicate: NSPredicate? = nil) -> Int {
        return Driver.sharedInstance.count(entityName, predicate: predicate, context: Driver.sharedInstance.context())
    }
    
}

public extension NSManagedObjectContext {
    public func save() {
        Driver.sharedInstance.save(self)
    }
    
    public class func save() {
        Driver.sharedInstance.save(Driver.sharedInstance.context())
    }
}



