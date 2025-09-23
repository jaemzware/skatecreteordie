//
//  MapViewController.swift
//  skatecreteordie
//
//  Created by JAMES K ARASIM on 3/26/16.
//  Copyright 2016-2024 jaemzware llc
//  Licensed under the Apache License, Version 2.0
//
import UIKit
import MapKit
import CoreLocation
import SwiftUI

extension Date {
    func string(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITabBarDelegate  {
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var dropCurrentLocationPinButton: UIButton!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var skateParkMapView: MKMapView!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var maptextview: UITextView!
    @IBOutlet weak var pathEnableControl: UISegmentedControl!
    @IBOutlet weak var milesLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var onOffSwitch: UISegmentedControl!
    var lastSkatepark:SkatePark? = nil;
    var defaultSkateparkEntry:SkatePark? = nil;
    var locationManager: CLLocationManager = CLLocationManager() //used to detect current location
    dynamic var deviceLocationAnnotation = MKPointAnnotation()
    let skateParkDataUrl = ConfigurationManager.shared.parkDataBaseURL
    var annotationCurrentLocation = MKPointAnnotation()
    var initialMapZoomAnnotationStart: CustomPointAnnotation?
    var initialMapZoomAnnotationEnd: CustomPointAnnotation?
    var initialMapZoomed:Bool = false
    var pinsHaveBeenDropped: Bool = false
    var coordinates:[CLLocationCoordinate2D] = []
    var detailButton: UIButton = UIButton(type: UIButton.ButtonType.detailDisclosure) as UIButton
    var polyline:MKPolyline? = nil;
    var timer: Timer?
    var startTime: TimeInterval = 0.0
    var elapsedTime: TimeInterval = 0.0
    var isTimerRunning = false
    var currentFilterPinImage: String? = nil
    var skateParks:[SkatePark] = {() -> [SkatePark] in
        var skateParkArray:[SkatePark] = Array<SkatePark>()
        return skateParkArray
    }()
    @IBAction func indexChanged(_ sender: Any) {
        switch onOffSwitch.selectedSegmentIndex {
        case 0:
            initializeLocationManager(locationManager: locationManager)
        case 1:
            stopUpdatingLocation()
        default:
            break
        }
    }
    @IBAction func resetPath(_ sender: Any) {
        coordinates = []
    }
    @IBAction func dropCurrentLocationPin(_ sender: AnyObject) {
        self.centerLocation()
    }
    @IBAction func copyTextButton(_ sender: AnyObject) {
        UIPasteboard.general.string = self.maptextview.text
    }
    @IBAction func filterButtonTapped(_ sender: Any) {
        let uniquePinImages = Array(Set(skateParks.compactMap { $0.pinimage }))
            .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
        
        let filterView = PinFilterView(
            onSelection: { [weak self] selectedPinImage in
                self?.refreshAnnotations(filterPinImage: selectedPinImage)
            },
            pinImages: uniquePinImages
        )
        
        let hostingController = UIHostingController(rootView: filterView)
        
        // Use popover on iPad, sheet on iPhone
        if UIDevice.current.userInterfaceIdiom == .pad {
            hostingController.modalPresentationStyle = .popover
            if let popover = hostingController.popoverPresentationController {
                popover.sourceView = filterButton
                popover.sourceRect = filterButton.bounds
                popover.permittedArrowDirections = .any
            }
        } else {
            hostingController.modalPresentationStyle = .pageSheet
            if let sheet = hostingController.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = true
            }
        }
        
        present(hostingController, animated: true)
    }
    @objc func buttonAction(sender: UIButton!) {
        tabBarController?.selectedIndex = 1
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set button background colors
        filterButton.backgroundColor = UIColor.systemBlue
        filterButton.layer.cornerRadius = 8.0
        
        //INITIALIZE MAP VIEW PROPERTIES
        initializeMapViewProperties(skateParkMapView: self.skateParkMapView)
        
        //INITIALIZE A WAY TO TAP THE DETAIL TAB BUTTON FOR THE PIN ANNOTATIONS
        detailButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        //PROVIDE HARDCODED PARK INFORMATION BEFORE GETTING LATEST FROM CLOUD
        self.dropPinToStaticLocalSkateParks()
        
        //INITIALIZE THE GEOCODE TEXT BOX
        self.maptextview.text = "Loading..."
        
        //TRACKING OFF BY DEFAULT
        onOffSwitch.selectedSegmentIndex = 1
        hideTrackingElements()
        
        //SETUP REQUEST FOR GETTING PARK INFORMATION IN THE CLOUD
        let requestURL: URL = URL(string: skateParkDataUrl)!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(
            url: requestURL,
            cachePolicy: .reloadIgnoringLocalCacheData,
            timeoutInterval: 8.0
        )
                
        //KICK OFF A SHARED DATA TASK TO OBTAIN SKATEPARK INFORMATION FROM skateParkDataUrl ()
        let SESSION = URLSession.shared.dataTask(with: urlRequest as URLRequest) {
            (data, response, error) -> Void in
            //IF WE WERE ABLE TO GET A RESPONSE
            if let httpResponse = response {
                let statusCode = (httpResponse as! HTTPURLResponse).statusCode
                //IF IT WAS AN OK RESPONSE
                if (statusCode == 200) {
                    //IF THE DATA IS NOT NIL (IF THIS ASSIGNMENT DOESN'T FAIL)
                    if let _ = data {
                        do{
                            //READ JSON DATA INTO AN ARRAY OF OBJECTS (SKATEPARKS)
                            let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String:AnyObject]
                            if let jsonskateparks = json["skateparks"] as? [[String: AnyObject]] {
                                //REMOVE ALL STATIC PARKS
                                self.skateParks.removeAll()
                                print("jsonskateparks COUNT: \(jsonskateparks.count)")
                                //ITERATE THROUGH ARRAY OF OBJECTS (SKATEPARKS)
                                var numParks = 0;
                                for skatepark in jsonskateparks {
                                    //IF EVERY PIECE OF SKATEPARK INFORMATION IS FILLED IN FOR THE OBJECT (SKATEPARK)
                                    if let name = skatepark["name"] as? String,
                                        let address = skatepark["address"] as? String,
                                        let id = skatepark["id"] as? String,
                                        let builder = skatepark["builder"] as? String,
                                        let sqft = skatepark["sqft"] as? String,
                                        let lights = skatepark["lights"] as? String,
                                        let covered = skatepark["covered"] as? String,
                                        let url = skatepark["url"] as? String,
                                        let elements = skatepark["elements"] as? String,
                                        let pinimage = skatepark["pinimage"] as? String,
                                        let photos = skatepark["photos"] as? String,
                                        let latitude = skatepark["latitude"] as? String,
                                        let longitude = skatepark["longitude"] as? String,
                                        let group = skatepark["group"] as? String
                                    {
                                        //BUILD A PHOTOS ARRAY FROM THE PHOTOS KEY VALUE OF IMAGE NAMES SEPARATED BY SPACES
                                        let photosArray = photos.trimmingCharacters(in:
                                                .whitespacesAndNewlines)
                                                .components(separatedBy: " ")
                                        //ADD THE PARK TO THE SKATEPARKS ARRAY
                                        //THAT WILL BE USED TO POPULATE THE MAP
                                        //AND PROVIDE DATA FOR THE DETAILS VIEW (SECOND VIEW CONTROLLER)
                                        self.skateParks.append(
                                            SkatePark(
                                                name:name,
                                                address:address,
                                                id:id,
                                                builder: builder,
                                                sqft: sqft,
                                                lights: lights,
                                                covered: covered,
                                                url: url,
                                                elements: elements,
                                                pinimage: pinimage,
                                                photos: photosArray,
                                                latitude: latitude,
                                                longitude: longitude,
                                                group: group
                                            )
                                        )
                                        print("FOUND A PARK, APPENDED \(name)")
                                        numParks = numParks + 1;
                                    }
                                }
                                print("FOUND PARKS: \(numParks)");
                            }
                        }
                        catch{
                            print("ERROR server response: \(statusCode.description)")
                     }
                        self.dropPinToOnlineDynamicSkateParks()
                    }
                }
                else{
                    print("NON 200 RESPONSE RESPONSE ATTEMPTING TO OBTAIN SKATEAPARK: \(statusCode.description)")
                }
            }
            else{
                print("NO SERVER RESPONSE ATTEMPTING TO OBTAIN SKATEPARK INFORMATION")
            }
        }
        
        self.centerOverUnitedStates()
        
        //KICK OFF THE SESSION
        SESSION.resume()
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is CustomPointAnnotation) {
            return nil
        }
        
