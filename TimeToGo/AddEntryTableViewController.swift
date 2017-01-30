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

class AddEntryTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UITextViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate, communicationToMain, CoreDataHelper {
	
	// Interface Builder variables
	@IBOutlet var schedLabelTextfield: UITextField!
	@IBOutlet var intervalLabelCell: UITableViewCell!
	@IBOutlet var intervalTimePicker: UIPickerView!
	@IBOutlet var notesTextview: UITextView!
	@IBOutlet var notesTextviewPlaceholder: UITextField!
	@IBOutlet var useLocationSwitch: UISwitch!
	@IBOutlet var startLocCell: UITableViewCell!
	@IBOutlet var startLocTextfield: UITextField!
	@IBOutlet var endLocCell: UITableViewCell!
	@IBOutlet var endLocTextfield: UITextField!
	@IBOutlet var mapView: MKMapView!				// Be careful using the MapView, it uses ~200 MB of RAM memory
	
	// CoreData variables
//	var moc: NSManagedObjectContext?
//	var eventName: String!
	var event: Trip!
    var entries: [Interval] = []
	
	// Current VC variables
	var schedLabel: String!
	var timeValueHours: Int = 0
	var timeValueMins: Int = 15
	var intervalTimeStr: String!
	var pickerHidden = true
	var notes: String?
	
	// MapKit variables
	var useLocation = false
	var useLocationPrev: Bool!
	var locationManager: CLLocationManager?
	var startLocation: MKMapItem?
	var endLocation: MKMapItem?
	var startAnnotation: LocationAnnotation = LocationAnnotation(coordinate: CLLocationCoordinate2DMake(0, 0), title: "", subtitle: "")
	var endAnnotation: LocationAnnotation = LocationAnnotation(coordinate: CLLocationCoordinate2DMake(0, 0), title: "", subtitle: "")
	var directionsOverlay: MKOverlay?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
//		moc = getContext()
//		eventName = UserDefaults.standard.object(forKey: "currentTripName") as! String
//		let fetchRequest = NSFetchRequest<Trip>(entityName: "Trip")
//		fetchRequest.predicate = NSPredicate(format: "tripName == %@", eventName!)
//        do {
//            let events = try moc!.fetch(fetchRequest)
//            event = events[0]
//        } catch {
//            print("caught bad one")
//        }
        
        // Fetch the current event from the persistent store and assign the CoreData variables
        do {
            
            event = try fetchCurrentEvent()
            if let theEntries = event.entries as? [Interval] {
                entries = theEntries
            } else {
                parent?.dismiss(animated: true, completion: { 
                    // TODO: implement a parent-displayed alert vc
                })
            }
            
        }  catch {
//            print("caught one")
            parent?.dismiss(animated: true, completion: {
                // TODO: implement a parent-displayed alert vc
            })
        }
		
		// Setting the row heights for the table view
		self.tableView.rowHeight = UITableViewAutomaticDimension
		
		// Customized setup of the Interface Builder variables
//		schedLabelTextfield.delegate = self
		schedLabelTextfield.text = schedLabel
		
		intervalTimeStr = Interval.stringFromTimeValue(timeValueHours, timeValueMins: timeValueMins)
		intervalLabelCell.detailTextLabel?.text = intervalTimeStr
		
//		intervalTimePicker.dataSource = self
//		intervalTimePicker.delegate = self
		
//		notesTextview.delegate = self
		notesTextview.text = notes
		
		if notes != nil && notes != "" {
			notesTextviewPlaceholder.placeholder = ""
		}
		
		useLocationSwitch.isOn = false
		useLocation = useLocationSwitch.isOn
		
