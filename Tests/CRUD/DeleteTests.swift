// DeleteTests.swift
//
// Copyright (c) 2014 Kenji Tayame
// Copyright (c) 2014 Shintaro Kaneko
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
import CoreData
import ActiveRecord

class DeleteTests: ActiveRecordTestCase {

    func testDelete() {
        let eventEntityName = "Event"
        var events = Event.find(entityName: eventEntityName)
        XCTAssertNotNil(events, "find does not fail")
        println("events count : \(events?.count)")
        if let events = events {
            XCTAssertTrue(events.count == 0, "should find none")
        }

        // create
        var newEvent = Event.create(entityName: eventEntityName) as? Event
        XCTAssertNotNil(newEvent, "create does not fail")
        if let event = newEvent {
            event.title = "eat"
            event.timeStamp = NSDate()
            event.save()
        }

        // read
        var fetchedEvent = Event.findFirst(entityName: eventEntityName) as? Event
        XCTAssertNotNil(fetchedEvent, "should find created event")
        if let fetchedEvent = fetchedEvent {
            XCTAssertEqual(fetchedEvent.title, "eat", "title should be eat")
        }

        // create
        newEvent = Event.create(entityName: eventEntityName) as? Event
        XCTAssertNotNil(newEvent, "create does not fail")
        if let event = newEvent {
            event.title = "sleep"
            event.timeStamp = NSDate()
            event.save()
        }

        // create
        newEvent = Event.create(entityName: eventEntityName) as? Event
        XCTAssertNotNil(newEvent, "create does not fail")
        if let event = newEvent {
            event.title = "play"
            event.timeStamp = NSDate()
            event.save()
        }

        // find with predicate
        fetchedEvent = Event.findFirst(entityName: eventEntityName, predicate: NSPredicate(format: "SELF.title = %@", "play")) as? Event
        XCTAssertNotNil(fetchedEvent, "should find created event")
        if let fetchedEvent = fetchedEvent {
            XCTAssertEqual(fetchedEvent.title, "play", "title should be play")
        }

        // find with predicate and sortDescriptor
        let sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor(key: "title", ascending: false)]
        fetchedEvent = Event.findFirst(entityName: eventEntityName, sortDescriptors:sortDescriptors) as? Event
        if let fetchedEvent = fetchedEvent {
            XCTAssertEqual(fetchedEvent.title, "sleep", "title should be sleep")
        }

        // update
        if let event = fetchedEvent {
            event.title = "work"
            event.save()
        }

        // find updated
        fetchedEvent = Event.findFirst(entityName: eventEntityName, predicate: NSPredicate(format: "SELF.title = %@", "work")) as? Event
        XCTAssertNotNil(fetchedEvent, "should find updated event")
        if let fetchedEvent = fetchedEvent {
            XCTAssertEqual(fetchedEvent.title, "work", "title should be work")
        }

        // delete
        if let event = fetchedEvent {
            event.delete()
        }

        // cannot find deleted
        fetchedEvent = Event.findFirst(entityName: eventEntityName, predicate: NSPredicate(format: "SELF.title = %@", "work")) as? Event
        XCTAssertNil(fetchedEvent, "should not find deleted event")
    }
    
}
