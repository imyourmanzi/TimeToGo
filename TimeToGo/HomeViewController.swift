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
    
    // Interface Builder variables
    @IBOutlet var loadPreviousButton: UIButton!
    
    // CoreData variables
    var allEvents: [Trip] = []
    var entries: [Interval] = []
    
    // Current VC variables
    var stockEvents: Events = Events()
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
        
//        if UserDefaults.standard.bool(forKey: WalkthroughConstants.NOT_FIRST_LAUNCH_KEY) {
            getEventData()
//        }
        
        if !(UserDefaults.standard.bool(forKey: HomeConstants.MIGRATED_DATA_KEY)) {
            migrateData()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if !(UserDefaults.standard.bool(forKey: WalkthroughConstants.NOT_FIRST_LAUNCH_KEY)) {
            showWalkthrough()
        }
        
    }
    
    private func getEventData() {
        
        do {
            
            allEvents = try CoreDataConnector.fetchAllEvents()
            loadPreviousButton.isEnabled = true
            
        } catch CoreDataEventError.returnedNoEvents {
            loadPreviousButton.isEnabled = false
        } catch {
            
            guard let parentVC = parent else {
                return
            }
            
            displayDataErrorAlert(on: parentVC, dismissHandler: nil)
            
        }
        
    }
    
    // Move all the main labels' contents into their respective entries'
    // notes and set them nil and set the event type and event time labels
    private func migrateData() {
        
        var i = 0
        for event in allEvents {
            
            var j = 0
            var entries = event.entries as! [Interval]
            for entry in entries {
                
                if let mainLabel = entry.mainLabel {
                    
                    if let notes = entry.notesStr {
                        entry.notesStr = "Main Label: \(mainLabel)\n\n\(notes)"
                    } else {
                        entry.notesStr = "Main Label: \(mainLabel)"
                    }
                    
                    entry.mainLabel = nil
                    
                }
                
                entries[j] = entry
                j += 1
                
            }
            
            allEvents[i].entries = entries as NSArray
            allEvents[i].eventType = "Plane"
            allEvents[i].eventTimeLabel = "Takeoff"
            i += 1
            
        }
        
        CoreDataConnector.updateStore(from: self)
        
        // Update the standards database
        UserDefaults.standard.set(true, forKey: HomeConstants.MIGRATED_DATA_KEY)
        
    }
    
    private func showWalkthrough() {
        
        guard let walkthroughVC = storyboard?.instantiateViewController(withIdentifier: IDs.VC_PAGE_WALKTHROUGH) else {
            return
        }
        
        walkthroughVC.modalTransitionStyle = .coverVertical
        present(walkthroughVC, animated: true, completion: nil)
        
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
        
        CoreDataConnector.updateStore(from: self)
        
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
