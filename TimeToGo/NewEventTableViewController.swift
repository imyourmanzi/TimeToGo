//
//  NewEventTableViewController.swift
//  TimeToGo
//
//  Created by Matt Manzi on 7/4/15.
//  Copyright (c) 2017 MRM Software. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "datePickerCell"

class NewEventTableViewController: UITableViewController, UITextFieldDelegate, CoreDataHelper {
    
	// Interface Builder variables
	@IBOutlet var eventNameTextfield: UITextField!
	@IBOutlet var dateCell: UITableViewCell!
	@IBOutlet var eventDatePicker: UIDatePicker!
    @IBOutlet var setTodayButton: UIButton!
	
	// CoreData variables
    var allEvents: [Trip] = []
	
	// Current VC variables
    var newEventName: String = ""
    var eventDate = Date()
    var eventType: String = ""
    var eventTimeLabel: String = ""
    var template: EventTemplate = EventTemplate()
    var defaultEntries: [Interval] = []
	let dateFormatter = DateFormatter()
	var pickerHidden = true
	
	override func viewDidLoad() {
		super.viewDidLoad()
        
        setupDateElements()
        
        // Set up the default entries
        template = EventTemplate(filename: eventType)
        defaultEntries = template.getEntries()
        
	}
    
    private func setupDateElements() {
        
        // Set up dateFormatter and assign a default newEventName
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .medium
        newEventName = eventType + " Event at \(dateFormatter.string(from: eventDate))"
        
        // Get current date but with seconds set to 0 and set date to current time zone
        var components = Calendar.current.dateComponents(in: TimeZone.current, from: eventDate)
        components.second = 0
        eventDate = Calendar.current.date(from: components)!
        
        // Set up dateFormatter for use generating label for the eventDatePicker
        dateFormatter.dateFormat = UIConstants.STD_DATETIME_FORMAT
        dateCell.detailTextLabel?.text = dateFormatter.string(from: eventDate)
        
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
        
        // Of the formatted strings:
        // - get the date (day) from the current
        // - get the time from event's date
        // - Put the date and time together
        let endDateIndex = dateString.index(dateString.startIndex, offsetBy: 10)
        dateString = dateString.substring(to: endDateIndex)
        timeString = timeString.substring(from: endDateIndex)
        let todayString = dateString + timeString
        
        // Parse out the concatenated date and time
        guard let todayDate = formatter.date(from: todayString) else {
            return
        }
        eventDate = todayDate
        
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
    
    func prepareForUpdate() {
        
        // Follow normal procedure to create the event and display the schedule
        guard let theMoc = CoreDataConnector.getMoc() else {
            displayAlert(title: "Not Saved", message: "Data could not be saved.", on: self, dismissHandler: nil)
            return
        }
        
        let newEvent = NSEntityDescription.insertNewObject(forEntityName: CoreDataConstants.ENTITY_NAME, into: theMoc) as! Trip
        newEvent.tripName = newEventName
        newEvent.flightDate = eventDate
        newEvent.eventType = eventType
        newEvent.eventTimeLabel = eventTimeLabel
        newEvent.entries = defaultEntries as NSArray
        
    }
    
    
	// MARK: - Navigation
	
	@IBAction func createNewEvent(_ sender: UIBarButtonItem) {
		
		// Test to see if the potential newEventName is the same as any of the other tripNames
		var nameIsUnique = true
		
		for event in allEvents {
			
			if newEventName == event.tripName {
				nameIsUnique = false
			}
			
		}
		
		if nameIsUnique {
			
            CoreDataConnector.updateStore(from: self)
            CoreDataConnector.setCurrentEventName(to: newEventName)
			
            guard let mainTabVC = self.storyboard?.instantiateViewController(withIdentifier: IDs.VC_TAB_MAIN) as? UITabBarController else {
                return
            }
            
			mainTabVC.modalTransitionStyle = .crossDissolve
            mainTabVC.selectedIndex = 1
            
			present(mainTabVC, animated: true, completion: nil)
				
		} else {
            
            // Do nothing except display an alert controller
            displayAlert(title: "Cannot Save Event", message: "There is already an event with the same name.", on: self, dismissHandler: nil)
			
		}
		
	}
	
	override func viewWillDisappear(_ animated: Bool) {

		eventNameTextfield.resignFirstResponder()
		
	}
	
}
