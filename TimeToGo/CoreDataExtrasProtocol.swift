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
    
    var moc: NSManagedObjectContext? { get set }
    
    func getContext() -> NSManagedObjectContext?
    
    func prepareForUpdateOnCoreData()
    
    func performUpdateOnCoreData()
    
}


// MARK: - Default Method Implementations

extension CoreDataHelper {
    
    func getContext() -> NSManagedObjectContext? {
        
        let appDel = UIApplication.shared.delegate as! AppDelegate
        
        guard let theMoc = appDel.managedObjectContext else {
            return nil
        }
        
        return theMoc
        
    }
    
    func prepareForUpdateOnCoreData() {
        // Add any deafult steps that may be done here, when preparing for saving the context
    }
    
    func performUpdateOnCoreData() {
        
        prepareForUpdateOnCoreData()
        
        guard let moc = self.moc else {
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
