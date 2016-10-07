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

class SettingsTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {

	@IBOutlet var flightDateCell: UITableViewCell!
	@IBOutlet var tripNameCell: UITableViewCell!
	
	var moc: NSManagedObjectContext?
	var currentTripName: String!
	var currentTrip: Trip!
	var currentTripIndex: Int!
	var allTrips = [Trip]()
	
	var flightDate: Date!
	var tripName: String!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		// Assign the moc CoreData variable by referencing the AppDelegate's
		moc = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
		
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
//		currentTripName = NSUserDefaults.standardUserDefaults().objectForKey("currentTripName") as! String
		let fetchAll = NSFetchRequest<Trip>(entityName: "Trip")
		allTrips = (try! moc!.fetch(fetchAll))
		
		tableView.reloadData()
		
	}
	
	@IBAction func clickedDeleteTrip(_ sender: UIButton) {
		
		// Present an action sheet to confirm deletion of currentTrip and handle the situations that can follow
		let deleteAlertController = UIAlertController(title: nil, message: "Delete \(currentTripName)?", preferredStyle: .actionSheet)
		let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {(action: UIAlertAction) in
			deleteAlertController.dismiss(animated: true, completion: nil)
		})
		let deleteAction = UIAlertAction(title: "Delete Trip", style: UIAlertActionStyle.destructive, handler: { (action: UIAlertAction) in
			
			var index = 0
			for trip in self.allTrips {
				
				if trip.tripName == self.currentTripName {
					
					self.currentTripIndex = index
					
				}
				
				index += 1
				
			}
			
			self.moc!.delete(self.allTrips.remove(at: self.currentTripIndex))
			
			do {
				try self.moc!.save()
			} catch {
				
//				print("Failed to delete the trip.\nError = \(error)")
				
			}
			
			if self.allTrips.count >= 1 {
				
				self.currentTripName = self.allTrips[self.allTrips.count - 1].tripName
				UserDefaults.standard.set(self.currentTripName, forKey: "currentTripName")
				
				self.viewWillAppear(true)
				
			} else if self.allTrips.count <= 0 {
				
				let semiDestVC = self.storyboard?.instantiateViewController(withIdentifier: "newTripNavVC") as! UINavigationController
				let destVC = semiDestVC.viewControllers[0] as! FlightTimeTableViewController
				destVC.hidesBottomBarWhenPushed = true
				destVC.navigationItem.hidesBackButton = true
				self.show(destVC, sender: self)
				
			}
			
		})
		
		deleteAlertController.addAction(cancelAction)
		deleteAlertController.addAction(deleteAction)
		
		present(deleteAlertController, animated: true, completion: nil)

	}
	
	fileprivate func displayAlertWithTitle(_ title: String?, message: String?) {
		
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let dismiss = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
		alert.addAction(dismiss)
		
		self.present(alert, animated: true, completion: nil)
		
	}

	
	// MARK: - Table view data source
	
	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		
		if section == 1 {
			
			return "Saved Trips: \(allTrips.count)"
			
		}
		
		return nil
		
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		if (indexPath as NSIndexPath).section == 2 {
			
			if (indexPath as NSIndexPath).row == 0 {
				
				newEmailToRecipients(["timetogosupport@narwhalsandcode.com"], subject: "Question/Comment/Concern with It's Time To Go")
				
			} else if (indexPath as NSIndexPath).row == 1 {
			
				if let homepage = URL(string: "https://www.narwhalsandcode.com/apps/#time-to-go") {		// Check this address
					UIApplication.shared.openURL(homepage)
				}
				
			}
			
		}
		
		tableView.deselectRow(at: indexPath, animated: true)
		
	}
	
	
	// MARK: - Mail composer delegate
	
	fileprivate func newEmailToRecipients(_ recipients: [String], subject: String) {
		
		if MFMailComposeViewController.canSendMail() {
			
			let mailComposer = MFMailComposeViewController()
			mailComposer.mailComposeDelegate = self
			mailComposer.setToRecipients(recipients)
			mailComposer.setSubject(subject)
			
			mailComposer.setMessageBody("<p><strong>Issue:</strong> </p><p><strong>Detail:</strong> </p><br /><p>Date and time: \(Date())<br />Device Family: \(UIDevice.current.model)<br />Device Model: \(UIDevice.current.modelName)<br />iOS Version: \(UIDevice.current.systemVersion)</p>", isHTML: true)
			
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
		if let timeVC = segue.destination as? EditFlightTimeTableViewController {
			
			timeVC.currentTripName = self.currentTripName
			timeVC.flightDate = self.flightDate
			timeVC.currentTrip = self.currentTrip
			
		} else if let nameVC = segue.destination as? EditTripNameTableViewController {
			
			nameVC.currentTripName = self.currentTripName
			nameVC.tripName = self.tripName
			nameVC.currentTrip = self.currentTrip
			
		} else if let newTripNavVC = segue.destination as? UINavigationController {
			
			guard let newTripVC = newTripNavVC.viewControllers[0] as? FlightTimeTableViewController else {
				return
			}
			
			newTripVC.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: newTripVC, action: #selector(newTripVC.cancelNewTripFromSettings))
			
		}
		
	}
	
}

// Extension courtesy of Sajeel
// https://www.sajeel.me/ios-swift-get-device-model/
public extension UIDevice {  
	var modelName: String {
		var systemInfo = utsname()
		uname(&systemInfo)
		let machineMirror = Mirror(reflecting: systemInfo.machine)
		let identifier = machineMirror.children.reduce("") { identifier, element in
			guard let value = element.value as? Int8 , value != 0 else { return identifier }
			return identifier + String(UnicodeScalar(UInt8(value)))
		}
		switch identifier {
		case "iPod5,1":
			return "iPod Touch 5"
		case "iPod7,1":
			return "iPod Touch 6"
		case "iPhone3,1", "iPhone3,2", "iPhone3,3": 
			return "iPhone 4"
		case "iPhone4,1":
			return "iPhone 4s"
		case "iPhone5,1", "iPhone5,2": 
			return "iPhone 5"
		case "iPhone5,3", "iPhone5,4": 
			return "iPhone 5c"
		case "iPhone6,1", "iPhone6,2":
			return "iPhone 5s"
		case "iPhone7,2":
			return "iPhone 6"
		case "iPhone7,1":
			return "iPhone 6 Plus"
		case "iPhone8,1": 
			return "iPhone 6s"
		case "iPhone8,2":
			return "iPhone 6s Plus"
		case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":
			return "iPad 2"
		case "iPad3,1", "iPad3,2", "iPad3,3": 
			return "iPad 3"
		case "iPad3,4", "iPad3,5", "iPad3,6":
			return "iPad 4"
		case "iPad4,1", "iPad4,2", "iPad4,3": 
			return "iPad Air"
		case "iPad5,3", "iPad5,4":
			return "iPad Air 2"
		case "iPad2,5", "iPad2,6", "iPad2,7": 
			return "iPad Mini"
		case "iPad4,4", "iPad4,5", "iPad4,6":
			return "iPad Mini 2"
		case "iPad4,7", "iPad4,8", "iPad4,9":
			return "iPad Mini 3"
		case "iPad5,1", "iPad5,2":
			return "iPad Mini 4"
		case "iPad6,7", "iPad6,8":
			return "iPad Pro"
		case "AppleTV5,3":
			return "Apple TV"
		case "i386", "x86_64":
			return "Simulator"
		default:
			return identifier
		}
	}
}
