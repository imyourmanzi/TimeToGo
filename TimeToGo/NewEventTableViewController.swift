//
//  NewEventTableViewController.swift
//  TimeToGo
//
//  Created by Matteo Manzi on 7/4/15.
//  Copyright (c) 2015 VMM Software. All rights reserved.
//

import UIKit
import CoreData

class NewEventTableViewController: UITableViewController, UITextFieldDelegate, CoreDataHelper {
	
	// Interface Builder variables
	@IBOutlet var eventNameTextfield: UITextField!
	@IBOutlet var dateCell: UITableViewCell!
	@IBOutlet var eventDatePicker: UIDatePicker!
    @IBOutlet var setTodayButton: UIButton!
	
	// CoreData variables
//	var moc: NSManagedObjectContext?
    var allEvents: [Trip] = []
	
	// Current VC variables
    var newEventName: String!
    var eventDate = Date()
    var eventType: String = ""
    var defaultEntries: [Interval] = []
	let dateFormatter = DateFormatter()
	var pickerHidden = true
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
//		// Set the view's background image
//		let backgroundImageView = UIImageView(image: UIImage(named: "lookout"))
//		backgroundImageView.contentMode = UIViewContentMode.scaleAspectFill
//		self.tableView.backgroundView = backgroundImageView
		
		// Get the app's managedObjectContext
//		moc = getContext()
        
		// Set up tripNameTextfield
//		eventNameTextfield.delegate = self
		
        setupDateElements()
        
        // Set up the default entries
        //        print("eventType:", eventType)
        if let fileData = readData(fromCSV: eventType) {
            //            print("fileData:", fileData)
            defaultEntries = getEntries(from: fileData)
        }
        //        for entry in defaultEntries {
        //            print("_Entries_\n", entry.scheduleLabel, entry.stringFromTimeValue())
        //        }
		
	}
    
	override func viewWillAppear(_ animated: Bool) {
        
		// Fetch all of the managed objects from the persistent store and update the table view
//		let fetchAll = NSFetchRequest<Trip>()
//		fetchAll.entity = NSEntityDescription.entity(forEntityName: "Trip", in: moc!)
//		allEvents = (try! moc!.fetch(fetchAll))
		
		// Handle a case of 0 currently saved events
//		if allEvents.count > 0 && self.navigationItem.leftBarButtonItem == nil {
//			
//			self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(cancelNewEvent))
//			let theEventName = allEvents[allEvents.count - 1].tripName
//			UserDefaults.standard.set(theEventName, forKey: "currentTripName")
//			
//		}
		
	}
    
    private func setupDateElements() {
        
        // Set up dateFormatter and assign a default newEventName
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .medium
        newEventName = eventType.replacingOccurrences(of: " ", with: "") + "EventOn_\(dateFormatter.string(from: eventDate))"
        
        // Get current date but with seconds set to 0 and set date to current time zone
        var components = Calendar.current.dateComponents(in: TimeZone.current, from: eventDate)
        components.second = 0
        eventDate = Calendar.current.date(from: components)!
        
        // Set up dateFormatter for use generating label for the eventDatePicker
        dateFormatter.dateFormat = "M/d/yy '@' h:mm a"
        dateCell.detailTextLabel?.text = dateFormatter.string(from: eventDate)
        
    }
	
    
    // MARK: - Manage CSV of default entries
    
    func readData(fromCSV file: String) -> String! {
        
        guard let filePath = Bundle.main.path(forResource: file, ofType: "csv") else {
            return nil
        }
        
        do {
            
            let contents = try String(contentsOfFile: filePath)
            return contents
            
        } catch {
            return nil
        }
        
    }
    
    func getEntries(from data: String) -> [Interval] {
        
        var entries: [Interval] = []
        
        var rows = data.components(separatedBy: "\n")
//        print("Rows:", rows)
        if rows.last == "" {
            rows.removeLast()
        }
        
        for row in rows {
            entries.append(Interval(args: row.components(separatedBy: ",")))
        }
        
        return entries
        
    }

    
    // MARK: - Text and date input delegate
    
	@IBAction func eventNameDidChange(_ sender: UITextField) {
		
		// Update the newEventName varaible with the contents of the textfield
		newEventName = sender.text!.trimmingCharacters(in: CharacterSet.whitespaces)
		
	}
	
	func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		
		// Hide the eventDatePicker if beginning to edit the textfield
		if pickerHidden == false {
			togglePicker()
		}
		
		return true
		
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		
		// Update the newEventName varaible with the contents of the textfield
		newEventName = textField.text!.trimmingCharacters(in: CharacterSet.whitespaces)
		
		textField.resignFirstResponder()
		
		return true
		
	}
	
	@IBAction func eventDateChanged(_ sender: UIDatePicker) {
		
		// Update the event time and its display
		eventDate = sender.date
		dateCell.detailTextLabel?.text = dateFormatter.string(from: eventDatePicker.date)
		
	}
	
    // Change the event date to today when tapped
    @IBAction func setEventDateToday(_ sender: UIButton) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        
        // Get a string of:
        // - the current date
        // - the event's date
        var dateString = formatter.string(from: Date())
        var timeString = formatter.string(from: eventDate)
        
        //        print("dateString before", dateString)
        //        print("timeString before", timeString)
        
        // Of the formatted strings:
        // - get the date (day) from the current
        // - get the time from event's date
        // - Put the date and time together
        let endDateIndex = dateString.index(dateString.startIndex, offsetBy: 10)
        dateString = dateString.substring(to: endDateIndex)
        timeString = timeString.substring(from: endDateIndex)
        let todayString = dateString + timeString
        
        //        print("dateString after", dateString)
        //        print("timeString after", timeString)
        //        print("todayString", todayString)
        
        // Turn the current day into a Date object,
        // the event's time into a Date object,
        // and the default date Jan 1, 2001 into a Date object
        //        formatter.dateFormat = "yyyy-MM-dd"
        //        guard let theDate = formatter.date(from: dateString) else {
        //            return
        //        }
        //        formatter.dateFormat = " HH:mm:ss Z"
        //        guard let theTime = formatter.date(from: timeString) else {
        //            return
        //        }
        //        formatter.dateFormat = "yyyy-MM-dd"
        //        guard let exDate = formatter.date(from: "2000-01-01") else {
        //            return
        //        }
        
        // Parse out the concatenated date and time
        guard let todayDate = formatter.date(from: todayString) else {
            return
        }
        eventDate = todayDate
        
        // Get the number of seconds (a TimeInterval) from Jan 1, 2001 12:00:00 AM until the event's time
        // Then add that amound of time to current date (who's time is 12:00:00 AM)
        //        eventDate = theDate.addingTimeInterval(theTime.timeIntervalSince(exDate))
        
        // Set the UI
        eventDatePicker.setDate(eventDate, animated: true)
        dateCell.detailTextLabel?.text = dateFormatter.string(from: eventDate)
        
    }
	
    
	// MARK: - Table view data source
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if pickerHidden {
			return 2
		} else {
			return 3
		}
		
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		if indexPath.row == 1 {
			togglePicker()
		}
		
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		
		if pickerHidden {
			return tableView.rowHeight
		} else {
			
			if indexPath.row == 2 {
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
			self.tableView.insertRows(at: [IndexPath(row: 2, section: 0)], with: UITableViewRowAnimation.fade)
			eventNameTextfield.resignFirstResponder()
			tableView.isScrollEnabled = false
            setTodayButton.isEnabled = true
			
		} else {
			
			self.tableView.deleteRows(at: [IndexPath(row: 2, section: 0)], with: UITableViewRowAnimation.fade)
			tableView.isScrollEnabled = true
            setTodayButton.isEnabled = false
			
		}
		
		pickerHidden = !pickerHidden
		
		self.tableView.endUpdates()
		
		self.tableView.deselectRow(at: IndexPath(row: 1, section: 0), animated: true)
		
	}
	
	
    // MARK: - Core Data helper
    
    func prepareForUpdateOnCoreData() {
        
        // Follow normal procedure to create the event and display the schedule
        guard let theMoc = moc else {
            displayAlert(title: "Not Saved", message: "Data could not be saved.", on: self, dismissHandler: nil)
            return
        }
        let newEvent = NSEntityDescription.insertNewObject(forEntityName: "Trip", into: theMoc) as! Trip
        newEvent.tripName = newEventName
        newEvent.flightDate = eventDate
        newEvent.eventType = eventType
        newEvent.entries = defaultEntries as NSArray
        
    }
    
    
	// MARK: - Navigation
	
