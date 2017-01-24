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
    var currentTripName: String! { get set }
    
    func performUpdateOnCoreData()
    
}
