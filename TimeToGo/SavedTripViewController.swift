//
//  SavedTripViewController.swift
//  TravelTimerBasics10
//
//  Created by Matteo Manzi on 7/1/15.
//  Copyright (c) 2015 VMM Softwares. All rights reserved.
//

import UIKit

class SavedTripViewController: UIViewController {
	
	// Interface Builder variables
	@IBOutlet var tripNameLabel: UILabel!
	@IBOutlet var flightDateLabel: UILabel!
	@IBOutlet var numOfEntriesLabel: UILabel!

	// CoreData variables
	var tripName: String!
	var flightDate: NSDate!
	
	// Current VC variables
	var numOfEntries: Int!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		// Set up the dateFormatter
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "M/d/yy '@' h:mm a"
		
		// Set the Interface Builder variables
		tripNameLabel.text = tripName
		flightDateLabel.text = "Flight Date and Time: \(dateFormatter.stringFromDate(flightDate))"
		numOfEntriesLabel.text = "Number of Intervals: \(String(numOfEntries))"
		
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

	@IBAction func loadTrip(sender: UIBarButtonItem) {
		
		// Update currentTripNameMaster in the AppDelegate to the chosen tripName
		(UIApplication.sharedApplication().delegate as! AppDelegate).currentTripNameMaster = self.tripName
		
		// Transition to the Scheudle VC
		let mainTabVC = self.storyboard?.instantiateViewControllerWithIdentifier("mainTabVC") as! UITabBarController
		mainTabVC.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
		self.presentViewController(mainTabVC, animated: true, completion: nil)
		
	}
	
}
