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

class ScheduleViewController: UIViewController, CoreDataHelper {
	
	// EventKit variables
	let eventStore = EKEventStore()
	
	// CoreData variables
//	var moc: NSManagedObjectContext?
//	var eventName: String!
	var event: Trip!
    var entries: [Interval] = []
	
	// Current VC variables
	var scheduleScroll: UIScrollView!
	let scrollSubview = UIView()
	
	var eventDate: Date!
	var intervalDate: Date!
	
	let eventIntervalLabel = UILabel()
	let eventIntervalTimeLabel = UILabel()
	
	let dateFormatter = DateFormatter()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Get the app's managedObjectContext
//		moc = getContext()
		
		let lessHeight = self.tabBarController!.tabBar.frame.height + 64.0 + 44.0
		scheduleScroll = UIScrollView(frame: CGRect(x: 0.0, y: 64.0, width: view.frame.width, height: view.frame.height - lessHeight))
		view.addSubview(scheduleScroll)
		scrollSubview.frame = CGRect(x: 0.0, y: 30.0, width: scheduleScroll.frame.width, height: scheduleScroll.frame.height)
		scheduleScroll.addSubview(scrollSubview)
		scheduleScroll.contentInset = UIEdgeInsets.zero
		
    }
	
	override func viewWillAppear(_ animated: Bool) {
		
		// Fetch the current event from the persistent store and assign the CoreData variables
//		eventName = UserDefaults.standard.object(forKey: "currentTripName") as! String
//		let fetchRequest = NSFetchRequest<Trip>(entityName: "Trip")
//		fetchRequest.predicate = NSPredicate(format: "tripName == %@", eventName)
//		let events = (try! moc!.fetch(fetchRequest))
//		event = events[0]
//		self.entries = event.entries as! [Interval]
//		self.eventDate = event.flightDate as Date!
		
        do {
            
            event = try fetchCurrentEvent()
            guard let theEntries = event.entries as? [Interval] else {
                // TODO: display alert vc saying data was not found, etc.
                return
            }
            entries = theEntries
            eventDate = event.flightDate
            
            //  Set the title display to the eventName
            self.navigationItem.title = eventName
            
            // Set up labels
            setupLabels()
            
            // Set up the dateFormatter for setting interval times
            dateFormatter.dateFormat = "h:mm a"
            intervalDate = (eventDate as NSDate).copy() as! Date
            
            for entry in Array(entries.reversed()) {
                
                // Set up the times for each interval
                entry.updateScheduleText()
                intervalDate = Date(timeInterval: -(entry.timeIntervalByConvertingTimeValue()), since: intervalDate)
                entry.startDate = intervalDate
                entry.updateDateTextWithString(dateFormatter.string(from: intervalDate))
                
            }
            
        } catch {
            // TODO: display alert vc saying data was not found, etc.
        }
        
	}
	
	// Set up and add the event labels and the interval labels
	private func setupLabels() {
		
		// Intervals
		var i: CGFloat = 0.0
		for entry in entries {
			
			entry.createScheduleLabelFromTopSpace(i, onView: scrollSubview)
			entry.createDateLabelOnView(scrollSubview)
			
			i += 50.0
			
		}
		
			// event interval
		dateFormatter.dateFormat = "h:mm a"
		eventIntervalLabel.translatesAutoresizingMaskIntoConstraints = false
		eventIntervalTimeLabel.translatesAutoresizingMaskIntoConstraints = false
		eventIntervalLabel.text = "Event Time"
		eventIntervalTimeLabel.text = dateFormatter.string(from: eventDate)
		eventIntervalLabel.font = UIFont.systemFont(ofSize: 16.0)
		eventIntervalTimeLabel.font = UIFont.systemFont(ofSize: 16.0)
		scrollSubview.addSubview(eventIntervalLabel)
		scrollSubview.addSubview(eventIntervalTimeLabel)
		
		let leftLabelConstraint = NSLayoutConstraint(item: eventIntervalLabel,
			attribute: NSLayoutAttribute.left,
			relatedBy: NSLayoutRelation.equal,
			toItem: scrollSubview,
			attribute: NSLayoutAttribute.leftMargin,
			multiplier: 1.0,
			constant: 15.0)
		
		let topLabelConstraint = NSLayoutConstraint(item: eventIntervalLabel,
			attribute: NSLayoutAttribute.top,
			relatedBy: NSLayoutRelation.equal,
			toItem: scrollSubview,
			attribute: NSLayoutAttribute.topMargin,
			multiplier: 1.0,
			constant: i)
		
		let rightLabelConstraint = NSLayoutConstraint(item: eventIntervalLabel,
			attribute: NSLayoutAttribute.right,
			relatedBy: NSLayoutRelation.equal,
			toItem: scrollSubview,
			attribute: NSLayoutAttribute.centerX,
			multiplier: 1.0,
			constant: 40.0)
		
		let leftTimeConstraint = NSLayoutConstraint(item: eventIntervalTimeLabel,
			attribute: NSLayoutAttribute.left,
			relatedBy: NSLayoutRelation.greaterThanOrEqual,
			toItem: eventIntervalLabel,
			attribute: NSLayoutAttribute.right,
			multiplier: 1.0,
			constant: 5.0)
		
		let topTimeConstraint = NSLayoutConstraint(item: eventIntervalTimeLabel,
			attribute: NSLayoutAttribute.top,
			relatedBy: NSLayoutRelation.equal,
			toItem: eventIntervalLabel,
			attribute: NSLayoutAttribute.top,
			multiplier: 1.0,
			constant: 0.0)
		
		let rightTimeConstraint = NSLayoutConstraint(item: eventIntervalTimeLabel,
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
	
//	@IBAction func addToCal(_ sender: UIButton) {
//		
//		let shareCalVC = storyboard?.instantiateViewController(withIdentifier: "shareCalNavVC") as! UINavigationController
//		
//		
//		
//	}
	
	private func displayAlertWithTitle(_ title: String?, message: String?) {
		
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
		alertController.addAction(dismissAction)
		
		present(alertController, animated: true, completion: nil)
		
	}
	
	
	// MARK: - Navigation
    
    @IBAction func unwindToSchedule(_ segue: UIStoryboardSegue) {
        
        // TODO: display whether the save was successful or not (if sender is true or false
        
    }
	
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        var shouldSegue = false
        
        if identifier == "toShareToCal" {
            
            switch EKEventStore.authorizationStatus(for: EKEntityType.event) {
                
            case .authorized:
                shouldSegue = true
                
            case .denied:
                shouldSegue = false
                displayAlertWithTitle("Not Allowed", message: "Access to Calendars was denied. To enable, go to Settings>It's Time To Go and turn on Calendars")
                
            case .notDetermined:
                eventStore.requestAccess(to: EKEntityType.event, completion: {
                    (granted: Bool, error: Error?) -> Void in
                    if granted {
                        shouldSegue = true
                    } else {
                        shouldSegue = false
                        self.displayAlertWithTitle("Not Allowed", message: "Access to Calendars was denied. To enable, go to Settings>It's Time To Go and turn on Calendars")
                    }
                })
                
            case .restricted:
                shouldSegue = false
                displayAlertWithTitle("Not Allowed", message: "Access to Calendars was restricted.")
                
            }
            
        }
        
        return shouldSegue
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let shareToCalVC = segue.destination as? ShareToCalTableViewController {
//            print("preparing for share")
            
//            print("event:", event)
            shareToCalVC.event = event
            
        }
        
    }
    
	override func viewDidDisappear(_ animated: Bool) {
		
		// Remove all views from the scrollSubview
		for entry in entries {
			
			entry.removeViewsFromSuperview()
			
		}
		
		eventIntervalLabel.removeFromSuperview()
		eventIntervalTimeLabel.removeFromSuperview()
		
	}
	
}
