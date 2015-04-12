# Active Record for Swift

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Easy way to operate for Core Data.


The library is inspired by the active record pattern which is a kind of design pattern to operate database easily.

----

## Requirements

- Xcode 6.3
- iOS7+ Mac OS X 10.10

## Installation

### Carthage

1. Add the following to your *Cartfile*: `github "kaneshin/ActiveRecord" ~> 0.1`
2. Run `carthage update`
3. Add ActiveRecord as an embedded framework.

### Embedded Framework

- Clone `ActiveRecord-swift` as a git submodule.
- Add `ActiveRecord.xcodeproj` file into your Xcode project.
- Link `ActiveRecord.framework` product for your target.
- Embed `ActiveRecord.framework`

## Usage

`ActiveRecord` needs `Context` which is contained `NSManagedObjectContext` for reading/writing on each threads.

So, you define the application context at first like below:

```swift
/**
    Application Context, which is inherited ARContext.
    It's easier to use than self-defined context.
 */
class AppContext: ARContext {
    override init() {
        super.init()
        self.persistentStoreCoordinator = self.lazyPersistentStoreCoordinator
    }

    private lazy var lazyPersistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        if let managedObjectModel = self.managedObjectModel {
            var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
            var error: NSError? = nil
            if let url = self.storeURL {
                if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
                    coordinator = nil
                }
            }
            return coordinator
        }
        return nil;
    }()
}
```

(Please show [AppContext.swift](https://github.com/kaneshin/ActiveRecord/blob/master/Example/Example%20Swift/AppContext.swift) in example project.)

And then, setup it into the `ActiveRecord` in `AppDelegate`.

```swift
import UIKit
import ActiveRecord

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    override class func initialize() {
        ActiveRecord.setup(context: AppContext())
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }

}
```


You can handle `NSManagedObject` like active record.

```swift
// Create
var event = Event.create(entityName: "Event") as? Event
event.title = "eat"
event.timeStamp = NSDate()
event.save()

// Read
var events = Event.find(entityName: "Event)"

// Delete
events?.first?.delete()
```

## License

[The MIT License (MIT)](http://kaneshin.mit-license.org/)

## Author

- [Shintaro Kaneko](https://github.com/kaneshin) <kaneshin0120@gmail.com>

## Contributors

- [Hiroshi Kimura](https://github.com/muukii0803) <muukii.muukii@gmail.com>
- Kenji Tayama

