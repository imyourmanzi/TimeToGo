//
//  EventTypeCollectionViewController.swift
//  TimeToGo
//
//  Created by Matt Manzi on 1/23/17.
//  Copyright © 2017 MRM Software. All rights reserved.
//

import UIKit

private let reuseIdentifier = "typeCell"

class EventTypeCollectionViewController: UICollectionViewController {

    // Current VC variables
    var eventTypes: [String] = ["1","2","3"]
    var typeIndexPath = IndexPath()
    
    // Intermittern variables - variables to be passed to next view controller
    var allEvents: [Trip] = []
    
    
    // MARK: - Collection View data source

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
        
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return eventTypes.count
        
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TypeCollectionViewCell
    
        cell.configure(typeTitle: eventTypes[indexPath.item])
    
        return cell
        
    }
    

    // MARK: - Collection View delegate
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        typeIndexPath = indexPath
        
        collectionView.deselectItem(at: indexPath, animated: true)
        
        return true
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        
        return true
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        
        let cell = collectionView.cellForItem(at: indexPath) as! TypeCollectionViewCell
        cell.highlight()
        
        return true
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! TypeCollectionViewCell
        cell.unhighlight()
        
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if let newEventVC = segue.destination as? NewEventTableViewController {
            
            newEventVC.allEvents = allEvents
            newEventVC.eventType = (eventTypes[typeIndexPath.item]).components(separatedBy: CSVFile.TITLE_DELIMIT)[1]
            
            let eventTimeLabel = (eventTypes[typeIndexPath.item]).components(separatedBy: CSVFile.TITLE_DELIMIT)[2]
            newEventVC.eventTimeLabel = (eventTimeLabel == HomeConstants.EVENT_TIME_LABEL_DEFAULT_KEY) ? HomeConstants.EVENT_TIME_LABEL_DEFAULT : eventTimeLabel
            
            
        }
        
    }

}
