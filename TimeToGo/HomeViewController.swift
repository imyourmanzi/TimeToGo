//
//  HomeViewController.swift
//  TimeToGo
//
//  Created by Matt Manzi on 1/20/17.
//  Copyright © 2017 MRM Software. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "categoryCell"

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, CoreDataHelper {
    
    // CoreData variables
    var allEvents: [Trip] = []
    var entries: [Interval] = []
    
    // Current VC variables
    let titleImageView = UIImageView(image: UIImage(named: "title"))
    var categoriesFileData: String = ""
    var eventCategories: [String] = ["A","B","C"]
    var categoryIndexPath = IndexPath()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the custom title for the navigation bar
        self.navigationItem.titleView = titleImageView

        if let fileData = readData(fromCSV: "EventTypeData") {
            categoriesFileData = fileData
            eventCategories = getEventCategories(from: fileData)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        getEventData()
        
        moveMainLabelIfNeeded()
        
        disableTabBarIfNeeded(events: allEvents, sender: self)
        
    }
    
    private func getEventData() {
        
        do {
            allEvents = try fetchAllEvents()
        } catch {
            displayAlert(title: "Error Retrieving Data", message: "There was an error retrieving saved data.", on: self, dismissHandler: nil)
        }
        
    }
    
    // If not done already, move all the main labels' contents into their respective notes and set them nil
    private func moveMainLabelIfNeeded() {
        
        if !(UserDefaults.standard.bool(forKey: "movedMainLabel")) {
            
            var i = 0
            for event in allEvents {
                
                self.entries = event.entries as! [Interval]
                
                var j = 0
                for entry in self.entries {
                    
                    if let mainLabel = entry.mainLabel {
                        
                        if let notes = entry.notesStr {
                            entry.notesStr = "Main Label: \(mainLabel)\n\n\(notes)"
                        } else {
                            entry.notesStr = "Main Label: \(mainLabel)"
                        }
                        
                        entry.mainLabel = nil
                        
                    }
                    
                    self.entries[j] = entry
                    j += 1
                    
                }
                
                allEvents[i].entries = self.entries as NSArray
                i += 1
                
            }
            
            // Update the standards database
            UserDefaults.standard.set(true, forKey: "movedMainLabel")
            
        }
        
    }
    
    
    // MARK: - Manage CSV of Event Types
    
    func readData(fromCSV file: String) -> String! {
        
        guard let filePath = Bundle.main.path(forResource: file, ofType: "csv") else {
            return nil
        }
        
        do {
            
            let contents = try String(contentsOfFile: filePath)
            
            return contents
            
        } catch {
            
            return nil
            
        }
        
    }
    
    func getEventCategories(from data: String) -> [String] {
        
        var categories: [String] = []
        
        var rows = data.components(separatedBy: "\n")
        if rows.last == "" {
            rows.removeLast()
        }
        
        for row in rows {
            
            let category = row.components(separatedBy: ",")[0]
            
            
            if !(categories.contains(category)) {
                categories.append(category)
            }
            
        }
        
        return categories
        
    }
    
    func getEventTypes(from data: String, ofCategory: String) -> [String] {
        
        var types: [String] = []
        
        var rows = data.components(separatedBy: "\n")
        if rows.last == "" {
            rows.removeLast()
        }
        
        for row in rows {
            
            let rowCategory = row.components(separatedBy: ",")[0]
            let rowType = row.components(separatedBy: ",")[1]
            
            if rowCategory == ofCategory {
                types.append(rowType)
            }
            
        }
        
        return types
        
    }
    
    
    // MARK: - Collection View Data Source
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return eventCategories.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CategoryCollectionViewCell
        
        cell.configure(categoryTitle: eventCategories[indexPath.item])
        
        return cell
        
    }
    
    
    // MARK: - Collection View Delegate
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        categoryIndexPath = indexPath
        collectionView.deselectItem(at: indexPath, animated: true)
        
        return true
        
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        
        return true
        
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        
        let cell = collectionView.cellForItem(at: indexPath) as! CategoryCollectionViewCell
        cell.highlight()
        
        return true
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! CategoryCollectionViewCell
        cell.unhighlight()
        
    }
    
    
    // MARK: - Navigation
    
    @IBAction func unwindToHome(_ segue: UIStoryboardSegue) {
        
        displayAlert(title: "No Events", message: "There are currently no saved events.", on: self, dismissHandler: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        performUpdateOnCoreData()
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let eventTypeVC = segue.destination as? EventTypeCollectionViewController {
            
            eventTypeVC.eventTypes = getEventTypes(from: categoriesFileData, ofCategory: eventCategories[categoryIndexPath.item])
            eventTypeVC.allEvents = allEvents
            eventTypeVC.navigationItem.title = (eventCategories[categoryIndexPath.item]).components(separatedBy: "^")[1]
            
        } else if let allEventsVC = segue.destination as? AllEventsTableViewController {
            
            allEventsVC.allEvents = allEvents
            
        }
        
    }

}
