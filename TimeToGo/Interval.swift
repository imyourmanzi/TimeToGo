//
//  Interval.swift
//  TimeToGo
//
//  Created by Matteo Manzi on 7/4/15.
//  Copyright (c) 2015 VMM Software. All rights reserved.
//

import UIKit
import MapKit

class Interval: NSObject, NSCoding {
	
	// Public variables
	var mainLabel: String!
	var scheduleLabel: String!
	var timeValueHours: Int!
	var timeValueMins: Int!
	var timeValueStr: String!
	var startDate: NSDate!
	var useLocation: Bool? = false
	var startLocation: MKPlacemark? = nil
	var endLocation: MKPlacemark? = nil
	
	// Private label variables for schedule
	private let entryLabel = UILabel()
	private let dateLabel = UILabel()
	
	
	// MARK: - Initializers
	
/*
	// OBSOLETE INITIALIZER
	
	init(mainLabel: String, timeValueHours: Int, timeValueMins: Int) {
		
		self.mainLabel = mainLabel
		self.scheduleLabel = {
			
			if let timeStrRange = mainLabel.rangeOfString("Time for") {
				
				return mainLabel.stringByReplacingCharactersInRange(timeStrRange, withString: "Start:")
				
			} else if let timeStrRange = mainLabel.rangeOfString("Time to") {
				
				return mainLabel.stringByReplacingCharactersInRange(timeStrRange, withString: "Start:")
				
			} else if let timeStrRange = mainLabel.rangeOfString("Time between") {
				
				return mainLabel.stringByReplacingCharactersInRange(timeStrRange, withString: "Start:")
				
			} else {
				
				return mainLabel
				
			}
			
		}()
		self.timeValueHours = timeValueHours
		self.timeValueMins = timeValueMins
		
	}
*/
	
	init(mainLabel: String, scheduleLabel: String, timeValueHours: Int, timeValueMins: Int) {
		
		self.mainLabel = mainLabel
		self.timeValueHours = timeValueHours
		self.timeValueMins = timeValueMins
		self.scheduleLabel = scheduleLabel
		
	}
	
	init(mainLabel: String, scheduleLabel: String, timeValueHours: Int, timeValueMins: Int, usesLocation: Bool, startLoc: MKPlacemark?, endLoc: MKPlacemark?) {
		
		self.mainLabel = mainLabel
		self.timeValueHours = timeValueHours
		self.timeValueMins = timeValueMins
		self.scheduleLabel = scheduleLabel
		self.useLocation = usesLocation
		if usesLocation == true && startLoc != nil && endLoc != nil {
			
			self.startLocation = startLoc
			self.endLocation = endLoc
			
		}
		
	}
	
	// Gets a custom built time interval string from a combination of hours and minutes
	func stringFromTimeValue() -> String {
		
		var timeString: String!
		
		if timeValueMins > 9 {
		
			timeString = "\(timeValueHours):\(timeValueMins)"
			
		} else {
			
			timeString = "\(timeValueHours):0\(timeValueMins)"
			
		}
		timeValueStr = timeString
		
		return timeString
		
	}
	
	// Class level function for getting custom built time interval string from a combination of hours and minutes
	static func stringFromTimeValue(timeValueHours: Int, timeValueMins: Int) -> String {
		
		var timeString: String!
		
		if timeValueMins > 9 {
			
			timeString = "\(timeValueHours):\(timeValueMins)"
			
		} else {
			
			timeString = "\(timeValueHours):0\(timeValueMins)"
			
		}
		
		return timeString
		
	}
	
	// Creates and adds label for scheduleLabel to a view
	func createScheduleLabelFromTopSpace(topSpace: CGFloat, onView view: UIView) {
		
		if scheduleLabel == nil {
			
			if let timeStrRange = mainLabel.rangeOfString("Time for") {
				
				scheduleLabel = mainLabel.stringByReplacingCharactersInRange(timeStrRange, withString: "Start:")
				
			} else if let timeStrRange = mainLabel.rangeOfString("Time to") {
				
				scheduleLabel = mainLabel.stringByReplacingCharactersInRange(timeStrRange, withString: "Start:")
				
			} else if let timeStrRange = mainLabel.rangeOfString("Time between") {
				
				scheduleLabel = mainLabel.stringByReplacingCharactersInRange(timeStrRange, withString: "Start:")
				
			} else {
				
				scheduleLabel = mainLabel
				
			}
			
		}
		
		entryLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
		entryLabel.numberOfLines = 2
		entryLabel.font = UIFont.systemFontOfSize(16.0)
		view.addSubview(entryLabel)
		
		let leftConstraint = NSLayoutConstraint(item: entryLabel,
			attribute: NSLayoutAttribute.Left,
			relatedBy: NSLayoutRelation.Equal,
			toItem: view,
			attribute: NSLayoutAttribute.LeftMargin,
			multiplier: 1.0,
			constant: 15.0)
		
		let topConstraint = NSLayoutConstraint(item: entryLabel,
			attribute: NSLayoutAttribute.Top,
			relatedBy: NSLayoutRelation.Equal,
			toItem: view,
			attribute: NSLayoutAttribute.Top,
			multiplier: 1.0,
			constant: topSpace)
		
		let rightConstraint = NSLayoutConstraint(item: entryLabel,
			attribute: NSLayoutAttribute.Right,
			relatedBy: NSLayoutRelation.Equal,
			toItem: view,
			attribute: NSLayoutAttribute.CenterX,
			multiplier: 1.0,
			constant: 40.0)
		
		view.addConstraints([leftConstraint, topConstraint, rightConstraint])
		
	}
	