        let cpa = annotation as! CustomPointAnnotation
        let reuseId = cpa.annotationId
        
        var anView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId!)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView!.canShowCallout = true
        }
        else {
            anView!.annotation = annotation
        }
        
        //Set annotation-specific properties **AFTER**
        //the view is dequeued or created...
        anView!.image = UIImage(named:cpa.imageName)
        anView!.rightCalloutAccessoryView = detailButton
        
        return anView
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView){
        //only do this for our custom skatepark annotation
        if view.annotation is CustomPointAnnotation {
            //save the last skatepark tapped for details view state
            if let annotationSkatepark = view.annotation as! CustomPointAnnotation?{
                lastSkatepark = annotationSkatepark.skatepark
                    //DISPLAY COORDINATES IN STATUS OUTPUT
                    if let lat = lastSkatepark!.latitude{
                        if let lon = lastSkatepark!.longitude {
                            maptextview.text = "\(lat),\(lon)"
                        }
                }
                        
            }
        }
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

        if let routePolyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: routePolyline)
            renderer.strokeColor = UIColor.green.withAlphaComponent(0.9)
            renderer.lineWidth = 1
            return renderer
        }

        return MKOverlayRenderer()
    }
    fileprivate func dropPinToOnlineDynamicSkateParks() {
        DispatchQueue.main.async {
            self.refreshAnnotations()
            self.maptextview.text = "Latest skatepark data loaded"
        }
    }
    func refreshAnnotations(filterPinImage: String? = nil) {
        // Update the current filter state
        currentFilterPinImage = filterPinImage
        
        // Update button title and color to reflect current filter
        DispatchQueue.main.async {
            if let filterName = filterPinImage {
                self.filterButton.setTitle("Filter: \(filterName)", for: .normal)
                self.filterButton.backgroundColor = UIColor.systemOrange // Orange when filtered
            } else {
                self.filterButton.setTitle("Filter", for: .normal)
                self.filterButton.backgroundColor = UIColor.systemBlue // Blue when not filtered
            }
        }
        
        let annotationsToRemove = skateParkMapView.annotations.filter { $0 !== skateParkMapView.userLocation }
        skateParkMapView.removeAnnotations(annotationsToRemove)
        
        let filteredParks = filterPinImage == nil ?
            skateParks :
            skateParks.filter { $0.pinimage == filterPinImage }
            
        for aPark in filteredParks {
            let aSkateparkAnnotation = CustomPointAnnotation()
            aSkateparkAnnotation.skatepark = aPark
            aSkateparkAnnotation.imageName = aPark.pinimage
            aSkateparkAnnotation.annotationId = aPark.id
            aSkateparkAnnotation.title = aSkateparkAnnotation.skatepark.name
            aSkateparkAnnotation.subtitle = aSkateparkAnnotation.skatepark.address
            aSkateparkAnnotation.accessibilityLabel = aPark.id
            pinCoordinatesForDestinationAddress(aSkateparkAnnotation)
        }
        
        if let filterPinImage = filterPinImage {
            maptextview.text = "Showing parks with pin image: \(filterPinImage)"
        } else {
            maptextview.text = "Showing all parks"
        }
    }
    fileprivate func dropPinToStaticLocalSkateParks() {
        guard let url = Bundle.main.url(forResource: "skateparkdata", withExtension: "json") else {
            print("JSON file not found")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            
            if let skateparks = json?["skateparks"] as? [[String: Any]] {
                for skatepark in skateparks {
                    if let name = skatepark["name"] as? String,
                       let address = skatepark["address"] as? String,
                       let id = skatepark["id"] as? String,
                       let builder = skatepark["builder"] as? String,
                       let sqft = skatepark["sqft"] as? String,
                       let lights = skatepark["lights"] as? String,
                       let covered = skatepark["covered"] as? String,
                       let url = skatepark["url"] as? String,
                       let elements = skatepark["elements"] as? String,
                       let pinimage = skatepark["pinimage"] as? String,
                       let photos = skatepark["photos"] as? String,
                       let latitude = skatepark["latitude"] as? String,
                       let longitude = skatepark["longitude"] as? String,
                       let group = skatepark["group"] as? String {
                        
                        let photosArray = photos.trimmingCharacters(in: .whitespacesAndNewlines)
                            .components(separatedBy: " ")
                        
                        let skatePark = SkatePark(
                            name: name,
                            address: address,
                            id: id,
                            builder: builder,
                            sqft: sqft,
                            lights: lights,
                            covered: covered,
                            url: url,
                            elements: elements,
                            pinimage: pinimage,
                            photos: photosArray,
                            latitude: latitude,
                            longitude: longitude,
                            group: group
                        )
                        
                        self.skateParks.append(skatePark)
                        
                        // Set the last park loaded as the default
                        self.lastSkatepark = skatePark
                        self.defaultSkateparkEntry = skatePark
                    }
                }
                
                for aPark in self.skateParks {
                    let aSkateparkAnnotation = CustomPointAnnotation()
                    aSkateparkAnnotation.skatepark = aPark
                    aSkateparkAnnotation.imageName = aPark.pinimage
                    aSkateparkAnnotation.annotationId = aPark.id
                    aSkateparkAnnotation.title = aSkateparkAnnotation.skatepark.name
                    aSkateparkAnnotation.subtitle = aSkateparkAnnotation.skatepark.address
                    aSkateparkAnnotation.accessibilityLabel = aPark.id
                    pinCoordinatesForDestinationAddress(aSkateparkAnnotation)
                }
            }
        } catch {
            print("Error loading skateparks: \(error)")
        }
    }
    func pinCoordinatesForDestinationAddress(_ annotation: CustomPointAnnotation) -> Void {
        let destinationLocation = CLLocationCoordinate2D(
            latitude: CLLocationDegrees(annotation.skatepark.latitude!)!,
            longitude: CLLocationDegrees(annotation.skatepark.longitude!)!
        )
        
        annotation.coordinate = destinationLocation
        
        // If this is being called from dynamic loading (not static), update the default
        if self.pinsHaveBeenDropped {
            self.lastSkatepark = annotation.skatepark
            self.defaultSkateparkEntry = annotation.skatepark
        }
        
        //run add annotation from main thread instead of the background process that calls this
        DispatchQueue.main.async {
            self.skateParkMapView.addAnnotation(annotation)
        }
        self.pinsHaveBeenDropped = true
    }
    func clearOverlay(){
        let overlays = self.skateParkMapView.overlays
        self.skateParkMapView.removeOverlays(overlays)
    }
    func initializeMapViewProperties(skateParkMapView:MKMapView){
        skateParkMapView.delegate = self
        skateParkMapView.mapType = .hybridFlyover
        skateParkMapView.isZoomEnabled = true
        skateParkMapView.isScrollEnabled = true
        skateParkMapView.showsUserLocation = true
    }
    
    func initializeLocationManager(locationManager: CLLocationManager) {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        
        switch locationManager.authorizationStatus {
            case .authorizedAlways:
                switch locationManager.accuracyAuthorization {
                    case .fullAccuracy:
                        startUpdatingLocation()
                    case .reducedAccuracy:
                        onOffSwitch.selectedSegmentIndex = 1
                        indexChanged(onOffSwitch!)
                        showLocationPermissionsAlert()
                    @unknown default:
                        break
                }
            case .authorizedWhenInUse, .notDetermined, .restricted, .denied:
                onOffSwitch.selectedSegmentIndex = 1
                indexChanged(onOffSwitch!)
                showLocationPermissionsAlert()
            @unknown default:
                break
        }
    }
    func showLocationPermissionsAlert() {
        // Handle the case when location permission is restricted or denied
        // Show an alert to request permission
        let alertController = UIAlertController(
            title: "Location \"Always\" and \"Precise\" Required",
            message: "skatecreteordie needs Location \"Always\" with \"Precise location\" enabled to track your park lines.\n\nThis data is neither stored nor shared, and goes away whenever the path is reset or the app is closed.\n\n1. Open Settings and tap \"Location\"\n2. Tap \"Always\"\n3. Switch on \"Precise Location\" \n4. Return to skatecreteordie",
            preferredStyle: .alert
        )
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            // Turn off the switch
            self?.onOffSwitch.selectedSegmentIndex = 1
            self?.indexChanged(self?.onOffSwitch ?? UISegmentedControl())
        }
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let viewController = window.rootViewController {
            viewController.present(alertController, animated: true, completion: nil)
        }    }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
            case .authorizedAlways:
                switch manager.accuracyAuthorization {
                    case .fullAccuracy:
                        onOffSwitch.selectedSegmentIndex = 0
                        indexChanged(onOffSwitch!)
                        startUpdatingLocation()
                    case .reducedAccuracy:
                        onOffSwitch.selectedSegmentIndex = 1
                        indexChanged(onOffSwitch!)
                        showLocationPermissionsAlert()
                    @unknown default:
                        break
                }
            case .notDetermined, .restricted, .denied, .authorizedWhenInUse:
                onOffSwitch.selectedSegmentIndex = 1
                indexChanged(onOffSwitch!)
                showLocationPermissionsAlert()
            @unknown default:
                break
        }
    }
    func startUpdatingLocation(){
        self.maptextview.text = "Locking location ..."
        locationManager.startUpdatingLocation()
        skateParkMapView.showsUserLocation = true
        startTimer()
        showTrackingElements()
    }
    func stopUpdatingLocation(){
        locationManager.stopUpdatingLocation()
        skateParkMapView.showsUserLocation = false
        stopTimer()
        hideTrackingElements()
        clearOverlay()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        //get the updated location coordinate
        for location in locations{
            self.coordinates.append(location.coordinate)
        }
        
        //REMOVE THE OLD PATH AND MAKE WAY FOR A NEW ONE
        if let oldPolyLine = self.polyline {
            skateParkMapView.removeOverlay(oldPolyLine);
        }
        
        //DRAW NEW PATH
        self.polyline = MKPolyline(coordinates: self.coordinates, count: self.coordinates.count)
        skateParkMapView.addOverlay(self.polyline!)
        
        //SHOW LOCATION AND DISTANCE
        distanceTapped()
        
        //UPDATE THE TIMER
        updateTimerLabel()
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clErr = error as? CLError {
            switch clErr {
            case CLError.locationUnknown:
                self.maptextview.text = "location manager: location unknown error"
            case CLError.denied:
                self.maptextview.text = "location manager: location denied error"
                DispatchQueue.main.async {
                    self.onOffSwitch.selectedSegmentIndex = 1
                    self.indexChanged(self.onOffSwitch!)
                }
            default:
                self.maptextview.text = "location manager: location failed error"
            }
        } else {
            self.maptextview.text = "other error: \(error.localizedDescription)"
        }
    }
    func applicationWillTerminate(_ application: UIApplication) {
        stopUpdatingLocation()
    }
    func showTrackingElements() {
        resetButton.isHidden = false
        dropCurrentLocationPinButton.isHidden = false
        milesLabel.isHidden = false
        timeLabel.isHidden = false
    }
    func hideTrackingElements() {
        resetButton.isHidden = true
        dropCurrentLocationPinButton.isHidden = true
        milesLabel.isHidden = true
        timeLabel.isHidden = true
    }
    func startTimer(){
        startTime = Date().timeIntervalSinceReferenceDate
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateTimerLabel()
        }
        isTimerRunning = true
    }
    func stopTimer(){
        timer?.invalidate()
        isTimerRunning = false
        elapsedTime = 0
    }
    func updateTimerLabel() {
        let timeToShow = elapsedTime + (isTimerRunning ? Date().timeIntervalSinceReferenceDate - startTime : 0)
        let minutes = Int(timeToShow / 60)
        let seconds = Int(timeToShow.truncatingRemainder(dividingBy: 60))
        timeLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
    func centerOverUnitedStates() {
            // Set initial region to cover the United States
            let initialLocation = CLLocationCoordinate2D(latitude: 40.76204712778915,  longitude:-111.90812528041526) // Center of the United States (San Francisco as an example)
            let regionRadius: CLLocationDistance = 2500000 // 2500 kilometers (adjust as needed)
            let coordinateRegion = MKCoordinateRegion(center: initialLocation, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
            skateParkMapView.setRegion(coordinateRegion, animated: true)
    }
    func centerLocation(){
        var centerCoordinate = self.skateParkMapView.userLocation.coordinate as CLLocationCoordinate2D
        var getLat: CLLocationDegrees = centerCoordinate.latitude
        var getLon: CLLocationDegrees = centerCoordinate.longitude
        if "\(getLat) \(getLon)" == "0.0 0.0"{
            getLat = CLLocationDegrees(self.lastSkatepark!.latitude!)!
            getLon = CLLocationDegrees(self.lastSkatepark!.longitude!)!
            centerCoordinate = CLLocationCoordinate2D(latitude: getLat, longitude: getLon);
        }
        // Adjust the span based on the size of the skate park
        let latitudeDelta = 0.0000001 // Adjust this value to control the zoom level
        let longitudeDelta = 0.0000001 // Adjust this value to control the zoom level
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        self.skateParkMapView.setRegion(region, animated: true)
        self.maptextview.text =
            "\(String(format:"%.8f",centerCoordinate.latitude)),\(String(format:"%.8f",centerCoordinate.longitude))"
    }
    func distanceTapped() {
        var total: Double = 0.0
        for i in 0..<self.coordinates.count - 1 {
            let start = self.coordinates[i]
            let end = self.coordinates[i + 1]
            let distance = getDistance(from: start, to: end)
            total += distance
        }
        self.maptextview.text = "\(String(format: "%.8f", self.coordinates[self.coordinates.count-1].latitude)),\(String(format: "%.8f", self.coordinates[self.coordinates.count-1].longitude))"
        let totalMiles = total/1609;
        let totalKilometers = totalMiles * 1.60934;
        self.milesLabel.text = "\(String(format: "%.4f", totalMiles))mi (\(String(format: "%.4f", totalKilometers))km)"
    }
    func getDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return from.distance(from: to)
    }
    func zoomToAnnotation(withId id: String) {
        // First, check if we need to clear the filter to show the selected park
        if let currentFilter = currentFilterPinImage {
            // Find the park with the given id
            if let selectedPark = skateParks.first(where: { $0.id == id }) {
                // Check if the selected park's pinimage matches the current filter
                if selectedPark.pinimage != currentFilter {
                    // Clear the filter to show all parks including the selected one
                    refreshAnnotations(filterPinImage: nil)
                }
            }
        }
        
        // Find the annotation with matching id
        if let annotation = skateParkMapView.annotations.first(where: { annotation in
            if let customAnnotation = annotation as? CustomPointAnnotation {
                return customAnnotation.annotationId == id
            }
            return false
        }) {
            // Set the region to zoom to the annotation
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
            skateParkMapView.setRegion(region, animated: true)
            
            // Select the annotation to show its callout
            skateParkMapView.selectAnnotation(annotation, animated: true)
        }
    }
}
