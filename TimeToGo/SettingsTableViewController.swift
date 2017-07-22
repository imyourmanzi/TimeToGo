//
//  SettingsTableViewController.swift
//  TimeToGo
//
//  Created by Matt Manzi on 7/4/15.
//  Copyright (c) 2017 MRM Software. All rights reserved.
//

import UIKit
import CoreData
import MessageUI

class SettingsTableViewController: UITableViewController, MFMailComposeViewControllerDelegate, CoreDataHelper {
    
    // Interface Builder variables
	@IBOutlet var eventDateCell: UITableViewCell!
	@IBOutlet var eventNameCell: UITableViewCell!
    @IBOutlet var eventTypeCell: UITableViewCell!
    @IBOutlet var resetButton: UIButton!
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet var deleteAlertPopoverViewAnchor: UIView!
    @IBOutlet var resetAlertPopoverViewAnchor: UIView!
	
    // Core Data variables
	var event: Trip!
    var allEvents: [Trip] = []
	
    // Current VC variables
    var eventName: String = UIConstants.NOT_FOUND
	var eventDate: Date = Date()
    var eventType: String = "Event Type"
    var hasEvents: Bool = false
    
    override func viewDidLoad() {
        
        retrieveCurrentEventName()
        
    }
    
	override func viewWillAppear(_ animated: Bool) {
        
		getEventData()
		
	}
    
    private func getEventData() {
        
        // Fetch the current event and all of the managed objects from the persistent store
        do {
            
            event = try CoreDataConnector.fetchCurrentEvent()
            allEvents = try CoreDataConnector.fetchAllEvents()
            
            hasEvents = true
            
        } catch CoreDataEventError.returnedNoEvents {
            
            hasEvents = false
            return
        
        } catch {
            
            guard let parentVC = parent else {
                return
            }
            
            displayDataErrorAlert(on: parentVC, dismissHandler: nil)
            return
            
        }
        
        // Assign the CoreData variables and update the table view
        eventDate = event.flightDate
        eventType = event.eventType
        setupCellDetails()
        
    }
    
    private func setupCellDetails() {
        
        // Set up the dateFormatter for the eventDate title display
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = UIConstants.STD_DATETIME_FORMAT
        
        eventNameCell.detailTextLabel?.text = eventName
        eventDateCell.detailTextLabel?.text = dateFormatter.string(from: eventDate)
        eventTypeCell.detailTextLabel?.text = eventType
        
        tableView.reloadData()
        
    }
    
    @IBAction func clickedResetSchedule(_ sender: UIButton) {
        
        let resetAlertController = UIAlertController(title: nil, message: "Reset \(eventName) to the default schedule for \(eventType) event?", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let resetAction = UIAlertAction(title: "Reset", style: .destructive) { (action: UIAlertAction) in
            
            let template = EventTemplate(filename: self.eventType)
            self.event.entries = template.getEntries() as NSArray
            
            CoreDataConnector.updateStore(from: self)
            
        }
        
        resetAlertController.addAction(cancelAction)
        resetAlertController.addAction(resetAction)
        
        resetAlertController.popoverPresentationController?.sourceView = resetAlertPopoverViewAnchor
        resetAlertController.popoverPresentationController?.permittedArrowDirections = .up
        
        present(resetAlertController, animated: true, completion: nil)
        
    }
	
	@IBAction func clickedDeleteEvent(_ sender: UIButton) {
		
		// Present an action sheet to confirm deletion of the event and handle the situations that can follow
		let deleteAlertController = UIAlertController(title: nil, message: "Delete \(eventName)?", preferredStyle: .actionSheet)
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(action: UIAlertAction) in
			deleteAlertController.dismiss(animated: true, completion: nil)
		})
		let deleteAction = UIAlertAction(title: "Delete Event", style: .destructive, handler: { (action: UIAlertAction) in
			
            guard let eventIndex = self.allEvents.index(of: self.event) else {
                return
            }
            
            let eventRemoved = self.allEvents.remove(at: eventIndex)
            guard let theMoc = CoreDataConnector.getMoc() else {
                
                self.allEvents.insert(eventRemoved, at: eventIndex)
                return
                
            }
			theMoc.delete(eventRemoved)
            
            CoreDataConnector.updateStore(from: self)
			
			if self.allEvents.count >= 1 {
				
                if let newEventName = self.allEvents.last?.tripName {
                    
                    CoreDataConnector.setCurrentEventName(to: newEventName)
                    self.getEventData()
                    
                }
				
			} else if self.allEvents.isEmpty {
                
                self.hasEvents = false
                
                self.setupCellDetails()
                
			}
			
		})
		
