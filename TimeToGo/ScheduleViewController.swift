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
	
	var flightDate: Date!
	var intervalDate: Date!
	
	let flightIntervalLabel = UILabel()
	let flightIntervalTimeLabel = UILabel()
	
	let dateFormatter = DateFormatter()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Get the app's managedObjectContext
		moc = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
		
		let lessHeight = self.tabBarController!.tabBar.frame.height + 64.0 + 44.0
		scheduleScroll = UIScrollView(frame: CGRect(x: 0.0, y: 64.0, width: view.frame.width, height: view.frame.height - lessHeight))
		view.addSubview(scheduleScroll)
		scrollSubview.frame = CGRect(x: 0.0, y: 30.0, width: scheduleScroll.frame.width, height: scheduleScroll.frame.height)
		scheduleScroll.addSubview(scrollSubview)
		scheduleScroll.contentInset = UIEdgeInsets.zero
		
    }
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewWillAppear(_ animated: Bool) {
		
		// Fetch the current trip from the persistent store and assign the CoreData variables
		currentTripName = UserDefaults.standard.object(forKey: "currentTripName") as! String
		let fetchRequest = NSFetchRequest<Trip>(entityName: "Trip")
		fetchRequest.predicate = NSPredicate(format: "tripName == %@", currentTripName)
		let trips = (try! moc!.fetch(fetchRequest))
		currentTrip = trips[0]
		self.entries = currentTrip.entries as! [Interval]
		self.flightDate = currentTrip.flightDate as Date!
		
        //  Set the title display to the currentTripName
		self.navigationItem.title = currentTripName
		
		// Set up labels
		setupLabels()
		
		// Set up the dateFormatter for setting interval times
		dateFormatter.dateFormat = "h:mm a"
		intervalDate = (flightDate as NSDate).copy() as! Date
		
		for entry in Array(entries.reversed()) {
			
			// Set up the times for each interval
			entry.updateScheduleText()
			intervalDate = Date(timeInterval: -(entry.timeIntervalByConvertingTimeValue()), since: intervalDate)
			entry.startDate = intervalDate
			entry.updateDateTextWithString(dateFormatter.string(from: intervalDate))
			
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
		flightIntervalTimeLabel.text = dateFormatter.string(from: flightDate)
		flightIntervalLabel.font = UIFont.systemFont(ofSize: 16.0)
		flightIntervalTimeLabel.font = UIFont.systemFont(ofSize: 16.0)
		scrollSubview.addSubview(flightIntervalLabel)
		scrollSubview.addSubview(flightIntervalTimeLabel)
		
		let leftLabelConstraint = NSLayoutConstraint(item: flightIntervalLabel,
			attribute: NSLayoutAttribute.left,
			relatedBy: NSLayoutRelation.equal,
			toItem: scrollSubview,
			attribute: NSLayoutAttribute.leftMargin,
			multiplier: 1.0,
			constant: 15.0)
		
		let topLabelConstraint = NSLayoutConstraint(item: flightIntervalLabel,
			attribute: NSLayoutAttribute.top,
			relatedBy: NSLayoutRelation.equal,
			toItem: scrollSubview,
			attribute: NSLayoutAttribute.topMargin,
			multiplier: 1.0,
			constant: i)
		
		let rightLabelConstraint = NSLayoutConstraint(item: flightIntervalLabel,
			attribute: NSLayoutAttribute.right,
			relatedBy: NSLayoutRelation.equal,
			toItem: scrollSubview,
			attribute: NSLayoutAttribute.centerX,
			multiplier: 1.0,
			constant: 40.0)
		
		let leftTimeConstraint = NSLayoutConstraint(item: flightIntervalTimeLabel,
			attribute: NSLayoutAttribute.left,
			relatedBy: NSLayoutRelation.greaterThanOrEqual,
			toItem: flightIntervalLabel,
			attribute: NSLayoutAttribute.right,
			multiplier: 1.0,
			constant: 5.0)
		
		let topTimeConstraint = NSLayoutConstraint(item: flightIntervalTimeLabel,
			attribute: NSLayoutAttribute.top,
			relatedBy: NSLayoutRelation.equal,
			toItem: flightIntervalLabel,
			attribute: NSLayoutAttribute.top,
			multiplier: 1.0,
			constant: 0.0)
		
		let rightTimeConstraint = NSLayoutConstraint(item: flightIntervalTimeLabel,
			attribute: NSLayoutAttribute.right,
			relatedBy: NSLayoutRelation.equal,
			toItem: scrollSubview,
			attribute: NSLayoutAttribute.rightMargin,
			multiplier: 1.0,
			constant: -15.0)
		
		scrollSubview.addConstraints([leftLabelConstraint, topLabelConstraint, rightLabelConstraint, leftTimeConstraint, topTimeConstraint, rightTimeConstraint])
		i += 50.0
		
		
		// Finish setting up scroll sub-view
		scrollSubview.frame.size.height = i + 30.0
		scheduleScroll.contentSize = scrollSubview.frame.size
		
	}
	
	
	// MARK: - Calendar access
	
	@IBAction func addToCal(_ sender: UIButton) {
		
		let shareCalVC = storyboard?.instantiateViewController(withIdentifier: "shareCalNavVC") as! UINavigationController
		
		switch EKEventStore.authorizationStatus(for: EKEntityType.event) {
			
		case .authorized:
			self.present(shareCalVC, animated: true, completion: nil)
			
		case .denied:
			self.displayAlertWithTitle("Not Allowed", message: "Access to Calendars was denied. To enable, go to Settings>It's Time To Go and turn on Calendars")
			
		case .notDetermined:
			eventStore.requestAccess(to: EKEntityType.event, completion: {
				(granted: Bool, error: Error?) -> Void in
				if granted {
					
					self.present(shareCalVC, animated: true, completion: nil)
					
				} else {
					
					self.displayAlertWithTitle("Not Allowed", message: "Access to Calendars was denied. To enable, go to Settings>It's Time To Go and turn on Calendars")
					
				}
			})
			
		case .restricted:
			self.displayAlertWithTitle("Not Allowed", message: "Access to Calendars was restricted.")
			
		}
		
	}
	
	private func displayAlertWithTitle(_ title: String?, message: String?) {
		
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
		alertController.addAction(dismissAction)
		
		present(alertController, animated: true, completion: nil)
		
	}
	
	
	// MARK: - Navigation
	
	override func viewDidDisappear(_ animated: Bool) {
		
		// Remove all views from the scrollSubview
		for entry in entries {
			
			entry.removeViewsFromSuperview()
			
		}
		
		flightIntervalLabel.removeFromSuperview()
		flightIntervalTimeLabel.removeFromSuperview()
		
	}
	
}
