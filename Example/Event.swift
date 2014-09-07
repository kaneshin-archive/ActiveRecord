//
//  Event.swift
//  Example
//
//  Created by Shintaro Kaneko on 9/8/14.
//  Copyright (c) 2014 kaneshinth.com. All rights reserved.
//

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
