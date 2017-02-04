//
//  SearchViewController.swift
//  TimeToGo
//
//  Created by Matteo Manzi on 7/4/15.
//  Copyright (c) 2015 VMM Software. All rights reserved.
//

import UIKit
import MapKit

protocol communicationToMain {
	
	func backFromSearch(_ mapItem: MKMapItem?, withStreetAddress address: String, atIndex index: Int)
	
}

class SearchViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {

	var delegate: communicationToMain? = nil
	
	var mapView: MKMapView!
	var whichLocationIndex: Int!
	var searchResultsController: UISearchController!
	var userCurrentLocation: MKMapItem?
	var mapSearchResults = [MKMapItem]()
	var selectedLocation: MKMapItem?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		setupSearchController()
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		
		searchResultsController.isActive = true
		
    }
    
    private func setupSearchController() {
        
        searchResultsController = {
            
            let controller = UISearchController(searchResultsController: nil)
            controller.delegate = self
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.hidesNavigationBarDuringPresentation = false
            controller.searchBar.showsCancelButton = false
            controller.searchBar.delegate = self
            controller.searchBar.placeholder = "Enter Location"
            
            tableView.tableHeaderView = controller.searchBar
            
            return controller
            
        }()
        
        tableView.reloadData()
        
    }
	
	
	// MARK: - Search updating
	
	func updateSearchResults(for searchController: UISearchController) {
		
		mapSearchResults.removeAll(keepingCapacity: false)
		
		let span = MKCoordinateSpan(latitudeDelta: 1.5, longitudeDelta: 1.5)
		let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: span)
		
		let request = MKLocalSearchRequest()
		request.naturalLanguageQuery = searchController.searchBar.text
		request.region = region
		
		let search = MKLocalSearch(request: request)
		search.start { (response: MKLocalSearchResponse?, error: Error?) in
			
			
			guard let response = response , response.mapItems.count > 0 else {
				return
			}
			
			for item in response.mapItems {
				self.mapSearchResults.append(item)
			}
			
			self.tableView.reloadData()
			
		}
		
	}
	
	
	// MARK: - Search controller delegate

	func didPresentSearchController(_ searchController: UISearchController) {

		if searchController.isActive {
			
			searchController.searchBar.showsCancelButton = false
			searchResultsController.searchBar.becomeFirstResponder()
			
		}
		
	}

	
	// MARK: - Search bar delegate
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		
		if searchText.isEmpty {
			
			self.tableView.reloadData()
			
		}
		
	}
	
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {

		guard let searchResultsController = searchResultsController else {
			
			return 1
			
		}
		
		if (searchResultsController.searchBar.text == nil || searchResultsController.searchBar.text?.isEmpty == true) {
			
			return 1
			
		} else {
			
			return 2
			
		}
		
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		
		if section == 1 {

			return "Search Results"
			
		}
		
		return nil
		
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if section == 1 {
			
			return mapSearchResults.count
			
		} else {
			
			return 1
			
		}
		
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell!
		
		if indexPath.section == 1 {
			
			let mapItem = mapSearchResults[indexPath.row]
			let streetAddress = Interval.getAddressFromMapItem(mapItem)
			
			cell?.textLabel?.text = mapItem.name
			cell?.detailTextLabel?.text = streetAddress
			
		} else {
			
			cell?.textLabel?.text = "Current Location"

			if userCurrentLocation?.placemark.coordinate == nil {
				
				cell?.detailTextLabel?.text = "(Not found)"
				
			} else {
				
				cell?.detailTextLabel?.text = userCurrentLocation!.name
				
			}
			
			
		}
		
		return cell!
		
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		tableView.deselectRow(at: indexPath, animated: true)
		
		var mapItem: MKMapItem?
		var streetAddress = ""
		
		if indexPath.section == 1 {
			
			mapItem = mapSearchResults[indexPath.row]
			streetAddress = Interval.getAddressFromMapItem(mapItem!)
				
			selectedLocation = mapItem
			
			selectedLocation = mapItem
			
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
		
		searchResultsController.dismiss(animated: true, completion: nil)
		self.dismiss(animated: true, completion: nil)
		
	}
	
	
	// MARK: - Navigation
	
	@IBAction func dismissLocationSearch(_ sender: UIBarButtonItem) {
		
		if searchResultsController.isActive {
			
			searchResultsController.dismiss(animated: true, completion: nil)
			
		}
		self.dismiss(animated: true, completion: nil)
		
	}
    
    deinit {
        
        searchResultsController.view.removeFromSuperview()
        
    }
	
}
