//
//  SearchViewController.swift
//  TestTableViewWithLocationSwitch
//
//  Created by Matteo Manzi on 7/14/15.
//  Copyright (c) 2015 VMM Softwares. All rights reserved.
//

import UIKit
import MapKit

protocol communicationToMain {
	
	func backFromSearch(mapItem: MKMapItem?, withStreetAddress address: String, atIndex index: Int)
	
}

class SearchViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {

	var delegate: communicationToMain? = nil
	
	var mapView: MKMapView!
	var whichLocationIndex: Int!
	var searchResultsController = UISearchController()
	let defaultLocations = [
		MKMapItem(),
		MKMapItem(),
		MKMapItem(),
		MKMapItem()
	]
	var userCurrentLocation: MKMapItem!
	var mapSearchResults = [MKMapItem]()
	var selectedLocation: MKMapItem?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		searchResultsController = ({
			
			let controller = UISearchController(searchResultsController: nil)
			controller.delegate = self
			controller.searchResultsUpdater = self
			controller.dimsBackgroundDuringPresentation = false
			controller.hidesNavigationBarDuringPresentation = false
			controller.searchBar.delegate = self
			controller.searchBar.placeholder = "Enter Location"
			controller.searchBar.sizeToFit()
			
			self.tableView.tableHeaderView = controller.searchBar
			
			return controller
			
		})()
		
		self.tableView.reloadData()
		
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		searchResultsController.active = true
		
	}
	
	
	// MARK: - Search updating
	
	func updateSearchResultsForSearchController(searchController: UISearchController) {
		
		mapSearchResults.removeAll(keepCapacity: false)
		
		let span = MKCoordinateSpan(latitudeDelta: 1.5, longitudeDelta: 1.5)
		var region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: span)
		
		let request = MKLocalSearchRequest()
		request.naturalLanguageQuery = searchController.searchBar.text
		request.region = region
		
		let search = MKLocalSearch(request: request)
		search.startWithCompletionHandler { (response: MKLocalSearchResponse!, error: NSError!) -> Void in
			
			if let searchResults = response {
				
				if response.mapItems.count > 0 {
					
					for item in response.mapItems as! [MKMapItem] {
						
						self.mapSearchResults.append(item)
						
					}
					
					self.tableView.reloadData()
						
				}
				
			}
			
		}
	
	}
	
	
	// MARK: - Search controller delegate

	func didPresentSearchController(searchController: UISearchController) {

		searchController.searchBar.setShowsCancelButton(false, animated: false)
		searchController.searchBar.sizeToFit()
		searchResultsController.searchBar.becomeFirstResponder()
		
	}

	
	// MARK: - Search bar delegate
	
	func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
		
		if searchText.isEmpty {
			
			self.tableView.reloadData()
			
		}
		
	}
	
	
	// MARK: - Table view data source
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		
		return 2
		
	}
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		
		if section == 1 {
			
			if searchResultsController.active && !searchResultsController.searchBar.text.isEmpty {
				
				return "Search Results"
				
			} else {
				
				return "Default Locations"
				
			}
			
		}
		
		return nil
		
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if section == 1 {
			
			if searchResultsController.active && !searchResultsController.searchBar.text.isEmpty {
				
				return mapSearchResults.count
				
			} else {
				
				return defaultLocations.count
				
			}
				
		} else {
			
			return 1
			
		}
		
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell
		
		if indexPath.section == 1 {
			
			if searchResultsController.active && !searchResultsController.searchBar.text.isEmpty {
				
				let mapItem = mapSearchResults[indexPath.row]
				let streetAddress = Interval.getAddressFromMapItem(mapItem)
				
				cell.textLabel?.text = mapItem.name
				cell.detailTextLabel?.text = streetAddress
				
			} else {
				
				cell.textLabel?.text = defaultLocations[indexPath.row].name
				
			}
				
		} else {
			
			cell.textLabel?.text = "Current Location"
			cell.detailTextLabel?.text = nil
			
		}
		
		return cell
		
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		var mapItem: MKMapItem?
		var streetAddress = ""
		
		if indexPath.section == 1 {
			
			if searchResultsController.active && !searchResultsController.searchBar.text.isEmpty {
				
				mapItem = mapSearchResults[indexPath.row]
				streetAddress = Interval.getAddressFromMapItem(mapItem!)
				
				selectedLocation = mapItem
				
			} else {
				
				mapItem = defaultLocations[indexPath.row]
				streetAddress = Interval.getAddressFromMapItem(mapItem!)
				
				selectedLocation = mapItem
				
			}
			
		} else {
			
			selectedLocation = userCurrentLocation
			
		}
		
		
		
		switch whichLocationIndex {
			
		case 0:
			delegate?.backFromSearch(selectedLocation, withStreetAddress: streetAddress, atIndex: 0)
			
		case 1:
			delegate?.backFromSearch(selectedLocation, withStreetAddress: streetAddress, atIndex: 1)
			
		default:
			break
			
		}
		
		searchResultsController.dismissViewControllerAnimated(true, completion: nil)
		self.dismissViewControllerAnimated(true, completion: nil)
		
	}
	
	
	// MARK: - Navigation
	
	@IBAction func dismissLocationSearch(sender: UIBarButtonItem) {
		
		if searchResultsController.active {
			
			searchResultsController.dismissViewControllerAnimated(true, completion: nil)
			
		}
		self.dismissViewControllerAnimated(true, completion: nil)
		
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
}
