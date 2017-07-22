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
	
    // Interface Builder variables
    @IBOutlet var noEventsLabel: UILabel!
    @IBOutlet var addToCalButton: UIButton!
    
	// EventKit variables
	let eventStore = EKEventStore()
	
	// CoreData variables
	var event: Trip!
    var entries: [Interval] = []
	
	// Current VC variables
	var scheduleScroll: UIScrollView!
	let scrollSubview = UIView()
	
    var eventName: String = UIConstants.NOT_FOUND
	var eventDate: Date!
    var eventTimeLabel: String!
	var intervalDate: Date!
	
	let eventIntervalLabel = UILabel()
	let eventIntervalTimeLabel = UILabel()
	
	let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        
        retrieveCurrentEventName()
        
    }
    
	override func viewWillAppear(_ animated: Bool) {
        
        let showStatusBar = view.frame.size.width < view.frame.height || UIDevice.current.model == "iPad"
        setupScrollView(for: view.frame.size, showingStatusBar: showStatusBar)
        getEventData()
        
	}
    
    private func setupScrollView(for size: CGSize, showingStatusBar statusBarVisible: Bool) {
        
        let topHeight = navigationController!.navigationBar.frame.height + (statusBarVisible ? 20.0 : 0.0)
        let bottomHeight = tabBarController!.tabBar.frame.height + addToCalButton.frame.height
        
        scheduleScroll = UIScrollView(frame: CGRect(x: 0.0,
                                                    y: topHeight,
                                                    width: size.width,
                                                    height: size.height - topHeight - bottomHeight))
        view.addSubview(scheduleScroll)
        
        scrollSubview.frame = CGRect(x: 0.0, y: 25.0, width: scheduleScroll.frame.width, height: scheduleScroll.frame.height - 25.0)
        scheduleScroll.addSubview(scrollSubview)
        scheduleScroll.contentInset = UIEdgeInsets.zero
        
    }
    
    private func getEventData() {
        
        do {
            
            event = try CoreDataConnector.fetchCurrentEvent()
            guard let theEntries = event.entries as? [Interval] else {
                
                guard let parentVC = parent else {
                    return
                }
                displayDataErrorAlert(on: parentVC, dismissHandler: {
                    (_) in
                    
                    guard let mainTabVC = self.storyboard?.instantiateViewController(withIdentifier: IDs.VC_TAB_MAIN) as? UITabBarController else {
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
            
            //  Set the title display to the eventName and date
            dateFormatter.dateFormat = ScheduleConstants.STD_DATE_FORMAT
            self.navigationItem.title = "\(eventName): \(dateFormatter.string(from: eventDate))"
            
            // Set up labels
            setupLabels()
            
            // Set up the dateFormatter for setting interval times
            dateFormatter.dateFormat = ScheduleConstants.STD_DURATION_FORMAT
            intervalDate = (eventDate as NSDate).copy() as! Date
            
            for entry in Array(entries.reversed()) {
                
                // Set up the times for each interval
                entry.updateScheduleText()
                intervalDate = Date(timeInterval: -(entry.getTimeInterval()), since: intervalDate)
                entry.startDate = intervalDate
                entry.updateDateText(to: dateFormatter.string(from: intervalDate))
                
            }
            
            scheduleScroll.isHidden = false
            noEventsLabel.isHidden = true
            addToCalButton.isEnabled = true
            
        } catch CoreDataEventError.returnedNoEvents {
            
            scheduleScroll.isHidden = true
            noEventsLabel.isHidden = false
            addToCalButton.isEnabled = false
        
        } catch {
            
            guard let parentVC = parent else {
                return
            }
            
            displayDataErrorAlert(on: parentVC, dismissHandler: {
                (_) in
                
                guard let mainTabVC = self.storyboard?.instantiateViewController(withIdentifier: IDs.VC_TAB_MAIN) as? UITabBarController else {
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
		dateFormatter.dateFormat = ScheduleConstants.STD_DURATION_FORMAT
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
        super.viewWillTransition(to: size, with: coordinator)
        
        let showStatusBar = (size.width < size.height) || UIDevice.current.model == "iPad"
        
        if scheduleScroll != nil {
            
            clearViews()
            setupScrollView(for: size, showingStatusBar: showStatusBar)
            getEventData()
            
        }
        
    }
	
	
	// MARK: - Calendar access
    
    private func canAccessCalendar() -> Bool {
        
        switch EKEventStore.authorizationStatus(for: EKEntityType.event) {
            
        case .authorized:
            return true
            
        case .denied:
            //displayAlert(title: "Not Allowed", message: "Access to Calendars was denied. To enable, go to Settings > It's Time To Go and turn on Calendars.", on: self, dismissHandler: nil)
            displayGoToSettingsCalendarAlert(on: self)
            return false
            
        case .notDetermined:
            eventStore.requestAccess(to: EKEntityType.event, completion: {
                (granted: Bool, error: Error?) in
                
                if !granted {
                    //self.displayAlert(title: "Not Allowed", message: "Access to Calendars was denied. To enable, go to Settings > It's Time To Go and turn on Calendars.", on: self, dismissHandler: nil)
                    self.displayGoToSettingsCalendarAlert(on: self)
                } else {
                    
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: IDs.SGE_TO_SHARE_CAL, sender: self)
                    }
                    
                }
                
            })
            
            return false
            
        case .restricted:
            displayAlert(title: "Not Allowed", message: "Access to Calendars was restricted. To check permissions, go to Settings > General > Restrictions > Calendars and verify It's Time To Go is on.", on: self, dismissHandler: nil)
            return false
            
        }
        
    }
    
    
    // MARK: - Core Data helper
    
    func retrieveCurrentEventName() {
        
        guard let currentEventName = CoreDataConnector.getCurrentEventName() else {
            return
        }
        
        eventName = currentEventName
        
    }
    
	
	// MARK: - Navigation
    
    // Allows programatic return from ShareToCalTableViewController
    @IBAction func unwindToSchedule(_ segue: UIStoryboardSegue) { }
	
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if identifier == IDs.SGE_TO_SHARE_CAL {
            return canAccessCalendar()
        }
        
        return true
        
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