		deleteAlertController.addAction(cancelAction)
		deleteAlertController.addAction(deleteAction)
        
        deleteAlertController.popoverPresentationController?.sourceView = deleteAlertPopoverViewAnchor
        deleteAlertController.popoverPresentationController?.permittedArrowDirections = .up
        
        present(deleteAlertController, animated: true, completion: nil)

	}

	
	// MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 && !hasEvents {
            
            cell.selectionStyle = .none
            eventDateCell.detailTextLabel?.text = "Event Time"
            eventNameCell.detailTextLabel?.text = "Event Name"
            eventTypeCell.detailTextLabel?.text = "Event Type"
            
        }
        
        eventDateCell.textLabel?.isEnabled = hasEvents
        eventNameCell.textLabel?.isEnabled = hasEvents
        eventTypeCell.textLabel?.isEnabled = hasEvents
        
        resetButton.isEnabled = hasEvents
        deleteButton.isEnabled = hasEvents
        
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        if indexPath.section == 0 && !hasEvents {
            return nil
        }
        
        return indexPath
        
    }
    
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
		if indexPath.section == 1 {
			
            switch indexPath.row {
                
            case 0:
                newEmail(to: [SettingConstants.SUPPORT_EMAIL], subject: SettingConstants.SUPPORT_SUBJECT)
            case 1:
                if let homepage = URL(string: SettingConstants.SUPPORT_SITE) { UIApplication.shared.openURL(homepage) }
            default:
                break
                
            }
            
		}
		
		tableView.deselectRow(at: indexPath, animated: true)
		
	}
    
	
	// MARK: - Mail composer delegate
	
	private func newEmail(to recipients: [String], subject: String) {
		
		if MFMailComposeViewController.canSendMail() {
			
			let mailComposer = MFMailComposeViewController()
			mailComposer.mailComposeDelegate = self
			mailComposer.setToRecipients(recipients)
			mailComposer.setSubject(subject)
			
            let gmtTime = Date()
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd HH:mm"
            df.timeZone = TimeZone(identifier: "GMT")
            
			mailComposer.setMessageBody("<p><strong>Subject:</strong> </p>" +
                                        "<p><strong>Detail:</strong> </p>" +
                                        "<p><strong>Device (iPhone 7, iPad Air 2, etc):</strong> </p>" +
                                        "<p>GMT Date and Time: \(df.string(from: gmtTime))<br/>" +
                                        "iOS Version: \(UIDevice.current.systemVersion)<br/>" +
                                        "App Version: \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] ?? "No Version Available")b\(Bundle.main.infoDictionary!["CFBundleVersion"] ?? "No Build Version Available")</p>",
                                        isHTML: true)
			
			present(mailComposer, animated: true, completion: nil)
			
		} else {
            displayAlert(title: "Cannot Send Email", message: "Email is not set up on this device.", on: self, dismissHandler: nil)
		}
		
	}
	
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		
		controller.dismiss(animated: true) { 
			
			if result == MFMailComposeResult.sent || result == MFMailComposeResult.saved {
                self.displayAlert(title: "Thank You!", message: "Your feedback is greatly appreciated! You should receive a reply within a week. Visit the website to find learn a bit more about It's Time To Go.", on: self, dismissHandler: nil)
			}
			
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
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if let timeVC = segue.destination as? EditEventTimeTableViewController {
            
			timeVC.eventDate = eventDate
			timeVC.event = event
			
		} else if let nameVC = segue.destination as? EditEventNameTableViewController {
			
            nameVC.eventName = eventName
			nameVC.event = event
			
        } else if let typeVC = segue.destination as? EditEventTypeTableViewController {
            
            typeVC.eventType = eventType
            typeVC.event = event
            
        }
		
	}
	
}
