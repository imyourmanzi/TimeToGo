//
//  Interval.swift
//  TimeToGo
//
//  Created by Matt Manzi on 7/4/15.
//  Copyright (c) 2017 MRM Software. All rights reserved.
//

import UIKit
import MapKit

class Interval: NSObject, NSCoding {
    
	// Public variables
    var mainLabel: String?
	var scheduleLabel: String!
	var timeValueHours: Int!
	var timeValueMins: Int!
	var timeValueStr: String!
	var startDate: Date!
	var useLocation: Bool? = false
	var startLocation: MKPlacemark? = nil
	var endLocation: MKPlacemark? = nil
    var notesStr: String? = nil
    
	// Private label constants for schedule
	private let entryLabel = UILabel()
	private let dateLabel = UILabel()
    
	
	// MARK: - Initializers
	
    init(scheduleLabel: String, timeValueHours: Int, timeValueMins: Int, notesStr: String?, usesLocation: Bool, startLoc: MKPlacemark?, endLoc: MKPlacemark?) {
		
        self.scheduleLabel = scheduleLabel
		self.timeValueHours = timeValueHours
		self.timeValueMins = timeValueMins
        self.notesStr = notesStr
		self.useLocation = usesLocation
		if usesLocation == true && startLoc != nil && endLoc != nil {
			
			self.startLocation = startLoc
			self.endLocation = endLoc
			
		}
		
	}
    
    init(args: [String]) {
            
        self.scheduleLabel = args[0]
        
        if let hours = Int(args[1]) {
            self.timeValueHours = hours
        } else {
            self.timeValueHours = 0
        }
        
        if let mins = Int(args[2]) {
            self.timeValueMins = mins
        } else {
            self.timeValueMins = 0
        }
        
        if args.count == 5 {
            
            self.useLocation = Bool(args[3])
            self.notesStr = args[4]
            
        }
        
    }
    
    
    // MARK: - Formatting time values
	
	// Gets a custom built time interval string from a combination of hours and minutes
	func getTimeValueString() -> String {
		
		var timeString: String!
		
		if timeValueMins > 9 {
		
			timeString = "\(timeValueHours!):\(timeValueMins!)"
			
		} else {
			
			timeString = "\(timeValueHours!):0\(timeValueMins!)"
			
		}
		timeValueStr = timeString
		
		return timeString
		
	}
	
	// Class level function for getting custom built time interval string from a combination of hours and minutes
	static func getStringFrom(hours timeValueHours: Int, mins timeValueMins: Int) -> String {
		
		var timeString: String!
		
		if timeValueMins > 9 {
			
			timeString = "\(timeValueHours):\(timeValueMins)"
			
		} else {
			
			timeString = "\(timeValueHours):0\(timeValueMins)"
			
		}
		
		return timeString
		
	}
    
    
    // MARK: - Formatting schedule
	
	// Creates and adds label for scheduleLabel to a view
	func createScheduleLabel(withSpace topSpace: CGFloat, on view: UIView) {
		
		entryLabel.translatesAutoresizingMaskIntoConstraints = false
		entryLabel.numberOfLines = 2
		entryLabel.font = UIFont.systemFont(ofSize: 16.0)
		view.addSubview(entryLabel)
		
		let leftConstraint = NSLayoutConstraint(item: entryLabel,
			attribute: NSLayoutAttribute.left,
			relatedBy: NSLayoutRelation.equal,
			toItem: view,
			attribute: NSLayoutAttribute.leftMargin,
			multiplier: 1.0,
			constant: 15.0)
		
		let topConstraint = NSLayoutConstraint(item: entryLabel,
			attribute: NSLayoutAttribute.top,
			relatedBy: NSLayoutRelation.equal,
			toItem: view,
			attribute: NSLayoutAttribute.top,
			multiplier: 1.0,
			constant: topSpace)
		
		let rightConstraint = NSLayoutConstraint(item: entryLabel,
			attribute: NSLayoutAttribute.right,
			relatedBy: NSLayoutRelation.equal,
			toItem: view,
			attribute: NSLayoutAttribute.centerX,
			multiplier: 1.0,
			constant: 40.0)
		
		view.addConstraints([leftConstraint, topConstraint, rightConstraint])
		
	}
	
	// Updates text on above scheduleLabel
	func updateScheduleText() {
		
		entryLabel.text = scheduleLabel
		
	}
	
	// Returns an NSTimeInterval by converting timeValueHours and timeValueMins
	func getTimeInterval() -> TimeInterval {
		
		let timeIntervalHours = Double(timeValueHours) * 60.0 * 60.0
		let timeIntervalMins = Double(timeValueMins) * 60.0
		let timeInterval: TimeInterval = timeIntervalHours + timeIntervalMins
		
		return timeInterval
		
	}
	
