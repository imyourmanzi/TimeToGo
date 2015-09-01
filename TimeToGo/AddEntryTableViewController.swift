//
//  AddEntryTableViewController.swift
//  TimeToGo
//
//  Created by Matteo Manzi on 7/4/15.
//  Copyright (c) 2015 VMM Software. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class AddEntryTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate, MKMapViewDelegate, communicationToMain {
	
	// Interface Builder outlets
	@IBOutlet var mainLabelTextfield: UITextField!
	@IBOutlet var schedLabelTextfield: UITextField!
	@IBOutlet var intervalLabelCell: UITableViewCell!
	@IBOutlet var intervalTimePicker: UIPickerView!
	@IBOutlet var useLocationSwitch: UISwitch!
	@IBOutlet var startLocCell: UITableViewCell!
	@IBOutlet var startLocTextfield: UITextField!
	@IBOutlet var endLocCell: UITableViewCell!
	@IBOutlet var endLocTextfield: UITextField!
	@IBOutlet var mapView: MKMapView!				// Be careful using the MapView, it uses ~200 MB of RAM memory
	
	// CoreData variables
	var moc: NSManagedObjectContext?
	var currentTripName: String!
	var currentTrip: Trip!
	var entries = [Interval]()
	
	// Current VC variables
	var mainLabel: String!
	var schedLabel: String!
	var timeValueHours: Int = 0
	var timeValueMins: Int = 15
	var intervalTimeStr: String!
	var pickerHidden = true
	
	// MapKit variables
	var useLocation = false
	var useLocationPrev: Bool!
	var locationManager: CLLocationManager?
	var startLocation: MKMapItem?
	var endLocation: MKMapItem?
	var startAnnotation: LocationAnnotation?
	var endAnnotation: LocationAnnotation?
	var directionsOverlay: MKOverlay?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Fetch the current trip from the persistent store and assign the CoreData variables
		moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
		currentTripName = (UIApplication.sharedApplication().delegate as! AppDelegate).currentTripNameMaster
		let fetchRequest = NSFetchRequest(entityName: "Trip")
		fetchRequest.predicate = NSPredicate(format: "tripName == %@", currentTripName)
		let trips = (try! moc!.executeFetchRequest(fetchRequest)) as! [Trip]
		currentTrip = trips[0]
		self.entries = currentTrip.entries as! [Interval]
		
		// Customized setup of the Interface Builder variables
		mainLabelTextfield.delegate = self
		mainLabelTextfield.text = mainLabel
		
		schedLabelTextfield.delegate = self
		schedLabelTextfield.text = schedLabel
		
		intervalTimeStr = Interval.stringFromTimeValue(timeValueHours, timeValueMins: timeValueMins)
		intervalLabelCell.detailTextLabel?.text = intervalTimeStr
		
		intervalTimePicker.dataSource = self
		intervalTimePicker.delegate = self
		
		useLocationSwitch.on = false
		useLocation = useLocationSwitch.on
		
		startLocTextfield.enabled = false
		endLocTextfield.enabled = false
		
	}
	
	func backFromSearch(mapItem: MKMapItem?, withStreetAddress address: String, atIndex index: Int) {
		
		switch index {
			
		case 0:
			startLocation = mapItem
			startLocTextfield.text = startLocation?.name
			mapView.removeAnnotation(startAnnotation!)
			startAnnotation = LocationAnnotation(coordinate: startLocation!.placemark.coordinate, title: startLocation!.name!, subtitle: address)
			mapView.addAnnotation(startAnnotation!)
			
		case 1:
			endLocation = mapItem
			endLocTextfield.text = endLocation?.name
			mapView.removeAnnotation(endAnnotation!)
			endAnnotation = LocationAnnotation(coordinate: endLocation!.placemark.coordinate, title: endLocation!.name!, subtitle: address)
			mapView.addAnnotation(endAnnotation!)
			
		default:
			break
			
		}
		
		if startLocation != nil && endLocation != nil {
			
			if directionsOverlay != nil {
				mapView.removeOverlay(directionsOverlay!)
			}
			
			let directionsRequest = MKDirectionsRequest()
			directionsRequest.source = startLocation
			directionsRequest.destination = endLocation
			directionsRequest.requestsAlternateRoutes = false
			directionsRequest.transportType = MKDirectionsTransportType.Automobile
			
			let directions = MKDirections(request: directionsRequest)
			directions.calculateDirectionsWithCompletionHandler({
				(response: MKDirectionsResponse?, error: NSError?) -> Void in
				
				guard let response = response else {
					return
				}
				self.showRoute(response)
				
			})
			
		}
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	override func viewDidAppear(animated: Bool) {
		
		// Show the keyboard for the mainLabelTextfield when the view has appeared if it is empty
		if mainLabelTextfield.text!.isEmpty {
			mainLabelTextfield.becomeFirstResponder()
		}
		
	}
	
	@IBAction func saveEntry(sender: UIBarButtonItem) {
		
		if mainLabelTextfield.text!.isEmpty || mainLabelTextfield.text == nil {
			
			// Alert the user that an entry cannot be saved if it does not have a mainLabel
			displayAlertWithTitle("Empty Field!", message: "Cannot leave Main Label empty")
			
		} else {
			
			// Fill in any empty values, save to the persistent store, and close the view controller
			if schedLabelTextfield.text!.isEmpty || schedLabelTextfield.text == nil {
				
				schedLabel = mainLabel
			}
			
			// Save entry information (and location information if it's present) and dismiss the view
			entries.append(Interval(mainLabel: mainLabel, scheduleLabel: schedLabel, timeValueHours: timeValueHours, timeValueMins: timeValueMins, usesLocation: useLocation, startLoc: startLocation?.placemark, endLoc: endLocation?.placemark))
			performUpdateOnCoreData()
			
			dismissViewControllerAnimated(true, completion: nil)
			
		}
		
	}
	
	@IBAction func cancelEntry(sender: UIBarButtonItem) {
		
		// Close the view controller without committing any changes to the persistent store
		dismissViewControllerAnimated(true, completion: nil)
		
	}
	
	
	// MARK: - Text field delegate and action
	
	@IBAction func mainLabelDidChange(sender: UITextField) {

		// Set the mainLabel with it's textfield
		mainLabel = sender.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
		
	}
	
	@IBAction func schedLabelDidChange(sender: UITextField) {
		
		// Set the schedLabel with it's textfield
		schedLabel = sender.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
		
	}
	
	func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
		
		// Hide the flightDatePicker if beginning to edit the textfield
		if pickerHidden == false {
			
			togglePicker()
			
		}
		
		return true
		
	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		
		textField.resignFirstResponder()
		
		if textField == mainLabelTextfield {
			
			// Set the mainLabel with it's textfield
			mainLabel = textField.text
			
		} else if textField == schedLabelTextfield {
			
			// Set the schedLabel with it's textfield
			schedLabel = textField.text
			
		}
		
		return true
		
	}
	
	// Update the new entry in the currentTrip
	private func performUpdateOnCoreData() {
		
		currentTrip.entries = self.entries
		guard let moc = self.moc else {
			return
		}
		
		if moc.hasChanges {
			
			do {
				try moc.save()
			} catch {
				
			}
			
		}
		
	}
	
	// MARK: - Table view data source
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if section == 0 {
			
			if pickerHidden {
				
				return 3
				
			} else {
				
				return 4
				
			}
			
		} else if section == 1 {
			
			if useLocation {
				
				return 4
				
			} else {
				
				return 1
				
			}
			
		} else {
			
			return 0
			
		}
		
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		if indexPath.section == 0 {
			
			if indexPath.row == 2 {
				
				togglePicker()
				
			}
			
		} else if indexPath.section == 1 && (indexPath.row == 1 || indexPath.row == 2) {
			
			loadSearchControllerWithTitle((tableView.cellForRowAtIndexPath(indexPath)?.contentView.subviews[1] as! UILabel).text, mapView: self.mapView)
			
		}
		
	}
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		
		if indexPath.section == 0 {
			
			if pickerHidden {
				
				return tableView.rowHeight
				
			} else {
				
				if indexPath.row == 3 {
					
					return intervalTimePicker.frame.height
					
				} else {
					
					return tableView.rowHeight
					
				}
				
			}
			
		} else if indexPath.section == 1 {
			
			if useLocation {
				
				if indexPath.row == 3 {
					
					return mapView.frame.height
					
				} else {
					
					return tableView.rowHeight
					
				}
				
			} else {
				
				return tableView.rowHeight
				
			}
			
		} else {
			
			return tableView.rowHeight
			
		}
		
	}
	
	
	// MARK: - Picker view data source and delegate
	
	func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
		
		return 3
		
	}
	
	func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		
		if component == 0 {
			
			return 24
			
		} else if component == 1 {
			
			return 1
			
		} else {
			
			return 60
			
		}
		
	}
	
	func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		
		if component == 0 {
			
			if row == 1 {
				
				return "\(row) hour"
				
			} else {
				
				return "\(row) hours"
				
			}
			
		} else if component == 1 {
			
			return ":"
			
		} else {
			
			if row == 1 {
				
				return "\(row) min"
				
			} else {
				
				return "\(row) mins"
				
			}
			
		}
		
	}
	
	func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		
		if component == 0 {
			
			timeValueHours = row
			
		}
		
		if component == 2 {
			
			timeValueMins = row
			
		}
		
		intervalLabelCell.detailTextLabel?.text = Interval.stringFromTimeValue(timeValueHours, timeValueMins: timeValueMins)
		
	}
	
	func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
		
		if component == 1 {
			
			return 15.0
			
		} else if component == 0 {
			
			return ((view.frame.width - 15) / 2.5)
			
		} else {
			
			return (view.frame.width - ((view.frame.width - 15) / 2.5))
			
		}
		
	}
	
	
	// MARK: - Picker view show/hide
	
	func togglePicker() {
		
		self.tableView.beginUpdates()
		
		if pickerHidden {
			
			intervalTimePicker.selectRow(timeValueHours, inComponent: 0, animated: false)
			intervalTimePicker.selectRow(timeValueMins, inComponent: 2, animated: false)
			self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 3, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
			mainLabelTextfield.resignFirstResponder()
			schedLabelTextfield.resignFirstResponder()
			
		} else {
			
			self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: 3, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
			
		}
		
		pickerHidden = !pickerHidden
		
		self.tableView.endUpdates()
		
		self.tableView.deselectRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0), animated: true)
		
	}
	
	
	// MARK: - Location management
	
	@IBAction func useLocationSwitchFlipped(sender: UISwitch) {
		
		if sender.on {
			checkForLocationPermission()
		} else {
			locationManager?.stopUpdatingLocation()
		}
		useLocationPrev = useLocation
		useLocation = sender.on
		toggleUseLocation()
		
	}
	
	private func checkForLocationPermission() {
		
		if CLLocationManager.locationServicesEnabled() {
			
			switch CLLocationManager.authorizationStatus() {
				
			case .AuthorizedAlways:
				createLocationManager(true)
				
			case .AuthorizedWhenInUse:
				createLocationManager(true)
				
			case .Denied:
				useLocationSwitch.on = false
				displayAlertWithTitle("Denied", message: "Location services are not allowed for this app")
				
			case .NotDetermined:
				createLocationManager(false)
				guard let locationManager = self.locationManager else {
					displayAlertWithTitle("Error Starting Location Services", message: "Please try again later")
					break
				}
				locationManager.requestWhenInUseAuthorization()
				
			case .Restricted:
				useLocationSwitch.on = false
				displayAlertWithTitle("Restricted", message: "Location services are not allowed for this app")
				
			}
			
		}
		
	}
	
	private func displayAlertWithTitle(title: String?, message: String?) {
		
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
		let dismissAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
		alertController.addAction(dismissAction)
		
		presentViewController(alertController, animated: true, completion: nil)
		
	}
	
	private func createLocationManager(startImmediately: Bool) {
		
		if locationManager == nil {
			locationManager = CLLocationManager()
		}
		
		guard let locationManager = locationManager else {
			return
		}
		
		locationManager.delegate = self
		if startImmediately {
			
			locationManager.startUpdatingLocation()
			mapView.showsUserLocation = true
			
		}
		
	}
	
	func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
		
		switch status {
			
		case .AuthorizedAlways:
			mapView.showsUserLocation = true
			
		case .AuthorizedWhenInUse:
			mapView.showsUserLocation = true
			
		case .Denied:
			useLocationSwitch.enabled = false
			
		case .Restricted:
			useLocationSwitch.enabled = false
			
		case .NotDetermined:
			checkForLocationPermission()
			
		}
		
	}
	
	func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
		
		print("Location manager failed: (\(manager))\n\(error)\n")
		
		let alertController = UIAlertController(title: "Error \(error.code)", message: "Location manager failed: \(error)", preferredStyle: UIAlertControllerStyle.Alert)
		let dismissBtn = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default) { (action: UIAlertAction) -> Void in
			
			manager.stopUpdatingLocation()
			self.useLocationSwitch.setOn(false, animated: true)
			self.useLocationPrev = self.useLocation
			self.useLocation = self.useLocationSwitch.on
			self.toggleUseLocation()
			
		}
		alertController.addAction(dismissBtn)
		
		self.presentViewController(alertController, animated: true, completion: nil)
		
	}
	
	func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
		
		if mapView.annotations.count < 3 {
			
			let span = MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4)
			let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: span)
			
			mapView.setRegion(region, animated: true)
			
		}
		
	}
	
	func mapViewWillStartLoadingMap(mapView: MKMapView) {
		
		startLocCell.userInteractionEnabled = false
		startLocCell.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
		endLocCell.userInteractionEnabled = false
		endLocCell.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
		
	}
	
	func mapViewDidFinishLoadingMap(mapView: MKMapView) {
		
		startLocCell.userInteractionEnabled = true
		startLocCell.backgroundColor = UIColor.whiteColor()
		endLocCell.userInteractionEnabled = true
		endLocCell.backgroundColor = UIColor.whiteColor()
		
	}
	
	func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
		
		let renderer = MKPolylineRenderer(overlay: overlay)
		renderer.strokeColor = UIColor(red: 8/255, green: 156/255, blue: 1.0, alpha: 1.0)
		renderer.lineWidth = 5.0
		
		return renderer
		
	}
	
	private func showRoute(response: MKDirectionsResponse) {
		
		for route in response.routes {
			
			mapView.addOverlay(route.polyline, level: MKOverlayLevel.AboveRoads)
			directionsOverlay = (mapView.overlays )[0]
			
			let timeInInt = Int((route.expectedTravelTime))
			timeValueHours = timeInInt / 3600
			timeValueMins = timeInInt / 60 % 60
			intervalLabelCell.detailTextLabel?.text = Interval.stringFromTimeValue(timeValueHours, timeValueMins: timeValueMins)
			
		}
		
	}
	
	func mapView(mapView: MKMapView, didAddOverlayRenderers renderers: [MKOverlayRenderer]) {
		
		var zoomRect = MKMapRectNull
		
		for annotation in mapView.annotations {
			
			let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
			let pointRec = MKMapRect(origin: MKMapPoint(x: annotationPoint.x - 50.0, y: annotationPoint.y - 50.0), size: MKMapSize(width: 100.0, height: 100.0))
			zoomRect = MKMapRectUnion(zoomRect, pointRec)
			
		}
		
		mapView.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 35.0, left: 35.0, bottom: 35.0, right: 35.0), animated: true)
		
	}
	
	@IBAction func openRouteInMaps(sender: UIButton) {
		
		guard let startLocation = startLocation, endLocation = endLocation else {
			displayAlertWithTitle("Can't Open Route", message: "Make sure there locations for both Start and End")
			return
		}

		let launchOptions = [
			MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving,
			MKLaunchOptionsMapTypeKey : MKMapType.Standard.rawValue,
			MKLaunchOptionsShowsTrafficKey : true,
			MKLaunchOptionsMapCenterKey : NSValue(MKCoordinate: self.mapView.region.center),
			MKLaunchOptionsMapSpanKey : NSValue(MKCoordinateSpan: self.mapView.region.span)
		]
		
		MKMapItem.openMapsWithItems([startLocation, endLocation], launchOptions: launchOptions)
		
	}
	
	
	// MARK: - Location-based fields show/hide
	
	private func toggleUseLocation() {
		
		let rowsToChange = [
			
			NSIndexPath(forRow: 1, inSection: 1),
			NSIndexPath(forRow: 2, inSection: 1),
			NSIndexPath(forRow: 3, inSection: 1)
			
		]
		
		self.tableView.beginUpdates()
		
		if useLocation && useLocationPrev == false {
			
			mapView.delegate = self
			self.tableView.insertRowsAtIndexPaths(rowsToChange, withRowAnimation: UITableViewRowAnimation.Fade)
			mainLabelTextfield.resignFirstResponder()
			schedLabelTextfield.resignFirstResponder()
			
		} else if !useLocation && useLocationPrev == true {
			
			self.tableView.deleteRowsAtIndexPaths(rowsToChange, withRowAnimation: UITableViewRowAnimation.Fade)
			
		}
		
		self.tableView.endUpdates()
		
	}
	
	private func loadSearchControllerWithTitle(title: String?, mapView: MKMapView) {
		
		let searchNavVC = self.storyboard?.instantiateViewControllerWithIdentifier("searchNavVC") as! UINavigationController
		let searchVC = searchNavVC.viewControllers[0] as! SearchViewController
		searchVC.delegate = self
		
		guard let title = title else {
			
			searchVC.whichLocationIndex = -1
			searchVC.title = "Location"
			return
			
		}
		if title == "Start" {
			
			searchVC.whichLocationIndex = 0
			
		} else if title == "End" {
			
			searchVC.whichLocationIndex = 1
			
		} else {
			
			searchVC.whichLocationIndex = -1
			
		}
		searchVC.title = title + " Location"
		
		searchVC.mapView = mapView
		
		CLGeocoder().reverseGeocodeLocation(mapView.userLocation.location!, completionHandler: { (placemarks, error: NSError?) -> Void in
			
			guard let placemarks = placemarks where placemarks.count > 0 else {
				
				self.displayAlertWithTitle("Location Error", message: "Connection to the server was not responsive.\nPlease try again later.")
				return
				
			}
			
			let userCurrentLocation = placemarks[0]
			searchVC.userCurrentLocation = MKMapItem(placemark: MKPlacemark(placemark: userCurrentLocation))
			
			searchVC.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
			self.presentViewController(searchNavVC, animated: true, completion: nil)
			
		})
		
	}
	
	
	// MARK: - Navigation
	
	override func viewWillDisappear(animated: Bool) {
		
		// Make sure that the keyboards are all away
		mainLabelTextfield.resignFirstResponder()
		schedLabelTextfield.resignFirstResponder()
		
	}

}
