//
//  ScheduleViewController.swift
//  TimeToGo
//
//  Created by Matt Manzi on 7/4/15.
//  Copyright (c) 2017 MRM Software. All rights reserved.
//

import UIKit
import CoreData
import EventKit

class ScheduleViewController: UIViewController, CoreDataHelper {
	
	// EventKit variables
	let eventStore = EKEventStore()
	
	// CoreData variables
	var event: Trip!
    var entries: [Interval] = []
	
	// Current VC variables
	var scheduleScroll: UIScrollView!
	let scrollSubview = UIView()
	
	var eventDate: Date!
    var eventTimeLabel: String!
	var intervalDate: Date!
	
	let eventIntervalLabel = UILabel()
	let eventIntervalTimeLabel = UILabel()
	
	let dateFormatter = DateFormatter()
    
	override func viewWillAppear(_ animated: Bool) {
		
        setupScrollView(for: view.frame.size)
        getEventData()
        
	}
    
    private func setupScrollView(for size: CGSize) {
        
        let lessHeight = self.tabBarController!.tabBar.frame.height + 64.0 + 44.0
        scheduleScroll = UIScrollView(frame: CGRect(x: 0.0, y: 64.0, width: size.width, height: size.height - lessHeight))
        view.addSubview(scheduleScroll)
        scrollSubview.frame = CGRect(x: 0.0, y: 30.0, width: scheduleScroll.frame.width, height: scheduleScroll.frame.height)
        scheduleScroll.addSubview(scrollSubview)
        scheduleScroll.contentInset = UIEdgeInsets.zero
        
    }
    
    private func getEventData() {
        
        do {
            
            event = try fetchCurrentEvent()
            guard let theEntries = event.entries as? [Interval] else {
                
                guard let parentVC = parent else {
                    return
                }
                displayDataErrorAlert(on: parentVC, dismissHandler: {
                    (_) in
                    
                    guard let mainTabVC = self.storyboard?.instantiateViewController(withIdentifier: "mainTabVC") as? UITabBarController else {
                        return
                    }
                    
                    mainTabVC.modalTransitionStyle = .crossDissolve
                    self.present(mainTabVC, animated: true, completion: nil)
                
                })
                
                return
                
            }
            entries = theEntries
            eventDate = event.flightDate
            eventTimeLabel = event.eventTimeLabel
            
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
                intervalDate = Date(timeInterval: -(entry.getTimeInterval()), since: intervalDate)
                entry.startDate = intervalDate
                entry.updateDateText(to: dateFormatter.string(from: intervalDate))
                
            }
            
        } catch {
            
            guard let parentVC = parent else {
                return
            }
            
            displayDataErrorAlert(on: parentVC, dismissHandler: {
                (_) in
                
                guard let mainTabVC = self.storyboard?.instantiateViewController(withIdentifier: "mainTabVC") as? UITabBarController else {
                    return
                }
                
                mainTabVC.modalTransitionStyle = .crossDissolve
                self.present(mainTabVC, animated: true, completion: nil)
                
            })
            
        }
        
    }
	
	// Set up and add the event labels and the interval labels
	private func setupLabels() {
		
		// Intervals
		var i: CGFloat = 0.0
		for entry in entries {
			
            entry.createScheduleLabel(withSpace: i, on: scrollSubview)
            entry.createDateLabel(on: scrollSubview)
			
			i += 50.0
			
		}
		
			// event interval
		dateFormatter.dateFormat = "h:mm a"
		eventIntervalLabel.translatesAutoresizingMaskIntoConstraints = false
		eventIntervalTimeLabel.translatesAutoresizingMaskIntoConstraints = false
		eventIntervalLabel.text = eventTimeLabel
		eventIntervalTimeLabel.text = dateFormatter.string(from: eventDate)
		eventIntervalLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
		eventIntervalTimeLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
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
    
    private func clearViews() {
        
        // Remove all views from the scrollSubview
        for entry in entries {
            entry.removeViewsFromSuperview()
        }
        
        eventIntervalLabel.removeFromSuperview()
        eventIntervalTimeLabel.removeFromSuperview()
        
        scheduleScroll.removeFromSuperview()
        
    }
    
    // Detect orientation change and adapt scheduleScroll accordingly
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        clearViews()
        setupScrollView(for: size)
        getEventData()
        
    }
	
	
	// MARK: - Calendar access
    
    private func canAccessCalendar() -> Bool {
        
        var canAccess = false
        
        switch EKEventStore.authorizationStatus(for: EKEntityType.event) {
            
        case .authorized:
            canAccess = true
            
        case .denied:
            canAccess = false
            displayAlert(title: "Not Allowed", message: "Access to Calendars was denied. To enable, go to Settings>It's Time To Go and turn on Calendars.", on: self, dismissHandler: nil)
            
        case .notDetermined:
            eventStore.requestAccess(to: EKEntityType.event, completion: {
                (granted: Bool, error: Error?) in
                
                if granted {
                    canAccess = true
                } else {
                    
                    canAccess = false
                    self.displayAlert(title: "Not Allowed", message: "Access to Calendars was denied. To enable, go to Settings>It's Time To Go and turn on Calendars.", on: self, dismissHandler: nil)
                    
                }
                
            })
            
        case .restricted:
            canAccess = false
            displayAlert(title: "Not Allowed", message: "Access to Calendars was restricted.", on: self, dismissHandler: nil)
            
        }
        
        return canAccess
        
    }
    
	
	// MARK: - Navigation
    
    // Allows programatic return from ShareToCalTableViewController
    @IBAction func unwindToSchedule(_ segue: UIStoryboardSegue) { }
	
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if identifier == "toShareToCal" && canAccessCalendar() {
            return true
        } else if identifier != "toShareToCal" {
            return true
        }
        
        return false
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let shareToCalVC = segue.destination as? ShareToCalTableViewController {
            shareToCalVC.event = event
        }
        
    }
    
	override func viewDidDisappear(_ animated: Bool) {
		
		clearViews()
		
	}
	
}
