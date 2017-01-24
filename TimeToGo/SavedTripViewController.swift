//
//  SavedTripViewController.swift
//  TimeToGo
//
//  Created by Matteo Manzi on 7/4/15.
//  Copyright (c) 2015 VMM Software. All rights reserved.
//

import UIKit

class SavedTripViewController: UIViewController, UITableViewDataSource {
	
	// Interface Builder variables
	@IBOutlet var tableView: UITableView!
	@IBOutlet var flightDateLabel: UILabel!
	
	// CoreData variables
	var tripName: String!
	var flightDate: Date!
	
	// Current VC variables
	var entries: [Interval]!
	
	override func viewDidLoad() {
        super.viewDidLoad()
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// Set up the dateFormatter
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "M/d/yy '@' h:mm a"
		
		// Set the Interface Builder variables
		flightDateLabel.text = "Flight Date and Time:\n\(dateFormatter.string(from: flightDate))"
		
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	
	// MARK: - Table view data source
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return entries.count
		
	}
	
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		
		return "Entries"
		
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "entryCell", for: indexPath)
		
		var entry: Interval!
		entry = entries[indexPath.row]
		
		cell.textLabel?.text = entry.scheduleLabel
        cell.detailTextLabel?.text = entry.stringFromTimeValue()
		
		return cell
		
	}
	
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Update currentTripName to the chosen tripName
        UserDefaults.standard.set(self.tripName, forKey: "currentTripName")
        
    }
    
//	@IBAction func loadTrip(_ sender: UIBarButtonItem) {
//		
//		// Update currentTripName to the chosen tripName
//		UserDefaults.standard.set(self.tripName, forKey: "currentTripName")
//		
//		// Transition to the Scheudle VC
//		let mainTabVC = self.storyboard?.instantiateViewController(withIdentifier: "mainTabVC") as! UITabBarController
//		mainTabVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
//		self.present(mainTabVC, animated: true, completion: nil)
//		
//	}
	
}
