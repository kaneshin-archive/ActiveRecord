// Event.swift
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
import ActiveRecord

class Event: NSManagedObject {

    @NSManaged var timeStamp: NSDate

}

extension Event {
    
    class func entityName() -> String {
        var entityName = NSStringFromClass(self)
        if let elements = entityName.componentsSeparatedByString(".") as [String]? {
            return elements.last!
        }
        return entityName
    }
    
    class func create() -> AnyObject? {
        return ActiveRecord.create(self.entityName())
    }
    
    class func find(attribute: String, value: AnyObject) -> [AnyObject]? {
        let predicate = NSPredicate(format: "\(attribute) == %@", argumentArray: [value])
        return ActiveRecord.find(self.entityName(), predicate: predicate)
    }
    
    class func findFirst(attribute: String, value: AnyObject) -> AnyObject? {
        let predicate = NSPredicate(format: "\(attribute) == %@", argumentArray: [value])
        return ActiveRecord.findFirst(self.entityName(), predicate: predicate)
    }
    
    func delete() {
        ActiveRecord.delete(self)
    }
    
    func save() {
        ActiveRecord.save(context: self.managedObjectContext)
    }
    

}
