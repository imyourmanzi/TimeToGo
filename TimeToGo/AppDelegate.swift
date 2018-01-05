//
//  AppDelegate.swift
//  TimeToGo
//
//  Created by Matt Manzi on 7/4/15.
//  Copyright (c) 2017 MRM Software. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		
        // Set IntervalTransformer so that CoreData knows which name to access it with
        let intervalTransformer = IntervalTransformer()
        ValueTransformer.setValueTransformer(intervalTransformer, forName: NSValueTransformerName(rawValue: "IntervalTransformer"))
        
		// Set the appearance of the navigation bar across the application to a light
		// blue bar color and white text color and the page control dot for current page
        // to a light orange
		UINavigationBar.appearance().barTintColor = UIColor(red: 46/255, green: 172/255, blue: 240/255, alpha: 1.0)
		UINavigationBar.appearance().tintColor = UIColor.white
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(red: 255/255, green: 169/255, blue: 59/255, alpha: 1.0)
		
        // Register a default for:
        // - the currentTripName
        // - whether or not the mainLabel was moved
        // - whether or not it's the first launch
		let defaults = UserDefaults.standard
		defaults.register(defaults: ["currentTripName": ""])
        defaults.register(defaults: ["movedMainLabel": false])
        defaults.register(defaults: ["notFirstLaunch": false])
        
		return true
	}
    
    func applicationWillResignActive(_ application: UIApplication) {
		
		self.saveContext()
        
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		
		self.saveContext()
        
	}

	func applicationWillEnterForeground(_ application: UIApplication) { }

	func applicationDidBecomeActive(_ application: UIApplication) { }

	func applicationWillTerminate(_ application: UIApplication) {
        
		self.saveContext()
        
	}

	// MARK: - Core Data stack

	lazy var applicationDocumentsDirectory: URL = {
        
	    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.VMM.TimeToGo" in the application's documents Application Support directory.
	    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
	    
        // Print the file path for the sqlite database file for the current simulator
//        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!)
        
        return urls[urls.count-1]
        
	}()

	lazy var managedObjectModel: NSManagedObjectModel = {
        
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
	    let modelURL = Bundle.main.url(forResource: "TimeToGo", withExtension: "momd")!
        
	    return NSManagedObjectModel(contentsOf: modelURL)!
        
	}()

	lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        
	    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
	    // Create the coordinator and store
	    var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
	    let url = self.applicationDocumentsDirectory.appendingPathComponent("TimeToGo.sqlite")
        let migrateOptions = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        
	    var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: migrateOptions)
        } catch var err as NSError {
            
            coordinator = nil
            // Report any error we got
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
            dict[NSUnderlyingErrorKey] = err
            err = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(String(describing: err)), \(err.userInfo)")
            fatalError()
            
        } catch {
            fatalError()
        }
	    
	    return coordinator
        
	}()

	lazy var managedObjectContext: NSManagedObjectContext? = {
        
	    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
	    let coordinator = self.persistentStoreCoordinator
	    if coordinator == nil {
	        return nil
	    }
        
	    var managedObjectContext = NSManagedObjectContext()
	    managedObjectContext.persistentStoreCoordinator = coordinator
        
	    return managedObjectContext
        
	}()

	
	// MARK: - Core Data saving support

	func saveContext() {
		
	    guard let moc = self.managedObjectContext else {
			return
		}
        
		if moc.hasChanges {
            
			do {
				try moc.save()
			} catch {
                moc.rollback()
			}
			
		}
		
	}

}

