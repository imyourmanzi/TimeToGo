//
//  EditEventTypeTableViewController.swift
//  TimeToGo
//
//  Created by Matt Manzi on 3/25/17.
//  Copyright © 2017 MRM Software. All rights reserved.
//

import UIKit

class EditEventTypeTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, CoreDataHelper {
    
    // Interface Builder variables
    @IBOutlet var eventTypeCell: UITableViewCell!
    @IBOutlet var eventTypePicker: UIPickerView!
    
    // CoreData variables
    var event: Trip!
    
    // Current VC variables
    var allTypes: [String] = []
    var pickerHidden = true
    var eventType: String = UIConstants.NOT_FOUND
    let eventsDir = Events()
    var eventTimeLabel: String = HomeConstants.EVENT_TIME_LABEL_DEFAULT
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting the row heights for the table view
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // Setup the eventTypeCell
        eventTypeCell.detailTextLabel?.text = eventType
        
        // Get all the event types
        allTypes = Events().getAllEventTypes()
        
    }
    
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if pickerHidden {
            return 1
        } else {
            return 2
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            togglePicker()
        }
        
    }
    
    
    // MARK: - Picker view data source and delegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return allTypes.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return allTypes[row]
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        eventType = allTypes[row]
        eventTypeCell.detailTextLabel?.text = eventType
        eventTimeLabel = eventsDir.getEventTimeLabel(for: eventType)
        
    }
    
    
    // MARK: - Picker view show/hide
    
    func togglePicker() {
        
        self.tableView.beginUpdates()
        
        if pickerHidden {
            
            guard let typeIdx = allTypes.index(of: eventType) else {
                
                self.tableView.endUpdates()
                self.tableView.deselectRow(at: IndexPath(row: 0, section: 0), animated: true)
                
                return
                
            }
            
            eventTypePicker.selectRow(typeIdx, inComponent: 0, animated: false)
            self.tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: UITableViewRowAnimation.fade)
            
        } else {
            
            self.tableView.deleteRows(at: [IndexPath(row: 1, section: 0)], with: UITableViewRowAnimation.fade)
            
        }
        
        pickerHidden = !pickerHidden
        
        self.tableView.endUpdates()
        self.tableView.deselectRow(at: IndexPath(row: 0, section: 0), animated: true)
        
    }
    
    
    // MARK: - Core Data helper
    
    func prepareForUpdate() {
        
        event.eventType = self.eventType
        event.eventTimeLabel = self.eventTimeLabel
        
    }
    
    
    // MARK: - Navigation
    
    override func viewWillDisappear(_ animated: Bool) {
        
        CoreDataConnector.updateStore(from: self)
        
    }
    
}
