//
//  AppDelegate.swift
//  TimeToGo
//
//  Created by Matteo Manzi on 7/4/15.
//  Copyright (c) 2015 VMM Software. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
    
	override class func initialize() {
		
		// Set IntervalTransformer so that CoreData knows which name to access it with
		let intervalTransformer = IntervalTransformer()
		ValueTransformer.setValueTransformer(intervalTransformer, forName: NSValueTransformerName(rawValue: "IntervalTransformer"))
		
	}
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		
		// Set the appearance of the navigation bar across the application to a light
		// blue bar color and white text color
		UINavigationBar.appearance().barTintColor = UIColor(red: 46/255, green: 172/255, blue: 240/255, alpha: 1.0)
		UINavigationBar.appearance().tintColor = UIColor.white
		
        // Register a default for:
        // - the currentTripName
        // - whether or not the mainLabel was moved
		let defaults = UserDefaults.standard
		defaults.register(defaults: ["currentTripName": ""])
        defaults.register(defaults: ["movedMainLabel": false])
		
		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
		
		self.saveContext()
        
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		
		self.saveContext()
        
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		
        
        
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		
        
        
	}

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
        
	    var error: NSError? = nil
	    var failureReason = "There was an error creating or loading the application's saved data."
	    do {
			try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: migrateOptions)
		} catch var error1 as NSError {
            
			error = error1
	        coordinator = nil
	        // Report any error we got.
	        var dict = [String: AnyObject]()
	        dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
	        dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
	        dict[NSUnderlyingErrorKey] = error
	        error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
	        // Replace this with code to handle the error appropriately.
	        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	        NSLog("Unresolved error \(error), \(error!.userInfo)")
	        abort()
            
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

	
	// MARK: - Core Data Saving support

	func saveContext() {
		
	    guard let moc = self.managedObjectContext else {
			return
		}
		
		if moc.hasChanges {
			
			do {
				try moc.save()
			} catch {
			}
			
		}
		
	}

}