//	func cancelNewEvent(_ sender: UIBarButtonItem) {
//		
//		// Allow the user to cancel out of creating a new event if there are previous and this is the first screen presented
////		let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "mainTabVC") as! UITabBarController
////		mainVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
////		present(mainVC, animated: true, completion: nil)
//        dismiss(animated: true, completion: nil)
//		
//	}
	
	@IBAction func createNewEvent(_ sender: UIBarButtonItem) {
		
		// Test to see if the potential newEventName is the same as any of the other tripNames
		var nameIsUnique = true
		
		for event in allEvents {
			
			if newEventName == event.tripName {
				nameIsUnique = false
			}
			
		}
		
		if nameIsUnique {
			
            performUpdateOnCoreData()
            
//			guard let moc = self.moc else {
//				return
//			}
//			
//			if moc.hasChanges {
//				
//				do {
//					try moc.save()
//				} catch {
//				}
//				
//			}
			
			UserDefaults.standard.set(newEventName, forKey: "currentTripName")
			
			let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "mainTabVC") as! UITabBarController
			mainVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
			present(mainVC, animated: true, completion: nil)
				
		} else {
			
			// Do nothing except display an alert controller
			let nameAlertController = UIAlertController(title: "Cannot Save Event", message: "There is already an event with the same name.", preferredStyle: UIAlertControllerStyle.alert)
			let dismissAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction) in
				nameAlertController.dismiss(animated: true, completion: nil)
			})
			nameAlertController.addAction(dismissAction)
			
			self.present(nameAlertController, animated: true, completion: nil)
			
		}
		
	}
	
	override func viewWillDisappear(_ animated: Bool) {

		eventNameTextfield.resignFirstResponder()
		
	}
	
}
