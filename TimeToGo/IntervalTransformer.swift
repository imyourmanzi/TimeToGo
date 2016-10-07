//
//  IntervalTransformer.swift
//  TimeToGo
//
//  Created by Matteo Manzi on 7/4/15.
//  Copyright (c) 2015 VMM Software. All rights reserved.
//
//	Class used by CoreData to save the array of Intervals in the Trip class

import UIKit

class IntervalTransformer: ValueTransformer {
	
	override class func allowsReverseTransformation() -> Bool {
		
		return true
		
	}
	
	override class func transformedValueClass() -> AnyClass {
		
		return NSArray.classForCoder()
		
	}
	
	override func transformedValue(_ value: Any?) -> Any? {
		
		return NSKeyedArchiver.archivedData(withRootObject: value!)
		
	}
	
	override func reverseTransformedValue(_ value: Any?) -> Any? {
		
		return NSKeyedUnarchiver.unarchiveObject(with: value! as! Data)
		
	}
	
}
