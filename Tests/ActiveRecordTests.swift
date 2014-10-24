// ActiveRecordTests.swift
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

import XCTest
import ActiveRecord
import CoreData

class ActiveRecordTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        ActiveRecordConfig.sharedInstance.coreDataStack = TestCoreDataStack()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testCrud() {
        let eventEntityName = "Event"
        var events = Event.find(entityName: eventEntityName)
        println("events count : \(events?.count)")
        XCTAssertTrue(events?.count == nil || events?.count == 0, "should find none")
        
        var newEvent = Event.create(entityName: eventEntityName) as? Event
        newEvent?.title = "eat"
        newEvent?.timeStamp = NSDate()
        NSManagedObjectContext.save()
        XCTAssertNotNil(newEvent, "new entity should be created")
        
        var fetchedEvent = Event.findFirst(entityName: eventEntityName) as? Event
        XCTAssertNotNil(fetchedEvent, "should find created event")
        if let fetchedEvent = fetchedEvent {
            XCTAssertEqual(fetchedEvent.title, "eat", "title should be eat")
        }
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
