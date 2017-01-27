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
	@IBOutlet var flightDateCell: UITableViewCell!
	@IBOutlet var tripNameCell: UITableViewCell!
    @IBOutlet var deleteAlertPopoverViewAnchor: UIView!
	
    // Core Data variables
	var moc: NSManagedObjectContext?
	var currentTripName: String!
	var currentTrip: Trip!
	var currentTripIndex: Int!
	var allTrips = [Trip]()
	
    // Current VC variables
	var flightDate: Date!
	var tripName: String!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		// Assign the moc CoreData variable by referencing the AppDelegate's
		moc = getContext()
		
    }
    
	override func viewWillAppear(_ animated: Bool) {
		
		// Fetch the current trip from the persistent store and assign the CoreData variables
		currentTripName = UserDefaults.standard.object(forKey: "currentTripName") as! String
		let fetchRequest = NSFetchRequest<Trip>(entityName: "Trip")
		fetchRequest.predicate = NSPredicate(format: "tripName == %@", currentTripName)
		let trips = (try! moc!.fetch(fetchRequest))
		currentTrip = trips[0]
		
		self.tripName = currentTrip.tripName
		self.flightDate = currentTrip.flightDate as Date!
		
		tripNameCell.detailTextLabel?.text = self.tripName
		
		// Set up the dateFormatter for the flightDate title display
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "M/d/yy '@' h:mm a"
		flightDateCell.detailTextLabel?.text = dateFormatter.string(from: self.flightDate)
		
		// Fetch all of the managed objects from the persistent store and update the table view
		let fetchAll = NSFetchRequest<Trip>(entityName: "Trip")
		allTrips = (try! moc!.fetch(fetchAll))
		
		tableView.reloadData()
		
	}
	
	@IBAction func clickedDeleteTrip(_ sender: UIButton) {
		
		// Present an action sheet to confirm deletion of currentTrip and handle the situations that can follow
		let deleteAlertController = UIAlertController(title: nil, message: "Delete \(currentTripName!)?", preferredStyle: .actionSheet)
		let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {(action: UIAlertAction) in
			deleteAlertController.dismiss(animated: true, completion: nil)
		})
		let deleteAction = UIAlertAction(title: "Delete Trip", style: UIAlertActionStyle.destructive, handler: { (action: UIAlertAction) in
			
            self.currentTripIndex = self.allTrips.index(of: self.currentTrip)
			self.moc!.delete(self.allTrips.remove(at: self.currentTripIndex))
			
			do {
				try self.moc!.save()
			} catch {
			}
			
			if self.allTrips.count >= 1 {
				
				self.currentTripName = self.allTrips[self.allTrips.count - 1].tripName
				UserDefaults.standard.set(self.currentTripName, forKey: "currentTripName")
				
				self.viewWillAppear(true)
				
			} else if self.allTrips.count <= 0 {
				
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
            
			timeVC.eventDate = self.flightDate
			timeVC.currentEvent = self.currentTrip
			
		} else if let nameVC = segue.destination as? EditTripNameTableViewController {
			
			nameVC.tripName = self.tripName
			nameVC.currentTrip = self.currentTrip
			
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
