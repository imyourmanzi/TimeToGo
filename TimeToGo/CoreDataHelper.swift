//
//  CoreDataExtrasProtocol.swift
//  TimeToGo
//
//  Created by Matt Manzi on 1/24/17.
//  Copyright © 2017 MRM Software. All rights reserved.
//

import UIKit
import CoreData

protocol CoreDataHelper {
    
    var appDelegate: AppDelegate { get }
    var moc: NSManagedObjectContext? { get }
    var eventName: String? { get }
    
//    func getContext() -> NSManagedObjectContext?
    
    func fetchEvents(using: NSPredicate?) throws -> [Trip]
    
    func fetchEvent(named: String) throws -> Trip
    
    func fetchCurrentEvent() throws -> Trip
    
    func fetchAllEvents() throws -> [Trip]
    
    func prepareForUpdateOnCoreData()
    
    func performUpdateOnCoreData()
    
}

enum CoreDataEventError: Error {
    
    case invalidEventName
    case invalidContext
    case returnedNoEvents
    
}


// MARK: - Default Method Implementations

extension CoreDataHelper {
    
    var appDelegate: AppDelegate {
        
        return UIApplication.shared.delegate as! AppDelegate
        
    }
    
    var moc: NSManagedObjectContext? {
        
        guard let theMoc = appDelegate.managedObjectContext else {
            return nil
        }
        
        return theMoc
        
    }
    
    var eventName: String? {
        
        return UserDefaults.standard.string(forKey: "currentTripName")
        
    }
    
//    func getContext() -> NSManagedObjectContext? {
//        
//        let appDel = UIApplication.shared.delegate as! AppDelegate
//        
//        guard let theMoc = appDel.managedObjectContext else {
//            return nil
//        }
//        
//        return theMoc
//        
//    }
    
    func fetchEvents(using predicate: NSPredicate?) throws -> [Trip] {
        
        let fetchRequest = NSFetchRequest<Trip>(entityName: "Trip")
        if let fetchPredicate = predicate {
            fetchRequest.predicate = fetchPredicate
        }
        
        guard let theMoc = moc else {
            throw CoreDataEventError.invalidContext
        }
        
        let events = try theMoc.fetch(fetchRequest)
        
        if events.count <= 0 {
            throw CoreDataEventError.returnedNoEvents
        } else {
            return events
        }
        
    }
    
    func fetchEvent(named name: String) throws -> Trip {
        
//        let fetchRequest = NSFetchRequest<Trip>(entityName: "Trip")
//        fetchRequest.predicate = NSPredicate(format: "tripName == %@", name)
//        
//        guard let theMoc = moc else {
//            throw CoreDataEventError.invalidMOC
//        }
//            
//        print("trying to fetch")
//        let events = try theMoc.fetch(fetchRequest)
//        let event = events[0]
//    
//        return event
        
//        print("caught for dataFetchFailed")
//        throw CoreDataEventError.dataFetchError
        
        let predicate = NSPredicate(format: "tripName == %@", name)
        
        let events = try fetchEvents(using: predicate)
        guard let event = events.first else {
            throw CoreDataEventError.returnedNoEvents
        }
        
        return event
        
    }
    
    func fetchCurrentEvent() throws -> Trip {
        
        guard let theName = eventName else {
            throw CoreDataEventError.invalidEventName
        }
        
        return try fetchEvent(named: theName)
        
    }
    
    func fetchAllEvents() throws -> [Trip] {
        
//        let fetchRequest = NSFetchRequest<Trip>(entityName: "Trip")
//        
//        guard let theMoc = moc else {
//            throw CoreDataEventError.invalidMOC
//        }
//        
//        return try theMoc.fetch(fetchRequest)
        
        return try fetchEvents(using: nil)
        
    }
    
    func prepareForUpdateOnCoreData() {
        // Add any deafult steps that may be done here, when preparing for saving the context
    }
    
    func performUpdateOnCoreData() {
        
        prepareForUpdateOnCoreData()
        
        appDelegate.saveContext()
        
    }
    
//    func performUpdateOnCoreData() {
//        
//        prepareForUpdateOnCoreData()
//        
//        guard let moc = self.moc else {
//            return
//        }
//        
//        if moc.hasChanges {
//            
//            do {
//                try moc.save()
//            } catch {
//            }
//            
//        }
//        
//    }
    
}
