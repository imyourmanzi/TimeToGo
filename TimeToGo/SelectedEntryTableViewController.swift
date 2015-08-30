//
//  SelectedEntryTableViewController.swift
//  TravelTimerBasics7
//
//  Created by Matteo Manzi on 6/25/15.
//	Edited by Matteo Manzi on 6/26/15.
//  Copyright (c) 2015 VMM Softwares. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class SelectedEntryTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate, MKMapViewDelegate, communicationToMain {

	// Interface Builder variables
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
	
	// Current trip variables
	var parentVC: EntriesViewController!
	var indexPath: NSIndexPath!
	var currentEntry: Interval!
	
	// Current entry variables
	var mainLabel: String!
	var schedLabel: String!
	var timeValueHours: Int!
	var timeValueMins: Int!
	var intervalTimeStr: String!
	
	// Current VC variables
	var pickerHidden = true
	var useLocation: Bool!
	var useLocationPrev: Bool!
	
	// MapKit variables
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
		let fetchRequest = NSFetchRequest(entityName: "Trip")
		fetchRequest.predicate = NSPredicate(format: "tripName == %@", currentTripName)
		var fetchingError: NSError?
		let trips = moc!.executeFetchRequest(fetchRequest, error: &fetchingError) as! [Trip]
		currentTrip = trips[0]
		self.entries = currentTrip.entries as! [Interval]
		
		parentVC = self.navigationController?.viewControllers[0] as! EntriesViewController
		indexPath = parentVC.tableView.indexPathForSelectedRow()
		currentEntry = self.entries[indexPath.row]
		
		// Customized setup of the Interface Builder variables
		mainLabelTextfield.delegate = self
		mainLabelTextfield.text = mainLabel
		
		schedLabelTextfield.delegate = self
		schedLabelTextfield.text = schedLabel
		
		intervalLabelCell.detailTextLabel?.text = intervalTimeStr
		
		intervalTimePicker.dataSource = self
		intervalTimePicker.delegate = self
		
		startLocTextfield.enabled = false
		endLocTextfield.enabled = false
		
		self.useLocation = currentEntry.useLocation
		
		if let usesLocation = useLocation {
			
			if usesLocation == true {
				
				self.startLocation = MKMapItem(placemark: currentEntry.startLocation)
				self.endLocation = MKMapItem(placemark: currentEntry.endLocation)
				
			}
		} else {
			
			useLocation = false
			
		}
		
		mapView.delegate = self
		
	}
	
	func backFromSearch(mapItem: MKMapItem?, withStreetAddress address: String, atIndex index: Int) {
		
//		println("came back")
		
		switch index {
			
		case 0:
			startLocation = mapItem
			startLocTextfield.text = startLocation?.name
			mapView.removeAnnotation(startAnnotation)
			startAnnotation = LocationAnnotation(coordinate: startLocation!.placemark.coordinate, title: startLocation!.name, subtitle: address)
			mapView.addAnnotation(startAnnotation)
			
		case 1:
			endLocation = mapItem
			endLocTextfield.text = endLocation?.name
			mapView.removeAnnotation(endAnnotation)
			endAnnotation = LocationAnnotation(coordinate: endLocation!.placemark.coordinate, title: endLocation!.name, subtitle: address)
			mapView.addAnnotation(endAnnotation)
			
		default:
			break
			
		}
		
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
//		println("did appear")
		
		if useLocation == true {
			
//			println("uses location")
			
/*			
			// Does not start location manager
			// Code would be less efficient to do everything here that
			// happens in useLocationSwitchFlipped(sender: UISwitch) method
			useLocationSwitch.setOn(true, animated: true)
			useLocationPrev = useLocation
			useLocation = useLocationSwitch.on
			toggleUseLocation()
*/
			useLocationSwitch.setOn(true, animated: true)
			useLocationSwitchFlipped(useLocationSwitch)
			

//			println("turned on loc fields")
			
			if startLocation != nil && endLocation != nil {
				
//				println("has start and end locs: \(startLocation), \(endLocation)")
				
				startLocTextfield.text = startLocation!.name
				endLocTextfield.text = endLocation!.name
				
				mapView.removeAnnotations(mapView.annotations)
				
				startAnnotation = LocationAnnotation(coordinate: startLocation!.placemark.coordinate, title: startLocation!.name, subtitle: Interval.getAddressFromMapItem(startLocation!))
				mapView.addAnnotation(startAnnotation)
				
				endAnnotation = LocationAnnotation(coordinate: endLocation!.placemark.coordinate, title: endLocation!.name, subtitle: Interval.getAddressFromMapItem(endLocation!))
				mapView.addAnnotation(endAnnotation)
				
				if directionsOverlay != nil {
					
					mapView.removeOverlay(directionsOverlay)
					
				} else {
					
//					println("directionsOveraly: nil")
					
				}
//				println("Overlays: \(mapView.overlays)")
//				println("Renderer For directionsOveraly: \(mapView.rendererForOverlay(directionsOverlay))")
				
//				println("Current location: \(locationManager?.location)")
//				while locationManager?.location == nil { }
				
				let directionsRequest = MKDirectionsRequest()
				directionsRequest.setSource(startLocation!)
				directionsRequest.setDestination(endLocation!)
				directionsRequest.requestsAlternateRoutes = false
				directionsRequest.transportType = MKDirectionsTransportType.Automobile
				
				let directions = MKDirections(request: directionsRequest)
				directions.calculateDirectionsWithCompletionHandler({
					(response: MKDirectionsResponse!, error: NSError!) -> Void in
//					println("made request")
					if let theResponse = response {
						
//						println("got response")
						self.showRoute(theResponse)
						
					}
					
				})
				
			}
			
		}
		
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

	
	// MARK: - Text field delegate and action
	
	@IBAction func mainLabelDidChange(sender: UITextField) {
		
		// Set the mainLabel with it's textfield
		mainLabel = sender.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
		
	}
	
	@IBAction func schedLabelDidChange(sender: UITextField) {
		
		// Set the schedLabel with it's textfield
		schedLabel = sender.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
		
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
			
			// Set the mainLabel with its textfield
			mainLabel = textField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
			
		} else if textField == schedLabelTextfield {
			
			// Set the schedLabel with its textfield
			schedLabel = textField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
			
		}
		
		return true
		
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
			
			if useLocation == true {
				
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
			
			if useLocation == true {
				
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
	
	func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
		
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
			currentEntry.timeValueHours = row
			
		}
		
		if component == 2 {
			
			timeValueMins = row
			currentEntry.timeValueMins = row
			
		}
		
		intervalLabelCell.detailTextLabel?.text = currentEntry.stringFromTimeValue()
		intervalTimeStr = currentEntry.stringFromTimeValue()
		
	}
	
	func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
		
		if component == 1 {
			
			return 15.0
			
		} else if component == 0 {
			
			return ((view.frame.width - 15) / 2.5)
			
		} else {
			
			return (view.frame.width - ((view.frame.width - 15) / 2.5) - 10)
			
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
				if let manager = self.locationManager {
					
					manager.requestWhenInUseAuthorization()
					
				}
				
			case .Restricted:
				useLocationSwitch.on = false
				displayAlertWithTitle("Restricted", message: "Location services are not allowed for this app")
				
			}
			
		} else {
			
			displayAlertWithTitle("Location Services Disabled", message: "Location services are not enabled on the device")
			
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
		
		if let manager = locationManager {
			
			manager.delegate = self
			if startImmediately {
				
				manager.startUpdatingLocation()
				mapView.showsUserLocation = true
				
			}
			
		}
		
	}
	
	func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
		
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
	
	func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
		
		println("Location manager failed: (\(manager))\n\(error)")
		
		let alertController = UIAlertController(title: "Error \(error.code)", message: "Location manager failed: \(error)", preferredStyle: UIAlertControllerStyle.Alert)
		let dismissBtn = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default) { (action: UIAlertAction!) -> Void in
			
			manager.stopUpdatingLocation()
			self.useLocationSwitch.setOn(false, animated: true)
			self.useLocationPrev = self.useLocation
			self.useLocation = self.useLocationSwitch.on
			self.toggleUseLocation()
			
		}
		alertController.addAction(dismissBtn)
		
		self.presentViewController(alertController, animated: true, completion: nil)
		
	}
	
	func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
		
		if mapView.annotations.count < 3 {
			
			let span = MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4)
			let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: span)
			
			mapView.setRegion(region, animated: true)
			
		}
		
	}
	
	func mapViewWillStartLoadingMap(mapView: MKMapView!) {
		
		startLocCell.userInteractionEnabled = false
		startLocCell.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
		endLocCell.userInteractionEnabled = false
		endLocCell.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
		
	}
	
	func mapViewDidFinishLoadingMap(mapView: MKMapView!) {
		
		startLocCell.userInteractionEnabled = true
		startLocCell.backgroundColor = UIColor.whiteColor()
		endLocCell.userInteractionEnabled = true
		endLocCell.backgroundColor = UIColor.whiteColor()
		
	}
	
	func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
		
