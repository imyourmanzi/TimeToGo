//
//  ScheduleViewController.swift
//  TimeToGo
//
//  Created by Matteo Manzi on 7/4/15.
//  Copyright (c) 2015 VMM Software. All rights reserved.
//

import UIKit
import CoreData
import EventKit

class ScheduleViewController: UIViewController {
	
	// EventKit variables
	let eventStore = EKEventStore()
	
	// CoreData variables
	var moc: NSManagedObjectContext?
	var currentTripName: String!
	var currentTrip: Trip!
	var entries = [Interval]()
	
	// Current VC variables
	var scheduleScroll: UIScrollView!
	let scrollSubview = UIView()
	
	var flightDate: NSDate!
	var intervalDate: NSDate!
	
	let flightIntervalLabel = UILabel()
	let flightIntervalTimeLabel = UILabel()
	
	let dateFormatter = NSDateFormatter()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
		
		let lessHeight = self.tabBarController!.tabBar.frame.height + 44.0 + 44.0
		scheduleScroll = UIScrollView(frame: CGRect(x: 0.0, y: 44.0, width: view.frame.width, height: view.frame.height - lessHeight))
		view.addSubview(scheduleScroll)
		scrollSubview.frame = scheduleScroll.frame
		scheduleScroll.addSubview(scrollSubview)
		scheduleScroll.contentInset = UIEdgeInsetsZero
		
    }
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewWillAppear(animated: Bool) {
		
		// Fetch the current trip from the persistent store and assign the CoreData variables
		currentTripName = (UIApplication.sharedApplication().delegate as! AppDelegate).currentTripNameMaster
		let fetchRequest = NSFetchRequest(entityName: "Trip")
		fetchRequest.predicate = NSPredicate(format: "tripName == %@", currentTripName)
		let trips = (try! moc!.executeFetchRequest(fetchRequest)) as! [Trip]
		currentTrip = trips[0]
		self.entries = currentTrip.entries as! [Interval]
		self.flightDate = currentTrip.flightDate
		
		// Set up the dateFormatter for the flightDate title display
		dateFormatter.dateFormat = "M/d/yy '@' h:mm a"
		self.navigationItem.title = "Flight: \(dateFormatter.stringFromDate(flightDate))"
		
		// Set up labels
		setupLabels()
		
		// Reset dateFormatter for setting interval times
		dateFormatter.dateFormat = "h:mm a"
		intervalDate = flightDate.copy() as! NSDate
		
		for entry in Array(entries.reverse()) {
			
			// Set up the times for each interval
			entry.updateScheduleText()
			intervalDate = NSDate(timeInterval: -(entry.timeIntervalByConvertingTimeValue()), sinceDate: intervalDate)
			entry.startDate = intervalDate
			entry.updateDateTextWithString(dateFormatter.stringFromDate(intervalDate))
			
		}
		
	}
	
	// Set up and add the flight labels and the interval labels
	private func setupLabels() {
		
		// Intervals
		var i: CGFloat = 0.0
		for entry in entries {
			
			entry.createScheduleLabelFromTopSpace(i, onView: scrollSubview)
			entry.createDateLabelOnView(scrollSubview)
			
			i += 50.0
			
		}
		
			// flight interval
		dateFormatter.dateFormat = "h:mm a"
		flightIntervalLabel.translatesAutoresizingMaskIntoConstraints = false
		flightIntervalTimeLabel.translatesAutoresizingMaskIntoConstraints = false
		flightIntervalLabel.text = "Flight Time"
		flightIntervalTimeLabel.text = dateFormatter.stringFromDate(flightDate)
		flightIntervalLabel.font = UIFont.systemFontOfSize(16.0)
		flightIntervalTimeLabel.font = UIFont.systemFontOfSize(16.0)
		scrollSubview.addSubview(flightIntervalLabel)
		scrollSubview.addSubview(flightIntervalTimeLabel)
		
		let leftLabelConstraint = NSLayoutConstraint(item: flightIntervalLabel,
			attribute: NSLayoutAttribute.Left,
			relatedBy: NSLayoutRelation.Equal,
			toItem: scrollSubview,
			attribute: NSLayoutAttribute.LeftMargin,
			multiplier: 1.0,
			constant: 15.0)
		
		let topLabelConstraint = NSLayoutConstraint(item: flightIntervalLabel,
			attribute: NSLayoutAttribute.Top,
			relatedBy: NSLayoutRelation.Equal,
			toItem: scrollSubview,
			attribute: NSLayoutAttribute.TopMargin,
			multiplier: 1.0,
			constant: i)
		
		let rightLabelConstraint = NSLayoutConstraint(item: flightIntervalLabel,
			attribute: NSLayoutAttribute.Right,
			relatedBy: NSLayoutRelation.Equal,
			toItem: scrollSubview,
			attribute: NSLayoutAttribute.CenterX,
			multiplier: 1.0,
			constant: 40.0)
		
		let leftTimeConstraint = NSLayoutConstraint(item: flightIntervalTimeLabel,
			attribute: NSLayoutAttribute.Left,
			relatedBy: NSLayoutRelation.GreaterThanOrEqual,
			toItem: flightIntervalLabel,
			attribute: NSLayoutAttribute.Right,
			multiplier: 1.0,
			constant: 5.0)
		
		let topTimeConstraint = NSLayoutConstraint(item: flightIntervalTimeLabel,
			attribute: NSLayoutAttribute.Top,
			relatedBy: NSLayoutRelation.Equal,
			toItem: flightIntervalLabel,
			attribute: NSLayoutAttribute.Top,
			multiplier: 1.0,
			constant: 0.0)
		
		let rightTimeConstraint = NSLayoutConstraint(item: flightIntervalTimeLabel,
			attribute: NSLayoutAttribute.Right,
			relatedBy: NSLayoutRelation.Equal,
			toItem: scrollSubview,
			attribute: NSLayoutAttribute.RightMargin,
			multiplier: 1.0,
			constant: -15.0)
		
		scrollSubview.addConstraints([leftLabelConstraint, topLabelConstraint, rightLabelConstraint, leftTimeConstraint, topTimeConstraint, rightTimeConstraint])
		i += 50.0
		
		
		// Finish setting up scroll sub-view
		scrollSubview.frame.size.height = i + 80.0
		scheduleScroll.contentSize = scrollSubview.frame.size
		
	}
	
	
	// MARK: - Calendar access
	
	@IBAction func addToCal(sender: UIButton) {
		
		let shareCalVC = storyboard?.instantiateViewControllerWithIdentifier("shareCalNavVC") as! UINavigationController
		
		switch EKEventStore.authorizationStatusForEntityType(EKEntityType.Event) {
			
		case .Authorized:
			self.presentViewController(shareCalVC, animated: true, completion: nil)
			
		case .Denied:
			self.displayAlertWithTitle("Not Allowed", message: "Access to Calendars was denied. To enable, go to Settings>It's Time To Go and turn on Calendars")
			
		case .NotDetermined:
			eventStore.requestAccessToEntityType(EKEntityType.Event, completion: {
				(granted: Bool, error: NSError?) -> Void in
				if granted {
					
					self.presentViewController(shareCalVC, animated: true, completion: nil)
					
				} else {
					
					self.displayAlertWithTitle("Not Allowed", message: "Access to Calendars was denied. To enable, go to Settings>It's Time To Go and turn on Calendars")
					
				}
			})
			
		case .Restricted:
			self.displayAlertWithTitle("Not Allowed", message: "Access to Calendars was restricted.")
			
		}
		
	}
	
	private func displayAlertWithTitle(title: String?, message: String?) {
		
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
		let dismissAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
		alertController.addAction(dismissAction)
		
		presentViewController(alertController, animated: true, completion: nil)
		
	}
	
	
	// MARK: - Navigation
	
	override func viewDidDisappear(animated: Bool) {
		
		// Remove all views from the scrollSubview
		for entry in entries {
			
			entry.removeViewsFromSuperview()
			
		}
		
		flightIntervalLabel.removeFromSuperview()
		flightIntervalTimeLabel.removeFromSuperview()
		
	}
	
}