	// Updates text on above scheduleLabel
	func updateScheduleText() {
		
		entryLabel.text = scheduleLabel
		
	}
	
	// Returns an NSTimeInterval by converting timeValueHours and timeValueMins
	func timeIntervalByConvertingTimeValue() -> NSTimeInterval {
		
		let timeIntervalHours = Double(timeValueHours) * 60.0 * 60.0
		let timeIntervalMins = Double(timeValueMins) * 60.0
		let timeInterval: NSTimeInterval = timeIntervalHours + timeIntervalMins
		
		return timeInterval
		
	}
	
	// Creates and adds label for timeValueHours and timeValueMins to a view
	func createDateLabelOnView(view: UIView) {
		
		dateLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
		dateLabel.numberOfLines = 1
		dateLabel.font = UIFont.systemFontOfSize(16.0)
		view.addSubview(dateLabel)
		
		let leftConstraint = NSLayoutConstraint(item: dateLabel,
			attribute: NSLayoutAttribute.Left,
			relatedBy: NSLayoutRelation.GreaterThanOrEqual,
			toItem: entryLabel,
			attribute: NSLayoutAttribute.Right,
			multiplier: 1.0,
			constant: 5.0)
		
		let topConstraint = NSLayoutConstraint(item: dateLabel,
			attribute: NSLayoutAttribute.Top,
			relatedBy: NSLayoutRelation.Equal,
			toItem: entryLabel,
			attribute: NSLayoutAttribute.Top,
			multiplier: 1.0,
			constant: 0.0)
		
		let rightConstraint = NSLayoutConstraint(item: dateLabel,
			attribute: NSLayoutAttribute.Right,
			relatedBy: NSLayoutRelation.Equal,
			toItem: view,
			attribute: NSLayoutAttribute.RightMargin,
			multiplier: 1.0,
			constant: -15.0)
		
		view.addConstraints([topConstraint, rightConstraint])
		
	}

	// Updates text on above dateLabel
	func updateDateTextWithString(dateString: String) {
		
		dateLabel.text = dateString
		
	}
	
	// Remove an interval's labels from their superview
	func removeViewsFromSuperview() {
		
		entryLabel.removeFromSuperview()
		dateLabel.removeFromSuperview()
		
	}
	
	// Static function that composes an address label for any MKMapItem
	static func getAddressFromMapItem(mapItem: MKMapItem) -> String {
		
		var streetAddress = ""
		
		if let thoroughfare = mapItem.placemark.thoroughfare {
			
			if let subThoroughfare = mapItem.placemark.subThoroughfare {
				streetAddress += subThoroughfare
			}
			
			streetAddress += " \(thoroughfare), "
			
		}
		if let locality = mapItem.placemark.locality {
			streetAddress += "\(locality), "
		}
		if let adminArea = mapItem.placemark.administrativeArea {
			
			streetAddress += adminArea
			
			if let postalCode = mapItem.placemark.postalCode {
				streetAddress += postalCode
			}
			
			streetAddress += ", "
			
		}
		if let country = mapItem.placemark.country {
			streetAddress += country
		}
		
		return streetAddress
		
	}
	
	
	// MARK: - NSCoding protocol
	
	required init(coder aDecoder: NSCoder) {
		
		self.mainLabel = aDecoder.decodeObjectForKey("mainLabel") as! String
		self.scheduleLabel = aDecoder.decodeObjectForKey("scheduleLabel") as! String
		self.timeValueHours = aDecoder.decodeObjectForKey("timeValueHours") as! Int
		self.timeValueMins = aDecoder.decodeObjectForKey("timeValueMins") as! Int
		self.useLocation = aDecoder.decodeObjectForKey("useLocation") as! Bool?
		self.startLocation = aDecoder.decodeObjectForKey("startLocation") as! MKPlacemark?
		self.endLocation = aDecoder.decodeObjectForKey("endLocation") as! MKPlacemark?
		
	}
	
	func encodeWithCoder(aCoder: NSCoder) {
		
		aCoder.encodeObject(mainLabel, forKey: "mainLabel")
		aCoder.encodeObject(scheduleLabel, forKey: "scheduleLabel")
		aCoder.encodeObject(timeValueHours, forKey: "timeValueHours")
		aCoder.encodeObject(timeValueMins, forKey: "timeValueMins")
		aCoder.encodeObject(useLocation, forKey: "useLocation")
		aCoder.encodeObject(startLocation, forKey: "startLocation")
		aCoder.encodeObject(endLocation, forKey: "endLocation")
		
	}
	
	
	// MARK: - NSObject
	
	override func isEqual(object: AnyObject?) -> Bool {
		
		if let theObject = object as? Interval {
			
			return (self.mainLabel == theObject.mainLabel &&
					self.scheduleLabel == theObject.scheduleLabel &&
					self.timeValueHours == theObject.timeValueHours &&
					self.timeValueMins == theObject.timeValueMins &&
					self.useLocation == theObject.useLocation &&
					self.startLocation == theObject.startLocation &&
					self.endLocation == theObject.endLocation)
			
		}
			
		return false
		
	}
	
	override var hash: Int {
		
		return mainLabel.hashValue
		
	}
	
}

