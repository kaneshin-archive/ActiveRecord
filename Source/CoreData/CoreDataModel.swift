// Migration.swift
//
// Copyright (c) 2015 Shintaro Kaneko
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

class CoreDataModel: NSObject {

    private var ctx: Context?

    init(context: Context?) {
        super.init()
        self.ctx = context
    }

}

class Migrator: CoreDataModel {

    var isConfirmedCompatibility: Bool = false

    /**
    Check if migration is needed.

    :returns: true if migration is needed. false if not needed (includes case when persistent store is not found).
    */
    var required: Bool {
        if let storeURL = self.ctx?.storeURL {
            var error: NSError? = nil
            if !storeURL.checkResourceIsReachableAndReturnError(&error) {
                // Couldn't find a persistent store.
                Log.print(.WARN, "Persistent store not found : \(error?.localizedDescription)")
                return false
            }

            // Check compatibility
            if let managedObjectModel = self.ctx?.managedObjectModel {
                let metadata = NSPersistentStoreCoordinator.metadataForPersistentStoreOfType(NSSQLiteStoreType, URL: storeURL, error: &error)
                let isCompatible: Bool = managedObjectModel.isConfiguration(nil, compatibleWithStoreMetadata: metadata)
                if isCompatible {
                    self.isConfirmedCompatibility = true
                }
                return !isCompatible
            } else {
                Log.print(.ERROR, "Could not get managed object model")
            }
        }
        return false
    }

}
