//
//  SavedTripViewController.swift
//  TravelTimerBasics10
//
//  Created by Matteo Manzi on 7/1/15.
//  Copyright (c) 2015 VMM Softwares. All rights reserved.
//

import UIKit

class SavedTripViewController: UIViewController {
	
	@IBOutlet var tripNameLabel: UILabel!
	@IBOutlet var flightDateLabel: UILabel!
	@IBOutlet var numOfEntriesLabel: UILabel!

	var tripName: String!
	var flightDate: NSDate!
	var numOfEntries: Int!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "M/d/yy '@' h:mm a"
		
		tripNameLabel.text = tripName
		flightDateLabel.text = "Flight Date and Time: \(dateFormatter.stringFromDate(flightDate))"
		numOfEntriesLabel.text = "Number of Intervals: \(String(numOfEntries))"
		
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	@IBAction func loadTrip(sender: UIBarButtonItem) {
		
		(UIApplication.sharedApplication().delegate as! AppDelegate).currentTripNameMaster = self.tripName
		
		let mainTabVC = self.storyboard?.instantiateViewControllerWithIdentifier("mainTabVC") as! UITabBarController
		mainTabVC.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
		self.presentViewController(mainTabVC, animated: true, completion: nil)
		
	}
	
}
