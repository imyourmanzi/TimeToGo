//
//  IntervalTransformer.swift
//  TravelTimerBasics10
//
//  Created by Matteo Manzi on 7/1/15.
//  Copyright (c) 2015 VMM Softwares. All rights reserved.
//
//	Class used by CoreData to save the array of Intervals in the Trip class

import UIKit

class IntervalTransformer: NSValueTransformer {

	override class func allowsReverseTransformation() -> Bool {
		
		return true
		
	}
	
	override class func transformedValueClass() -> AnyClass {
		
		return NSArray.classForCoder()
		
	}
	
	override func transformedValue(value: AnyObject?) -> AnyObject? {
		
		return NSKeyedArchiver.archivedDataWithRootObject(value!)
		
	}
	
	override func reverseTransformedValue(value: AnyObject?) -> AnyObject? {
		
		return NSKeyedUnarchiver.unarchiveObjectWithData(value! as! NSData)
		
	}
	
}
