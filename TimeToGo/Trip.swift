//
//  Trip.swift
//  TimeToGo
//
//  Created by Matt Manzi on 7/4/15.
//  Copyright (c) 2017 MRM Software. All rights reserved.
//
//	CoreData entity class

import CoreData

@objc(Trip) class Trip: NSManagedObject {

    @NSManaged var flightDate: Date
    @NSManaged var tripName: String
    @NSManaged var eventTimeLabel: String
    @NSManaged var eventType: String
    @NSManaged var entries: NSArray

}
