//
//  NewEventTableViewController.swift
//  TimeToGo
//
//  Created by Matteo Manzi on 7/4/15.
//  Copyright (c) 2015 VMM Software. All rights reserved.
//

import UIKit
import CoreData

class NewEventTableViewController: UITableViewController, UITextFieldDelegate {
	
	// Interface Builder variables
	@IBOutlet var eventNameTextfield: UITextField!
	@IBOutlet var dateCell: UITableViewCell!
	@IBOutlet var eventDatePicker: UIDatePicker!
    @IBOutlet var setTodayButton: UIButton!
	
	// CoreData variables
	var moc: NSManagedObjectContext?
	var allEvents = [Trip]()
	var eventName: String!
	var eventDate = Date()
	
	// Current VC variables
    var defaultEntries: [Interval] = [
		
//		Interval(mainLabel: "Getting Ready", scheduleLabel: "Wake Up", timeValueHours: 0, timeValueMins: 45),
//		Interval(mainLabel: "Driving To Airport", scheduleLabel: "Leave for Airport", timeValueHours: 0, timeValueMins: 30),
//		Interval(mainLabel: "Arrival to Boarding", scheduleLabel: "Arrive at Airport", timeValueHours: 0, timeValueMins: 45),
//		Interval(mainLabel: "Boarding to Departure", scheduleLabel: "Board Plane", timeValueHours: 0, timeValueMins: 30)
		
	]
	let dateFormatter = DateFormatter()
	var pickerHidden = true
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Set the view's background image
		let backgroundImageView = UIImageView(image: UIImage(named: "lookout"))
		backgroundImageView.contentMode = UIViewContentMode.scaleAspectFill
		self.tableView.backgroundView = backgroundImageView
		
		// Get the app's managedObjectContext
		moc = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
		
		// Set up tripNameTextfield
		eventNameTextfield.delegate = self
		
		// Set up dateFormatter and assign a default tripName
		dateFormatter.dateStyle = .short
		dateFormatter.timeStyle = .medium
		eventName = "TripOn_\(dateFormatter.string(from: eventDate))"
		
		// Get current date but with seconds set to 0
		var components = Calendar.current.dateComponents(in: TimeZone.current, from: eventDate)
		components.second = 0
		eventDate = Calendar.current.date(from: components)!
		
		// Set up dateFormatter for use generating label for the flightDatePicker
		dateFormatter.dateFormat = "M/d/yy '@' h:mm a"
		dateCell.detailTextLabel?.text = dateFormatter.string(from: eventDate)
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		
		// Fetch all of the managed objects from the persistent store and update the table view
		let fetchAll = NSFetchRequest<Trip>()
		fetchAll.entity = NSEntityDescription.entity(forEntityName: "Trip", in: moc!)
		allEvents = (try! moc!.fetch(fetchAll))
		
		// Handle a case of 0 currently saved trips
		if allEvents.count > 0 && self.navigationItem.leftBarButtonItem == nil {
			
			self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(cancelNewEvent))
			let theTripName = allEvents[allEvents.count - 1].tripName
			UserDefaults.standard.set(theTripName, forKey: "currentTripName")
			
		}
		
	}
	
	@IBAction func eventNameDidChange(_ sender: UITextField) {
		
		// Update the tripName varaible with the contents of the textfield
		eventName = sender.text!.trimmingCharacters(in: CharacterSet.whitespaces)
		
	}
	
	func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		
		// Hide the flightDatePicker if beginning to edit the textfield
		if pickerHidden == false {
			togglePicker()
		}
		
		return true
		
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		
		// Update the tripName varaible with the contents of the textfield
		eventName = textField.text!.trimmingCharacters(in: CharacterSet.whitespaces)
		
		textField.resignFirstResponder()
		
		return true
		
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
	
	
	// MARK: - Navigation
	
	func cancelNewEvent(_ sender: UIBarButtonItem) {
		
		// Allow the user to cancel out of creating a new trip if there are previous and this is the first screen presented
//		let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "mainTabVC") as! UITabBarController
//		mainVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
//		present(mainVC, animated: true, completion: nil)
        dismiss(animated: true, completion: nil)
		
	}
	
	@IBAction func createNewEvent(_ sender: UIBarButtonItem) {
		
		// Test to see if the potential tripName is the same as any of the other tripNames
		var nameIsUnique = true
		
		for event in allEvents {
			
			if self.eventName == event.tripName {
				nameIsUnique = false
			}
			
		}
		
		if nameIsUnique {
			
			// Follow normal procedure to create the trip and display the schedule
			let newEvent = NSEntityDescription.insertNewObject(forEntityName: "Trip", into: moc!) as! Trip
			newEvent.tripName = self.eventName
			newEvent.flightDate = self.eventDate
			newEvent.entries = self.defaultEntries as NSArray
			guard let moc = self.moc else {
				return
			}
			
			if moc.hasChanges {
				
				do {
					try moc.save()
				} catch {
				}
				
			}
			
			UserDefaults.standard.set(self.eventName, forKey: "currentTripName")
			
			let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "mainTabVC") as! UITabBarController
			mainVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
			present(mainVC, animated: true, completion: nil)
				
		} else {
			
			// Do nothing except display an alert controller
			let nameAlertController = UIAlertController(title: "Cannot Save Trip", message: "There is already a trip with the same name.", preferredStyle: UIAlertControllerStyle.alert)
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
