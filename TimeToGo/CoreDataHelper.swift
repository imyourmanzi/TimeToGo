//
//  CoreDataExtrasProtocol.swift
//  TimeToGo
//
//  Created by Matt Manzi on 1/24/17.
//  Copyright © 2017 MRM Software. All rights reserved.
//

import UIKit
import CoreData

public enum CoreDataEventError: Error {
    
    case invalidEventName
    case invalidContext
    case returnedNoEvents
    
}

public protocol CoreDataHelper {
    
    // Setting a local view controller variable for event name
    func retrieveCurrentEventName()
    
    // Any deafult steps that may be done here, when preparing for saving the context
    func prepareForUpdate() 
    
}


// MARK: - Default function implementation

extension CoreDataHelper {
    
    func retrieveCurrentEventName() { }
    
    func prepareForUpdate() { }
    
}

public class CoreDataConnector {
    
    static let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate

    static func getMoc() -> NSManagedObjectContext? {
        
        guard let theMoc = appDelegate.managedObjectContext else {
            return nil
        }
        
        return theMoc
        
    }
    
    static func getCurrentEventName() -> String? {
        
        return UserDefaults.standard.string(forKey: CoreDataConstants.CURRENT_EVENT_NAME_KEY)
        
    }
    
    static func setCurrentEventName(to newName: String) {
        
        UserDefaults.standard.set(newName, forKey: CoreDataConstants.CURRENT_EVENT_NAME_KEY)
        
    }
    
    static func fetchCurrentEvent() throws -> Trip {
        
        guard let currentEventName = getCurrentEventName() else {
            throw CoreDataEventError.invalidEventName
        }
        
        return try fetchOneEvent(named: currentEventName)
        
    }
    
    static func fetchAllEvents() throws -> [Trip] {
        
        return try fetchEvents(using: nil)
        
    }
    
    
    static func updateStore(from sender: UIViewController?) {
        
        if let theSender = sender as? CoreDataHelper {
            theSender.prepareForUpdate()
        }
        
        appDelegate.saveContext()
        
    }
    
    private static func fetchEvents(using predicate: NSPredicate?) throws -> [Trip] {
        
        let fetchRequest = NSFetchRequest<Trip>(entityName: CoreDataConstants.ENTITY_NAME)
        
        if let fetchPredicate = predicate {
            fetchRequest.predicate = fetchPredicate
        }
        
        guard let theMoc = getMoc() else {
            throw CoreDataEventError.invalidContext
        }
        
        let events = try theMoc.fetch(fetchRequest)
        
        if events.isEmpty {
            throw CoreDataEventError.returnedNoEvents
        } else {
            return events
        }
        
    }
    
    private static func fetchOneEvent(named name: String) throws -> Trip {
        
        let predicate = NSPredicate(format: CoreDataConstants.FETCH_BY_NAME, name)
        let events = try fetchEvents(using: predicate)
        
        guard let event = events.first else {
            throw CoreDataEventError.returnedNoEvents
        }
        
        return event
        
    }
    
}
