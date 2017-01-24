//
//  HomeViewController.swift
//  TimeToGo
//
//  Created by Matt Manzi on 1/20/17.
//  Copyright © 2017 MRM Software. All rights reserved.
//

import UIKit

private let reuseIdentifier = "categoryCell"

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // Current VC variables
    let titleImageView = UIImageView(image: UIImage(named: "title"))
    var categoriesFileData: String = ""
    var eventCategories: [String] = ["A","B","C"]
    var categoryIndexPath: IndexPath = IndexPath()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the custom title for the navigation bar
        self.navigationItem.titleView = titleImageView

        if let fileData = readData(fromCSV: "EventTypeData") {
            categoriesFileData = fileData
            eventCategories = getEventCategories(from: fileData)
        }
//        print("eventCategories in viewDidLoad \(eventCategories)")
        
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
        
        var rows = data.components(separatedBy: "\r")
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
        
        var rows = data.components(separatedBy: "\r")
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
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
//        if let newEventVC = segue.destination as? NewEventTableViewController {
//            
//            newEventVC.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: newEventVC, action: #selector(newEventVC.cancelNewEvent))
//            
//        }
        
        if let eventTypeVC = segue.destination as? EventTypeCollectionViewController {
            
            eventTypeVC.navigationItem.title = (eventCategories[categoryIndexPath.item]).replacingOccurrences(of: "^", with: " ")
            eventTypeVC.eventTypes = getEventTypes(from: categoriesFileData, ofCategory: eventCategories[categoryIndexPath.item])
            
        }
        
    }

}
