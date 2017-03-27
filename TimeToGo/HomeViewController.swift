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
    
    // Value constants
    let MOVE_MAIN_LABEL_KEY  = "movedMainLabel"
    
    // CoreData variables
    var allEvents: [Trip] = []
    var entries: [Interval] = []
    
    // Current VC variables
    var stockEvents: Events = Events()
    var isViewVisible = false
    let titleImageView = UIImageView(image: UIImage(named: "title"))
    var categoriesFileData: String = ""
    var eventCategories: [String] = ["A","B","C"]
    var categoryIndexPath = IndexPath()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the custom title for the navigation bar
        self.navigationItem.titleView = titleImageView
        
        eventCategories = stockEvents.getEventCategories()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        getEventData()
        
        moveMainLabelIfNeeded()
        
        disableTabBarIfNeeded(events: allEvents, sender: self)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        isViewVisible = true
        
    }
    
    private func getEventData() {
        
        do {
            allEvents = try fetchAllEvents()
        } catch CoreDataEventError.returnedNoEvents {
            
            guard let parentVC = parent else {
                return
            }
            
            displayNoEventsAlert(on: parentVC, dismissHandler: nil)
            
        } catch {
            
            guard let parentVC = parent else {
                return
            }
            
            displayDataErrorAlert(on: parentVC, dismissHandler: nil)
            
        }
        
    }
    
    // If not done already, move all the main labels' contents into their respective notes and set them nil
    private func moveMainLabelIfNeeded() {
        
        if !(UserDefaults.standard.bool(forKey: MOVE_MAIN_LABEL_KEY)) {
            
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
            UserDefaults.standard.set(true, forKey: MOVE_MAIN_LABEL_KEY)
            
        }
        
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
        
        guard let allEventsVC = segue.source as? AllEventsTableViewController else {
            return
        }
        allEvents = allEventsVC.allEvents
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        performUpdateOnCoreData()
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let eventTypeVC = segue.destination as? EventTypeCollectionViewController {
            
            eventTypeVC.eventTypes = stockEvents.getEventTypes(ofCategory: eventCategories[categoryIndexPath.item])
            eventTypeVC.allEvents = allEvents
            eventTypeVC.navigationItem.title = (eventCategories[categoryIndexPath.item]).components(separatedBy: CSVFile.TITLE_DELIMIT)[1]
            
        } else if let allEventsVC = segue.destination as? AllEventsTableViewController {
            allEventsVC.allEvents = allEvents
        }
        
    }

}