		startLocTextfield.isEnabled = false
		endLocTextfield.isEnabled = false
		
	}
	
	func backFromSearch(_ mapItem: MKMapItem?, withStreetAddress address: String, atIndex index: Int) {
		
		guard let mItem = mapItem else {
			
			// Needs to be re-implemented
//			displayAlertWithTitle("No Location", message: "Could not find the requested location")
			return
			
		}
		
		switch index {
			
		case 0:
			startLocation = mItem
			startLocTextfield.text = startLocation?.name
			mapView.removeAnnotation(startAnnotation)
			startAnnotation = LocationAnnotation(coordinate: startLocation!.placemark.coordinate, title: startLocation!.name, subtitle: address)
			mapView.addAnnotation(startAnnotation)
			
		case 1:
			endLocation = mItem
			endLocTextfield.text = endLocation?.name
			mapView.removeAnnotation(endAnnotation)
			endAnnotation = LocationAnnotation(coordinate: endLocation!.placemark.coordinate, title: endLocation!.name, subtitle: address)
			mapView.addAnnotation(endAnnotation)
			
		default:
			break
			
		}
		
		if startLocation != nil && endLocation != nil {
			
			if directionsOverlay != nil {
				mapView.remove(directionsOverlay!)
			}
			
			let directionsRequest = MKDirectionsRequest()
			directionsRequest.source = startLocation
			directionsRequest.destination = endLocation
			directionsRequest.requestsAlternateRoutes = false
			directionsRequest.transportType = MKDirectionsTransportType.automobile
			
			let directions = MKDirections(request: directionsRequest)
			directions.calculate(completionHandler: {
				(response: MKDirectionsResponse?, error: Error?) -> Void in
				
				guard let response = response else {
					return
				}
				self.showRoute(response)
				
			})
			
		}
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		
		// Show the keyboard for the scheduleLabelTextfield when the view has appeared if it is empty
		if schedLabelTextfield.text!.isEmpty {
			schedLabelTextfield.becomeFirstResponder()
		}
		
	}
	
	@IBAction func saveEntry(_ sender: UIBarButtonItem) {
		
		if schedLabelTextfield.text!.isEmpty || schedLabelTextfield.text == nil {
			
			// Alert the user that an entry cannot be saved if it does not have a scheduleLabel
			displayAlertWithTitle("Empty Field!", message: "Cannot leave Schedule Label empty")
			
        } else {
			
			// Save entry information (and location information if it's present) and dismiss the view
//			entries.append(Interval(mainLabel: mainLabel, scheduleLabel: schedLabel, timeValueHours: timeValueHours, timeValueMins: timeValueMins, notesStr: notes, usesLocation: useLocation, startLoc: startLocation?.placemark, endLoc: endLocation?.placemark))
            let newEntry = Interval(scheduleLabel: schedLabel, timeValueHours: timeValueHours, timeValueMins: timeValueMins, notesStr: notes, usesLocation: useLocation, startLoc: startLocation?.placemark, endLoc: endLocation?.placemark)
            entries.append(newEntry)
			performUpdateOnCoreData()
			
			dismiss(animated: true, completion: nil)
			
		}
		
	}
	
	@IBAction func cancelEntry(_ sender: UIBarButtonItem) {
		
		// Close the view controller without committing any changes to the persistent store
		dismiss(animated: true, completion: nil)
		
	}
	
	
	// MARK: - Text field delegate and action
	
	@IBAction func schedLabelDidChange(_ sender: UITextField) {
		
		// Set the schedLabel with its textfield
		schedLabel = sender.text!.trimmingCharacters(in: CharacterSet.whitespaces)
		
	}
	
	func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		
		// Hide the eventDatePicker if beginning to edit the textfield
		if pickerHidden == false {
			
			togglePicker()
			
		}
		
		return true
		
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		
		textField.resignFirstResponder()
        
        // Set the schedLabel with it's textfield
        schedLabel = textField.text
        
		return true
		
	}
    
    
    // MARK: - Core Data helper
	
	// Update the new entry in the event
    func prepareForUpdateOnCoreData() {
        
        event.entries = self.entries as NSArray
        
    }
    
