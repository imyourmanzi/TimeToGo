//
//  LocationAnnotation.swift
//  TimeToGo
//
//  Created by Matteo Manzi on 7/4/15.
//  Copyright (c) 2015 VMM Software. All rights reserved.
//

import UIKit
import MapKit

class LocationAnnotation: NSObject, MKAnnotation {
 
	private(set) var coordinate: CLLocationCoordinate2D
	private(set) var title: String
	private(set) var subtitle: String?
	
	init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String?) {
		
		self.coordinate = coordinate
		self.title = title
		self.subtitle = subtitle
		
	}
	
}
