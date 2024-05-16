
import UIKit
import ARVideoKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ARFaceFilterModel")
          container.loadPersistentStores { (storeDescription, error) in
              if let error = error {
                  fatalError("Unable to load persistent store: \(error)")
              }
          }
          return container
      }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if let storeURL = persistentContainer.persistentStoreDescriptions.first?.url {
            print("Database Path: \(storeURL.path)")
        }
        if #available(iOS 13.0, *) {
           // window?.overrideUserInterfaceStyle = .light
        }
        return true
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return ViewAR.orientation
    }

}

