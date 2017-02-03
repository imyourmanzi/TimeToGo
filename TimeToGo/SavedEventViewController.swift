//
//  SavedEventViewController.swift
//  TimeToGo
//
//  Created by Matteo Manzi on 7/4/15.
//  Copyright (c) 2015 VMM Software. All rights reserved.
//

import UIKit

class SavedEventViewController: UIViewController, UITableViewDataSource {
	
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
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "entryCell", for: indexPath)
		
		let entry = entries[indexPath.row]
		cell.textLabel?.text = entry.scheduleLabel
        cell.detailTextLabel?.text = entry.stringFromTimeValue()
		
		return cell
		
	}
	
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Update currentTripName to the chosen eventName
        UserDefaults.standard.set(self.eventName, forKey: "currentTripName")
        
    }
	
}
