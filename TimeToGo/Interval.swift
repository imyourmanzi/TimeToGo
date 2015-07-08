//
//  Interval.swift
//  TravelTimerBasics5
//
//  Created by Matteo Manzi on 6/24/15.
//	Edited by Matteo Manzi on 6/26/15.
//  Copyright (c) 2015 VMM Softwares. All rights reserved.
//

import UIKit

class Interval: NSObject, NSCoding {
	
	var mainLabel: String!
	var scheduleLabel: String!
	var timeValueHours: Int!
	var timeValueMins: Int!
	var timeValueStr: String!
	var startDate: NSDate!
	
	private let entryLabel = UILabel()
	private let dateLabel = UILabel()
	
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
	
	init(mainLabel: String, scheduleLabel: String, timeValueHours: Int, timeValueMins: Int) {
		
		self.mainLabel = mainLabel
		self.timeValueHours = timeValueHours
		self.timeValueMins = timeValueMins
		self.scheduleLabel = scheduleLabel
		
	}
	
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
	
	static func stringFromTimeValue(timeValueHours: Int, timeValueMins: Int) -> String {
		
		var timeString: String!
		
		if timeValueMins > 9 {
			
			timeString = "\(timeValueHours):\(timeValueMins)"
			
		} else {
			
			timeString = "\(timeValueHours):0\(timeValueMins)"
			
		}
		
		return timeString
		
	}
	
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
	
	func updateScheduleText() {
		
		entryLabel.text = scheduleLabel
		
	}
	
	func timeIntervalByConvertingTimeValue() -> NSTimeInterval {
		
		let timeIntervalHours = Double(timeValueHours) * 60.0 * 60.0
		let timeIntervalMins = Double(timeValueMins) * 60.0
		let timeInterval: NSTimeInterval = timeIntervalHours + timeIntervalMins
		
		return timeInterval
		
	}
	
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

	func updateDateTextWithString(dateString: String) {
		
		dateLabel.text = dateString
		
	}
	
	func removeViewsFromSuperview() {
		
		entryLabel.removeFromSuperview()
		dateLabel.removeFromSuperview()
		
	}
	
	
	// MARK: - NSCoding protocol
	
	required init(coder aDecoder: NSCoder) {
		
		self.mainLabel = aDecoder.decodeObjectForKey("mainLabel") as! String
		self.scheduleLabel = aDecoder.decodeObjectForKey("scheduleLabel") as! String
		self.timeValueHours = aDecoder.decodeObjectForKey("timeValueHours") as! Int
		self.timeValueMins = aDecoder.decodeObjectForKey("timeValueMins") as! Int
		
	}
	
	func encodeWithCoder(aCoder: NSCoder) {
		
		aCoder.encodeObject(mainLabel, forKey: "mainLabel")
		aCoder.encodeObject(scheduleLabel, forKey: "scheduleLabel")
		aCoder.encodeObject(timeValueHours, forKey: "timeValueHours")
		aCoder.encodeObject(timeValueMins, forKey: "timeValueMins")
		
	}
	
	
	// MARK: - NSObject
	
	override func isEqual(object: AnyObject?) -> Bool {
		
		if let theObject = object as? Interval {
			
			return (self.mainLabel == theObject.mainLabel &&
					self.scheduleLabel == theObject.scheduleLabel &&
					self.timeValueHours == theObject.timeValueHours &&
					self.timeValueMins == theObject.timeValueMins)
			
		}
			
		return false
		
	}
	
	override var hash: Int {
		
		return mainLabel.hashValue
		
	}
	
}

