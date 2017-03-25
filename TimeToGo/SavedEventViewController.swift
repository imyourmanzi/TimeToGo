//
//  SavedEventViewController.swift
//  TimeToGo
//
//  Created by Matteo Manzi on 7/4/15.
//  Copyright (c) 2015 VMM Software. All rights reserved.
//

import UIKit

private let reuseIdentifier = "entryCell"

class SavedEventViewController: UIViewController, UITableViewDataSource, CoreDataHelper {
	
	// Interface Builder variables
	@IBOutlet var tableView: UITableView!
	@IBOutlet var eventDateLabel: UILabel!
	
	// Current VC variables
    var eventName: String!
    var eventDate: Date!
	var entries: [Interval]!
	
	override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDateElements()
        
    }
    
    private func setupDateElements() {
        
        // Set up the dateFormatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d/yy '@' h:mm a"
        
        // Set the Interface Builder variables
        eventDateLabel.text = "Event Date and Time:\n\(dateFormatter.string(from: eventDate))"
        
    }
	
    
	// MARK: - Table view data source
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return entries.count
		
	}
	
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		
		return "Entries"
		
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
		
		let entry = entries[indexPath.row]
		cell.textLabel?.text = entry.scheduleLabel
        cell.detailTextLabel?.text = entry.getTimeValueString()
		
		return cell
		
	}
	
    
    // MARK: - Navigation
    
    @IBAction func loadEvent(_ sender: UIBarButtonItem) {
        
        // Update currentTripName to the chosen eventName
        setCurrentEventInDefaults(to: eventName)
        
        guard let mainTabVC = storyboard?.instantiateViewController(withIdentifier: "mainTabVC") as? UITabBarController else {
            return
        }
        
        mainTabVC.modalTransitionStyle = .crossDissolve
        mainTabVC.selectedIndex = 1
        
        present(mainTabVC, animated: true, completion: nil)
        
    }
	
}
