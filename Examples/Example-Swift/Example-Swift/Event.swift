//
//  Event.swift
//  Example-Swift
//
//  Created by Shintaro Kaneko on 9/23/14.
//  Copyright (c) 2014 Shintaro Kaneko (http://kaneshinth.com). All rights reserved.
//

import Foundation
import CoreData

class Event: NSManagedObject {

    @NSManaged var timeStamp: NSDate

    class func entityName() -> String {
        var entityName = NSStringFromClass(self)
        if let elements = entityName.componentsSeparatedByString(".") as [String]? {
            return elements.last!
        }
        return entityName
    }
    
}
