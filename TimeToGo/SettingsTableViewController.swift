//
//  SettingsTableViewController.swift
//  TimeToGo
//
//  Created by Matteo Manzi on 7/4/15.
//  Copyright (c) 2015 VMM Software. All rights reserved.
//

import UIKit
import CoreData
import MessageUI

class SettingsTableViewController: UITableViewController, MFMailComposeViewControllerDelegate, CoreDataHelper {

    // Interface Builder variables
	@IBOutlet var eventDateCell: UITableViewCell!
	@IBOutlet var eventNameCell: UITableViewCell!
    @IBOutlet var deleteAlertPopoverViewAnchor: UIView!
	
    // Core Data variables
//	var moc: NSManagedObjectContext?
//	var eventName: String!
	var event: Trip!
//	var eventIndex: Int!
    var allEvents: [Trip] = []
	
    // Current VC variables
	var eventDate: Date!
//	var eventName: String!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		// Assign the moc CoreData variable by referencing the AppDelegate's
//		moc = getContext()
		
    }
    
	override func viewWillAppear(_ animated: Bool) {
		
//		eventName = UserDefaults.standard.object(forKey: "currentTripName") as! String
//		let fetchRequest = NSFetchRequest<Trip>(entityName: "Trip")
//		fetchRequest.predicate = NSPredicate(format: "tripName == %@", eventName)
//		let events = (try! moc!.fetch(fetchRequest))
//		event = events[0]

        // Fetch the current event from the persistent store and assign the CoreData variables
        do {
            
            event = try fetchCurrentEvent()
            eventDate = event.flightDate
            
            // Set up the dateFormatter for the eventDate title display
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "M/d/yy '@' h:mm a"
            eventDateCell.detailTextLabel?.text = dateFormatter.string(from: self.eventDate)
            
        } catch {
            // TODO: implement alert vc saying couldn't find event
        }
        
//		self.eventName = event.tripName
		
		eventNameCell.detailTextLabel?.text = eventName
		
//		let fetchAll = NSFetchRequest<Trip>(entityName: "Trip")
//		allEvents = (try! moc!.fetch(fetchAll))
        
        // Fetch all of the managed objects from the persistent store and update the table view
        do {
            
            allEvents = try fetchAllEvents()
            tableView.reloadData()
            
        } catch {
            // TODO: implement alert vc saying no events found
        }
		
		
	}
	
	@IBAction func clickedDeleteEvent(_ sender: UIButton) {
		
		// Present an action sheet to confirm deletion of the event and handle the situations that can follow
		let deleteAlertController = UIAlertController(title: nil, message: "Delete \(eventName!)?", preferredStyle: .actionSheet)
		let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {(action: UIAlertAction) in
			deleteAlertController.dismiss(animated: true, completion: nil)
		})
		let deleteAction = UIAlertAction(title: "Delete Event", style: UIAlertActionStyle.destructive, handler: { (action: UIAlertAction) in
			
            guard let eventIndex = self.allEvents.index(of: self.event) else {
                return
            }
            
            let eventRemoved = self.allEvents.remove(at: eventIndex)
            guard let theMoc = self.moc else {
                
                self.allEvents.insert(eventRemoved, at: eventIndex)
                return
                
            }
			theMoc.delete(eventRemoved)
            self.performUpdateOnCoreData()
//			do {
//				try self.moc!.save()
//			} catch {
//			}
			
			if self.allEvents.count >= 1 {
				
                if let newEventName = self.allEvents.last?.tripName {
                    
                    UserDefaults.standard.set(newEventName, forKey: "currentTripName")
                    self.viewWillAppear(true)
                    
                }
				
				
			} else if self.allEvents.count <= 0 {
				
				let semiDestVC = self.storyboard?.instantiateViewController(withIdentifier: "newTripNavVC") as! UINavigationController
				let destVC = semiDestVC.viewControllers[0] as! NewEventTableViewController
				destVC.hidesBottomBarWhenPushed = true
				destVC.navigationItem.hidesBackButton = true
				self.show(destVC, sender: self)
				
			}
			
		})
		
		deleteAlertController.addAction(cancelAction)
		deleteAlertController.addAction(deleteAction)
        
        deleteAlertController.popoverPresentationController?.sourceView = deleteAlertPopoverViewAnchor
        
        present(deleteAlertController, animated: true, completion: nil)

	}
	
	private func displayAlertWithTitle(_ title: String?, message: String?) {
		
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let dismiss = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
		alert.addAction(dismiss)
		
		self.present(alert, animated: true, completion: nil)
		
	}

	
	// MARK: - Table view data source
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		if indexPath.section == 1 {
			
			if indexPath.row == 0 {
				
				newEmailToRecipients(["timetogosupport@narwhalsandcode.com"], subject: "Question/Comment/Concern with It's Time To Go")
				
			} else if indexPath.row == 1 {
			
				if let homepage = URL(string: "https://www.narwhalsandcode.com/apps/#time-to-go") {
					UIApplication.shared.openURL(homepage)
				}
				
			}
			
		}
		
		tableView.deselectRow(at: indexPath, animated: true)
		
	}
	
	
	// MARK: - Mail composer delegate
	
	private func newEmailToRecipients(_ recipients: [String], subject: String) {
		
		if MFMailComposeViewController.canSendMail() {
			
			let mailComposer = MFMailComposeViewController()
			mailComposer.mailComposeDelegate = self
			mailComposer.setToRecipients(recipients)
			mailComposer.setSubject(subject)
			
			mailComposer.setMessageBody("<p><strong>Issue:</strong> </p><p><strong>Detail:</strong> </p><br /><p>Date and time: \(Date())<br />Device Model: [PLEASE ADD]<br />iOS Version: \(UIDevice.current.systemVersion)</p>", isHTML: true)
			
			present(mailComposer, animated: true, completion: nil)
			
		} else {
			
			self.displayAlertWithTitle("Cannot Send Email", message: "Email is not set up on this device.")
			
		}
		
	}
	
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		
		controller.dismiss(animated: true) { 
			
			if result == MFMailComposeResult.sent || result == MFMailComposeResult.saved {
				
				self.displayAlertWithTitle("Thank You!", message: "Your feedback is greatly appreciated! You should receive a reply within a week. Visit the website to find learn a bit more about It's Time To Go.")
				
			}
			
		}
		
	}
	
	
	// MARK: - Navigation
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		// Prepare the possible views that may appear by pre-setting properties
		if let timeVC = segue.destination as? EditEventTimeTableViewController {
            
			timeVC.eventDate = self.eventDate
			timeVC.event = self.event
			
		}
        
        if let nameVC = segue.destination as? EditEventNameTableViewController {
			
			nameVC.eventName = self.eventName
			nameVC.event = self.event
			
		}
        
//        else if let newTripNavVC = segue.destination as? UINavigationController {
//			
//			if let newTripVC = newTripNavVC.viewControllers[0] as? NewEventTableViewController {
//				
//                newTripVC.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: newTripVC, action: #selector(newTripVC.cancelNewEvent))
//                
//			}
//			
//		}
		
	}
	
}
