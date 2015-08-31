//
//  Trip.swift
//  TimeToGo
//
//  Created by Matteo Manzi on 7/4/15.
//  Copyright (c) 2015 VMM Software. All rights reserved.
//
//	CoreData entity class

import Foundation
import CoreData

@objc(Trip) class Trip: NSManagedObject {

    @NSManaged var flightDate: NSDate
    @NSManaged var tripName: String
    @NSManaged var entries: NSArray

}
