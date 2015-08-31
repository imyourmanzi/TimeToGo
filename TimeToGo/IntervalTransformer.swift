//
//  IntervalTransformer.swift
//  TimeToGo
//
//  Created by Matteo Manzi on 7/4/15.
//  Copyright (c) 2015 VMM Software. All rights reserved.
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
