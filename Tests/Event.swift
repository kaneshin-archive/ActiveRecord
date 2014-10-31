//
//  Event.swift
//  ActiveRecord
//
//  Created by Kenji Tayama on 10/24/14.
//  Copyright (c) 2014 Shintaro Kaneko (http://kaneshinth.com). All rights reserved.
//

import Foundation
import CoreData

class Event: NSManagedObject {
    
    @NSManaged var title: NSString
    @NSManaged var timeStamp: NSDate
    
}
