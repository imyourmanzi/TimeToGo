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
    var moc: NSManagedObjectContext?
    var allTrips: [Trip] = []
    var trip: Trip!
    var entries: [Interval] = []
    
    // Current VC variables
    let titleImageView = UIImageView(image: UIImage(named: "title"))
    var categoriesFileData: String = ""
    var eventCategories: [String] = ["A","B","C"]
    var categoryIndexPath = IndexPath()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Assign the moc CoreData variable by referencing the AppDelegate's
        moc = getContext()
        
        // Set the custom title for the navigation bar
        self.navigationItem.titleView = titleImageView

        if let fileData = readData(fromCSV: "EventTypeData") {
            categoriesFileData = fileData
            eventCategories = getEventCategories(from: fileData)
        }
//        print("eventCategories in viewDidLoad \(eventCategories)")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // If not done already, move all the main labels' contents into their respective notes and set them nil
        if !(UserDefaults.standard.bool(forKey: "movedMainLabel")) {
        
            let fetchRequest = NSFetchRequest<Trip>(entityName: "Trip")
            allTrips = (try! moc!.fetch(fetchRequest))
            
            var i = 0
            for trip in allTrips {
                
    //            print("trip", i, trip.tripName)
                
                self.entries = trip.entries as! [Interval]
                
                var j = 0
                for entry in self.entries {
                
    //                print("entry", j, entry.description)
                
                    if let mainLabel = entry.mainLabel {
                        
    //                    print("mainLabel exists in entry", j)
                        
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
                
                allTrips[i].entries = self.entries as NSArray
                i += 1
                
            }
            
            // Update the database
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
//            print("contents\n\(contents)")
            return contents
            
        } catch {
            
//            print("File read error")
            return nil
            
        }
        
    }
    
    func getEventCategories(from data: String) -> [String] {
        
        var categories: [String] = []
        
        var rows = data.components(separatedBy: "\n")
        if rows.last == "" {
            rows.removeLast()
        }
        
//        print("All Rows: \(rows)")
//        print("Num rows: \(rows.count)")
        for row in rows {
            
//            print("Row: \(row)")
            let category = row.components(separatedBy: ",")[0]
            
            
            if !categories.contains(category) {
                
//                print("Category: \(category)")
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
        
//        print("eventCategories in cellForItem \(eventCategories)")
//        print("indexPath.item in cellForItem \(indexPath.item)")
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
    
    
    // MARK: - Core Data helper
    
//    func performUpdateOnCoreData() {
//        
//        print("performing update")
//
//        guard let moc = self.moc else {
//            return
//        }
//        
//        if moc.hasChanges {
//            
//            do {
//                print("saving")
//                try moc.save()
//            } catch {
//            }
//            
//        }
//        
//    }
    
    
    // MARK: - Navigation
    
    override func viewWillDisappear(_ animated: Bool) {
        
        performUpdateOnCoreData()
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let eventTypeVC = segue.destination as? EventTypeCollectionViewController {
            
            eventTypeVC.navigationItem.title = (eventCategories[categoryIndexPath.item]).components(separatedBy: "^")[1]
            eventTypeVC.eventTypes = getEventTypes(from: categoriesFileData, ofCategory: eventCategories[categoryIndexPath.item])
            
        }
        
    }

}