//		println("rendererforoverlay")
		
		let renderer = MKPolylineRenderer(overlay: overlay)
		renderer.strokeColor = UIColor(red: 8/255, green: 156/255, blue: 1.0, alpha: 1.0)
		renderer.lineWidth = 5.0
		
		return renderer
		
	}
	
	private func showRoute(response: MKDirectionsResponse) {
		
		for route in response.routes as! [MKRoute]  {
			
			mapView.addOverlay(route.polyline, level: MKOverlayLevel.AboveRoads)
			directionsOverlay = (mapView.overlays as! [MKOverlay])[0]
			
			let timeInInt = Int((route.expectedTravelTime))
			timeValueHours = timeInInt / 3600
			timeValueMins = timeInInt / 60 % 60
			intervalLabelCell.detailTextLabel?.text = Interval.stringFromTimeValue(timeValueHours, timeValueMins: timeValueMins)
//			println("set route")
			
		}
		
	}
	
	func mapView(mapView: MKMapView!, didAddOverlayRenderers renderers: [AnyObject]!) {
		
//		println("did add overlay renderer(s)")
		
		var zoomRect = MKMapRectNull
		
		for annotation in mapView.annotations as! [MKAnnotation] {
			
			var annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
			var pointRec = MKMapRect(origin: MKMapPoint(x: annotationPoint.x - 50.0, y: annotationPoint.y - 50.0), size: MKMapSize(width: 100.0, height: 100.0))
			
			zoomRect = MKMapRectUnion(zoomRect, pointRec)
			
		}
		
		mapView.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 35.0, left: 35.0, bottom: 35.0, right: 35.0), animated: true)
		
	}
	
	@IBAction func openRouteInMaps(sender: UIButton) {
		
		if let startLoc = startLocation {
			
			if let endLoc = endLocation {
				
				let launchOptions = [
					MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving,
					MKLaunchOptionsMapTypeKey : MKMapType.Standard.rawValue,
					MKLaunchOptionsShowsTrafficKey : true,
					MKLaunchOptionsMapCenterKey : NSValue(MKCoordinate: self.mapView.region.center),
					MKLaunchOptionsMapSpanKey : NSValue(MKCoordinateSpan: self.mapView.region.span)
				]
				
				MKMapItem.openMapsWithItems([startLoc, endLoc], launchOptions: launchOptions)
				
			}
			
		}
		
	}
	
	
	// MARK: - Location-based fields show/hide
	
	private func toggleUseLocation() {
		
		let rowsToChange = [
			
			NSIndexPath(forRow: 1, inSection: 1),
			NSIndexPath(forRow: 2, inSection: 1),
			NSIndexPath(forRow: 3, inSection: 1)
			
		]
		
		self.tableView.beginUpdates()
		
		if useLocation == true && useLocationPrev == false {
			
			mapView.delegate = self
			self.tableView.insertRowsAtIndexPaths(rowsToChange, withRowAnimation: UITableViewRowAnimation.Fade)
			mainLabelTextfield.resignFirstResponder()
			schedLabelTextfield.resignFirstResponder()
			
		} else if useLocation == false && useLocationPrev == true {
			
			self.tableView.deleteRowsAtIndexPaths(rowsToChange, withRowAnimation: UITableViewRowAnimation.Fade)
			
		}
		
		self.tableView.endUpdates()
		
	}
	
	private func loadSearchControllerWithTitle(title: String?, mapView: MKMapView) {
		
		let searchNavVC = self.storyboard?.instantiateViewControllerWithIdentifier("searchNavVC") as! UINavigationController
		let searchVC = searchNavVC.viewControllers[0] as! SearchViewController
		searchVC.delegate = self
		
		if let theTitle = title {
			
			if theTitle == "Start" {
				
				searchVC.whichLocationIndex = 0
				
			} else if theTitle == "End" {
				
				searchVC.whichLocationIndex = 1
				
			} else {
				
				searchVC.whichLocationIndex = -1
				
			}
			
			searchVC.title = theTitle + " Location"
			
		} else {
			
			searchVC.whichLocationIndex = -1
			searchVC.title = "Location"
			
		}
		searchVC.mapView = mapView
		
		CLGeocoder().reverseGeocodeLocation(mapView.userLocation.location, completionHandler: { (placemarks, error: NSError!) -> Void in
			
			if let returnedPlacemarks = placemarks {
				
				if returnedPlacemarks.count > 0 {
					
					let userCurrentLocation = placemarks[0] as! CLPlacemark
					searchVC.userCurrentLocation = MKMapItem(placemark: MKPlacemark(placemark: userCurrentLocation))
					
					searchVC.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
					self.presentViewController(searchNavVC, animated: true, completion: nil)
					
				}
				
			} else {
				
				let alertController = UIAlertController(title: "Location Error", message: "Connection to the server was not responsive.\nPlease try again later.", preferredStyle: UIAlertControllerStyle.Alert)
				let dismissBtn = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) -> Void in
					
					alertController.dismissViewControllerAnimated(true, completion: nil)
					
				})
				alertController.addAction(dismissBtn)
				self.presentViewController(alertController, animated: true, completion: nil)
				
			}
			
		})
		
		
	}
	
	
	// MARK: - Navigation
	
	override func viewWillDisappear(animated: Bool) {
		
		// Check and save the currentEntry's properities to CoreData
		if mainLabelTextfield.text.isEmpty || mainLabelTextfield.text == nil {
			
			// Alert the user that an entry cannot be saved if it does not have a mainLabel
			let alertVC = UIAlertController(title: "Empty Field!", message: "Changes were not saved because the Main Label field was empty.", preferredStyle: UIAlertControllerStyle.Alert)
			let okBtn = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in
				alertVC.dismissViewControllerAnimated(true, completion: nil)
			})
			alertVC.addAction(okBtn)
			parentViewController?.presentViewController(alertVC, animated: true, completion: nil)
			
		} else {
			
			currentEntry.mainLabel = self.mainLabel
			if schedLabelTextfield.text.isEmpty || schedLabelTextfield.text == nil {
				
				currentEntry.scheduleLabel = self.mainLabel
				
			} else {
				
				currentEntry.scheduleLabel = self.schedLabel
				
			}
			currentEntry.timeValueHours = self.timeValueHours
			currentEntry.timeValueMins = self.timeValueMins
			currentEntry.timeValueStr = self.intervalTimeStr
			if useLocation == true && startLocation != nil && endLocation != nil {
			
				currentEntry.useLocation = self.useLocation
				currentEntry.startLocation = self.startLocation?.placemark
				currentEntry.endLocation = self.endLocation?.placemark
//				println("saved location")
				
			}
			self.entries[indexPath.row] = currentEntry
			currentTrip.entries = self.entries
			
			var savingError: NSError?
			if moc!.save(&savingError) == false {
				
				if let error = savingError {
					
					println("Failed to save the trip.\nError = \(error)")
					
				}
				
			}
			
		}
		
		mainLabelTextfield.resignFirstResponder()
		schedLabelTextfield.resignFirstResponder()
		
	}
	
}
