//
//  SavedEventViewController.swift
//  TimeToGo
//
//  Created by Matt Manzi on 7/4/15.
//  Copyright (c) 2017 MRM Software. All rights reserved.
//

import UIKit

private let reuseIdentifier = "entryCell"

class SavedEventViewController: UIViewController, UITableViewDataSource, CoreDataHelper {
	
	// Interface Builder variables
	@IBOutlet var tableView: UITableView!
	@IBOutlet var eventDateLabel: UILabel!
    @IBOutlet var eventTypeLabel: UILabel!
	
	// Current VC variables
    var eventName: String = UIConstants.NOT_FOUND
    var eventDate: Date!
    var eventType: String = UIConstants.NOT_FOUND
	var entries: [Interval]!
	
	override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDateElements()
        
    }
    
    private func setupDateElements() {
        
        // Set up the dateFormatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = UIConstants.STD_DATETIME_FORMAT
        
        // Set the Interface Builder variables
        eventDateLabel.text = "Event Date and Time:\n\(dateFormatter.string(from: eventDate))"
        eventTypeLabel.text = "Event Type:\n\(eventType)"
        
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
        CoreDataConnector.setCurrentEventName(to: eventName)
        
        guard let mainTabVC = storyboard?.instantiateViewController(withIdentifier: IDs.VC_TAB_MAIN) as? UITabBarController else {
            return
        }
        
        mainTabVC.modalTransitionStyle = .crossDissolve
        mainTabVC.selectedIndex = 1
        
        present(mainTabVC, animated: true, completion: nil)
        
    }
	
}