//	func performUpdateOnCoreData() {
//		
//		guard let moc = self.moc else {
//			return
//		}
//		
//		if moc.hasChanges {
//			
//			do {
//				try moc.save()
//			} catch {
//			}
//			
//		}
//		
//	}
	
	
	// MARK: - Text view delegate and action
	
	func textViewDidChange(_ textView: UITextView) {
		
		// Set the notes with its textview
		notes = textView.text.trimmingCharacters(in: CharacterSet.whitespaces)
		
		if notes == nil || notes == "" {
			
			notesTextviewPlaceholder.placeholder = "Notes"
			
		} else {
			
			notesTextviewPlaceholder.placeholder = ""
			
		}
		
	}
	
	func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
		
		// Hide the eventDatePicker if beginning to edit the textview
		if pickerHidden == false {
			
			togglePicker()
			
		}
		
		return true
		
	}
	
	func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
		
		textView.resignFirstResponder()
		
		// Set the notes with its textview
		notes = textView.text.trimmingCharacters(in: CharacterSet.whitespaces)
		
		return true
		
	}
	
	override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		
		notesTextview.resignFirstResponder()
		
	}
	
	
	// MARK: - Table view data source
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
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
	
    
    // MARK: - Table view delegate
    
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		if indexPath.section == 0 {
			
			if indexPath.row == 2 {
				
				togglePicker()
				
			}
			
		} else if indexPath.section == 1 && (indexPath.row == 1 || indexPath.row == 2) {
			
			loadSearchControllerWithTitle((tableView.cellForRow(at: indexPath)?.contentView.subviews[1] as! UILabel).text, mapView: self.mapView)
			
		}
		
	}
	
	
	// MARK: - Picker view data source and delegate
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		
		return 3
		
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		
		if component == 0 {
			
			return 24
			
		} else if component == 1 {
			
			return 1
			
		} else {
			
			return 60
			
		}
		
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		
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
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		
		if component == 0 {
			
			timeValueHours = row
			
		}
		
		if component == 2 {
			
			timeValueMins = row
			
		}
		
		intervalTimeStr = Interval.stringFromTimeValue(timeValueHours, timeValueMins: timeValueMins)
		intervalLabelCell.detailTextLabel?.text = intervalTimeStr
		
	}
	
	func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
		
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
			self.tableView.insertRows(at: [IndexPath(row: 3, section: 0)], with: UITableViewRowAnimation.fade)
			schedLabelTextfield.resignFirstResponder()
			notesTextview.resignFirstResponder()
			
		} else {
			
			self.tableView.deleteRows(at: [IndexPath(row: 3, section: 0)], with: UITableViewRowAnimation.fade)
			
		}
		
		pickerHidden = !pickerHidden
		
		self.tableView.endUpdates()
		
		self.tableView.deselectRow(at: IndexPath(row: 2, section: 0), animated: true)
		
	}
	
	
	// MARK: - Location management
	
	@IBAction func useLocationSwitchFlipped(_ sender: UISwitch) {
		
		if sender.isOn {
			checkForLocationPermission()
		} else {
			locationManager?.stopUpdatingLocation()
		}
		useLocationPrev = useLocation
		useLocation = sender.isOn
		toggleUseLocation()
		
	}
	
	private func checkForLocationPermission() {
		
		if CLLocationManager.locationServicesEnabled() {
			
			switch CLLocationManager.authorizationStatus() {
				
			case .authorizedAlways:
				createLocationManager(true)
				
			case .authorizedWhenInUse:
				createLocationManager(true)
				
			case .denied:
				useLocationSwitch.isOn = false
				displayAlertWithTitle("Denied", message: "Location services are not allowed for this app")
				
			case .notDetermined:
				createLocationManager(false)
				guard let locationManager = self.locationManager else {
					displayAlertWithTitle("Error Starting Location Services", message: "Please try again later")
					break
				}
				locationManager.requestWhenInUseAuthorization()
				
			case .restricted:
				useLocationSwitch.isOn = false
				displayAlertWithTitle("Restricted", message: "Location services are not allowed for this app")
				
			}
			
		}
		
	}
	
	private func displayAlertWithTitle(_ title: String?, message: String?) {
		
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
		alertController.addAction(dismissAction)
		
		self.present(alertController, animated: true, completion: nil)
		
	}
	
	private func createLocationManager(_ startImmediately: Bool) {
		
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
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		
		switch status {
			
		case .authorizedAlways:
			mapView.showsUserLocation = true
			
		case .authorizedWhenInUse:
			mapView.showsUserLocation = true
			
		case .denied:
			useLocationSwitch.isEnabled = false
			
		case .restricted:
			useLocationSwitch.isEnabled = false
			
		case .notDetermined:
			checkForLocationPermission()
			
		}
		
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
		guard let err = error as? CLError else {
			
			let alertController = UIAlertController(title: "Error LocX", message: "An unknown error occurred: \"\(error)\"\nTry contacting support with a screenshot.", preferredStyle: UIAlertControllerStyle.alert)
			let dismissBtn = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default) { (action: UIAlertAction) -> Void in
				
				manager.stopUpdatingLocation()
				self.useLocationSwitch.setOn(false, animated: true)
				self.useLocationPrev = self.useLocation
				self.useLocation = self.useLocationSwitch.isOn
				self.toggleUseLocation()
				
			}
			alertController.addAction(dismissBtn)
			
			self.present(alertController, animated: true, completion: nil)
			
			return
		}
		
		if err.code != CLError.Code.locationUnknown {
			
			let alertController = UIAlertController(title: "Error \(err.code)", message: "Location manager failed: \(err) -- Please contact support via the App Store with a screenshot of this error.", preferredStyle: UIAlertControllerStyle.alert)
			let dismissBtn = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default) { (action: UIAlertAction) -> Void in
				
				manager.stopUpdatingLocation()
				self.useLocationSwitch.setOn(false, animated: true)
				self.useLocationPrev = self.useLocation
				self.useLocation = self.useLocationSwitch.isOn
				self.toggleUseLocation()
				
			}
			alertController.addAction(dismissBtn)
			
			self.present(alertController, animated: true, completion: nil)

		}		
			
	}
	
	func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
		
		if mapView.annotations.count < 3 {
			
			let span = MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4)
			let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: span)
			
			mapView.setRegion(region, animated: true)
			
		}
		
	}
	
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		
		let renderer = MKPolylineRenderer(overlay: overlay)
		renderer.strokeColor = UIColor(red: 8/255, green: 156/255, blue: 1.0, alpha: 1.0)
		renderer.lineWidth = 5.0
		
		return renderer
		
	}
	
	private func showRoute(_ response: MKDirectionsResponse) {
		
		for route in response.routes {
			
			mapView.add(route.polyline, level: MKOverlayLevel.aboveRoads)
			directionsOverlay = (mapView.overlays )[0]
			
			let timeInInt = Int((route.expectedTravelTime))
			timeValueHours = timeInInt / 3600
			timeValueMins = timeInInt / 60 % 60
			intervalTimeStr = Interval.stringFromTimeValue(timeValueHours, timeValueMins: timeValueMins)
			intervalLabelCell.detailTextLabel?.text = intervalTimeStr
			
		}
		
	}
	
	func mapView(_ mapView: MKMapView, didAdd renderers: [MKOverlayRenderer]) {
		
		var zoomRect = MKMapRectNull
		
		for annotation in mapView.annotations {
			
			let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
			let pointRec = MKMapRect(origin: MKMapPoint(x: annotationPoint.x - 50.0, y: annotationPoint.y - 50.0), size: MKMapSize(width: 100.0, height: 100.0))
			zoomRect = MKMapRectUnion(zoomRect, pointRec)
			
		}
		
		mapView.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 35.0, left: 35.0, bottom: 35.0, right: 35.0), animated: true)
		
	}
	
	@IBAction func openRouteInMaps(_ sender: UIButton) {
		
		guard let startLocation = startLocation, let endLocation = endLocation else {
			displayAlertWithTitle("Can't Open Route", message: "Make sure there are locations for both Start and End")
			return
		}

		let launchOptions = [
			MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving,
			MKLaunchOptionsMapTypeKey : MKMapType.standard.rawValue,
			MKLaunchOptionsShowsTrafficKey : true,
			MKLaunchOptionsMapCenterKey : NSValue(mkCoordinate: self.mapView.region.center),
			MKLaunchOptionsMapSpanKey : NSValue(mkCoordinateSpan: self.mapView.region.span)
		] as [String : Any]
		
		MKMapItem.openMaps(with: [startLocation, endLocation], launchOptions: launchOptions)
		
	}
	
	
	// MARK: - Location-based fields show/hide
	
	private func toggleUseLocation() {
		
		let rowsToChange = [
			
			IndexPath(row: 1, section: 1),
			IndexPath(row: 2, section: 1),
			IndexPath(row: 3, section: 1)
			
		]
		
		self.tableView.beginUpdates()
		
		if useLocation && useLocationPrev == false {
			
//			mapView.delegate = self
			self.tableView.insertRows(at: rowsToChange, with: UITableViewRowAnimation.fade)
			schedLabelTextfield.resignFirstResponder()
			notesTextview.resignFirstResponder()
			
		} else if !useLocation && useLocationPrev == true {
			
			self.tableView.deleteRows(at: rowsToChange, with: UITableViewRowAnimation.fade)
			
		}
		
		self.tableView.endUpdates()
		
	}
	
	private func loadSearchControllerWithTitle(_ title: String?, mapView: MKMapView) {
		
		let searchNavVC = self.storyboard?.instantiateViewController(withIdentifier: "searchNavVC") as! UINavigationController
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
		
		if mapView.userLocation.location != nil {
			
			CLGeocoder().reverseGeocodeLocation(mapView.userLocation.location!, completionHandler: { (placemarks, error) in
				
				guard let placemarks = placemarks , placemarks.count > 0 else {
					
					self.displayAlertWithTitle("Location Error", message: "Unable to confirm your current location. Please try again later.")
					return
					
				}
				
				let userCurrentLocation = placemarks[0]
				searchVC.userCurrentLocation = MKMapItem(placemark: MKPlacemark(placemark: userCurrentLocation))
				searchVC.tableView.reloadData()
				
			})
			
		}
		
		searchVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
		self.present(searchNavVC, animated: true, completion: nil)
		
	}
	
	
	// MARK: - Navigation
	
	override func viewWillDisappear(_ animated: Bool) {
		
		// Make sure that the keyboards are all away
		schedLabelTextfield.resignFirstResponder()
		notesTextview.resignFirstResponder()
		
	}

}
