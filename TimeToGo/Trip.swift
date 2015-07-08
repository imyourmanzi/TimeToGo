//
//  Trip.swift
//  
//
//  Created by Matteo Manzi on 7/1/15.
//
//

import Foundation
import CoreData

@objc(Trip) class Trip: NSManagedObject {

    @NSManaged var flightDate: NSDate
    @NSManaged var tripName: String
    @NSManaged var entries: NSArray

}
