//
//  EditEventTimeTableViewController.swift
//  TimeToGo
//
//  Created by Matteo Manzi on 7/4/15.
//  Copyright (c) 2015 VMM Software. All rights reserved.
//

import UIKit
import CoreData

class EditEventTimeTableViewController: UITableViewController {
	
	// Interface Builder variables
	@IBOutlet var eventDatePicker: UIDatePicker!
	@IBOutlet var dateCell: UITableViewCell!
    @IBOutlet var setTodayButton: UIButton!

	// CoreData variables
	var moc: NSManagedObjectContext?
//	var currentEventName: String!       // Not used
	var currentEvent: Trip!
	
	// Current VC variables
	var pickerHidden = true
	var eventDate = Date()
	let dateFormatter = DateFormatter()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Assign the moc CoreData variable by referencing the AppDelegate's
		moc = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
		
        // Set the time zone
        let components = Calendar.current.dateComponents(in: TimeZone.current, from: eventDate)
        eventDate = Calendar.current.date(from: components)!
        
		// Define the date format and apply it to the flight time display
		dateFormatter.dateFormat = "M/d/yy '@' h:mm a"
		dateCell.detailTextLabel?.text = dateFormatter.string(from: eventDate)
		
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	@IBAction func eventDateChanged(_ sender: UIDatePicker) {
		
		// Update the flight time and its display
		eventDate = sender.date
		dateCell.detailTextLabel?.text = dateFormatter.string(from: eventDatePicker.date)
		
	}
	
    @IBAction func setEventDateToday(_ sender: UIButton) {
        
        // Change the event date to today when tapped
        var dateString = Date().description
        var timeString = eventDate.description
        let endDate = dateString.index(dateString.startIndex, offsetBy: 10)
        dateString = dateString.substring(to: endDate)
        timeString = timeString.substring(from: endDate)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let theDate = formatter.date(from: dateString) else {
            return
        }
        formatter.dateFormat = " HH:mm:ss Z"
        guard let theTime = formatter.date(from: timeString) else {
            return
        }
        formatter.dateFormat = "yyyy-MM-dd"
        guard let exDate = formatter.date(from: "2000-01-01") else {
            return
        }
        
        eventDate = theDate.addingTimeInterval(theTime.timeIntervalSince(exDate))
        eventDatePicker.setDate(eventDate, animated: true)
        dateCell.detailTextLabel?.text = dateFormatter.string(from: eventDatePicker.date)
        
    }
	
    
    // MARK: - Table view data source

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if pickerHidden {
			return 1
		} else {
			return 2
		}
		
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		if indexPath.row == 0 {
			togglePicker()
		}
		
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		
		if pickerHidden {
			return tableView.rowHeight
		} else {
			
			if indexPath.row == 1 {
				return eventDatePicker.frame.height
			} else {
				return tableView.rowHeight
			}
			
		}
		
	}
	
	
	// MARK: - Date picker show/hide
	
	func togglePicker() {
		
		self.tableView.beginUpdates()
		
		if pickerHidden {
			
			eventDatePicker.setDate(eventDate, animated: true)
			self.tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: UITableViewRowAnimation.fade)
			tableView.isScrollEnabled = false
            setTodayButton.isEnabled = true
			
		} else {
			
			self.tableView.deleteRows(at: [IndexPath(row: 1, section: 0)], with: UITableViewRowAnimation.fade)
			tableView.isScrollEnabled = true
            setTodayButton.isEnabled = false
			
		}
		
		pickerHidden = !pickerHidden
		
		self.tableView.endUpdates()
		
		self.tableView.deselectRow(at: IndexPath(row: 0, section: 0), animated: true)
		
	}
	
	
	// MARK: - Navigation
	
	override func viewWillDisappear(_ animated: Bool) {
		
		currentEvent.flightDate = self.eventDate
		
		guard let moc = self.moc else {
			return
		}
		
		if moc.hasChanges {
			
			do {
				try moc.save()
			} catch {
			}
			
		}

	}

}