	// Creates and adds label for timeValueHours and timeValueMins to a view
	func createDateLabel(on view: UIView) {
		
		dateLabel.translatesAutoresizingMaskIntoConstraints = false
		dateLabel.numberOfLines = 1
		dateLabel.font = UIFont.systemFont(ofSize: 16.0)
		view.addSubview(dateLabel)
		
		let topConstraint = NSLayoutConstraint(item: dateLabel,
			attribute: NSLayoutAttribute.top,
			relatedBy: NSLayoutRelation.equal,
			toItem: entryLabel,
			attribute: NSLayoutAttribute.top,
			multiplier: 1.0,
			constant: 0.0)
		
		let rightConstraint = NSLayoutConstraint(item: dateLabel,
			attribute: NSLayoutAttribute.right,
			relatedBy: NSLayoutRelation.equal,
			toItem: view,
			attribute: NSLayoutAttribute.rightMargin,
			multiplier: 1.0,
			constant: -15.0)
		
		view.addConstraints([topConstraint, rightConstraint])
		
	}

	// Updates text on above dateLabel
	func updateDateText(to dateString: String) {
		
		dateLabel.text = dateString
		
	}
	
	// Remove an interval's labels from their superview
    func removeViewsFromSuperview() {
        
        entryLabel.removeFromSuperview()
        dateLabel.removeFromSuperview()
        
    }
    
    
    // MARK: - Formatting map address
	
	// Static function that composes an address label for any MKMapItem
	static func getAddress(from mapItem: MKMapItem) -> String {
		
		var streetAddress = ""
		
		if let thoroughfare = mapItem.placemark.thoroughfare {
			
			if let subThoroughfare = mapItem.placemark.subThoroughfare {
				streetAddress += subThoroughfare + " "
            }
			
			streetAddress += "\(thoroughfare), "
		}
        
		if let locality = mapItem.placemark.locality {
			streetAddress += "\(locality), "
		}
        
		if let adminArea = mapItem.placemark.administrativeArea {
			
			streetAddress += adminArea
			
			if let postalCode = mapItem.placemark.postalCode {
				streetAddress += " \(postalCode)"
			}
			
			streetAddress += ", "
		}
        
		if let country = mapItem.placemark.country {
			streetAddress += country
		}
		
		return streetAddress
		
	}
	
	
	// MARK: - NSCoding protocol
	
	required init?(coder aDecoder: NSCoder) {
		
        self.mainLabel = aDecoder.decodeObject(forKey: "mainLabel") as? String
		self.scheduleLabel = aDecoder.decodeObject(forKey: "scheduleLabel") as! String?
		self.timeValueHours = aDecoder.decodeObject(forKey: "timeValueHours") as! Int?
		self.timeValueMins = aDecoder.decodeObject(forKey: "timeValueMins") as! Int?
		self.useLocation = aDecoder.decodeObject(forKey: "useLocation") as! Bool?
		self.startLocation = aDecoder.decodeObject(forKey: "startLocation") as! MKPlacemark?
		self.endLocation = aDecoder.decodeObject(forKey: "endLocation") as! MKPlacemark?
		self.notesStr = aDecoder.decodeObject(forKey: "notesStr") as! String?
		
	}
	
	func encode(with aCoder: NSCoder) {
		
        aCoder.encode(mainLabel, forKey: "mainLabel")
		aCoder.encode(scheduleLabel, forKey: "scheduleLabel")
		aCoder.encode(timeValueHours, forKey: "timeValueHours")
		aCoder.encode(timeValueMins, forKey: "timeValueMins")
		aCoder.encode(useLocation, forKey: "useLocation")
		aCoder.encode(startLocation, forKey: "startLocation")
		aCoder.encode(endLocation, forKey: "endLocation")
		aCoder.encode(notesStr, forKey: "notesStr")
		
	}
    
	
	// MARK: - NSObject protocol
	
    override var hash: Int {
        
        return scheduleLabel.hashValue
        
    }
    
    override var description: String {
        
        return "Label:  \(self.scheduleLabel)\nTime:  \(self.getTimeValueString())\nNotes:  \(String(describing: notesStr))\nMain Label:  \(String(describing: mainLabel))\nUses Location:  \(String(describing: useLocation))"
        
    }
    
	override func isEqual(_ object: Any?) -> Bool {
		
		guard let theObject = object as? Interval else {
			return false
		}
			
		return (self.scheduleLabel == theObject.scheduleLabel &&
                self.timeValueHours == theObject.timeValueHours &&
                self.timeValueMins == theObject.timeValueMins &&
                self.useLocation == theObject.useLocation &&
                self.startLocation == theObject.startLocation &&
                self.endLocation == theObject.endLocation &&
                self.notesStr == theObject.notesStr)
		
	}
	
}
