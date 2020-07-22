//
//  MapViewController.swift
//  MelodyTracks
//  viewcontroller file for the map screen user sees while running
//
//  Created by Daniel Loi on 7/14/20.
//  Last Edited by John A. on 7/20/20
//

import UIKit
import FloatingPanel //https://github.com/SCENEE/FloatingPanel
import AVKit
import CoreLocation
import MapKit
import CoreMotion
import Dispatch



class MapViewController: UIViewController, FloatingPanelControllerDelegate, CLLocationManagerDelegate, MKMapViewDelegate{
    //passed from MapViewController
    var audioPlayer: AVAudioPlayerNode?
    var SongsArr: [Song]?
    
    var fpc: FloatingPanelController!
    
    @IBOutlet weak var timerNum: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var currentSpeedLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var uiView: UIView!
    
    /*
     * Instantiate pedometer object to access step data
     * set the start date to nil initially
     * start date used for queries to pedometer data cached on phone
     */
    private let pedometer = CMPedometer()
    private var startDate: Date? = nil
    
    /*
     * Map access objects
     * create Core Location manager object to access location data of phone
     * declare variable for holding previous coordinate as map draws poly lines
     */
    private var locationManager:CLLocationManager!
    private var oldLocation: CLLocation?
    
    static let startNotification = Notification.Name("startNotification")
    static let finishNotification = Notification.Name("finishNotification")
    
    var timer = Timer()
    //holds number of seconds elapsed
    var secondsElapsed = 0
    
    /*
     * set of bool flags for auth status of different pedometer objects
     */
    private var stepAval = false
    private var paceAval = false
    private var cadenceAval = false
    private var distanceAval = false
    private var firstTimeUpdate = true
    
    /*
     * Core Motion access variables
     * use these to access latest pace in mph, sin miles, and footsteps
     * cadence is specifically a float for audio processing
     */
    var paceMPH: String?
    var distance: String?
    var footsteps: String?
    var currentCadence: Float?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        uiView.layer.shadowColor = UIColor.black.cgColor
        uiView.layer.shadowOpacity = 1
        uiView.layer.shadowOffset = .zero
        uiView.layer.shadowRadius = 5

        // set up location manager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // complete authorization process for location services
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined || status == .denied || status == .authorizedWhenInUse {
               locationManager.requestAlwaysAuthorization()
               locationManager.requestWhenInUseAuthorization()
           }
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        
        // view current location on map
        self.mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.mapType = MKMapType.standard
        mapView.setUserTrackingMode(MKUserTrackingMode.followWithHeading, animated: true)
        let location = MKUserLocation()
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, latitudinalMeters: 500, longitudinalMeters: 500)
        self.mapView.setRegion(region, animated: true)
        
        checkAuthStatus()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: MapViewController.startNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: MapViewController.finishNotification, object: nil)
        
        //Starts the timer upon screen load
        runTimer()
        startUpdating()
        //Has to manually show bottom screen
        showBottomSheet()
    }
    
    
    /*
     * method name: checkAuthStatus
     * description: updates binary flags for what's avaialble for use on the phone
     * parameters: none
     */
    func checkAuthStatus() {
        if CMPedometer.isPaceAvailable() {
            paceAval = true
        }
        
        if CMPedometer.isDistanceAvailable() {
            distanceAval = true
        }
        
        if CMPedometer.isStepCountingAvailable() {
            stepAval = true
        }
        
        if CMPedometer.isCadenceAvailable() {
            cadenceAval = true
        }
    }
    
    /*
     * method name: startUpdating()
     * description: starts tracking footstep data and tests for if it's the first time starting updates
     * if it's not the first time starting tracking, resume location tracking as the map was paused
     * parameters: none
     */
    func startUpdating() {
        // start location tracking
        if !firstTimeUpdate {
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        }
        
        // start step tracking
        startTrackingSteps()
//        self.currentSpeedLabel.text = self.paceMPH
    }
    
    /*
     * method name: stopUpdating()
     * description: stops the updating of footstep tracking and location tracking
     * parameters: none
     */
    func stopUpdating() {
        // stop step tracking
        pedometer.stopUpdates()
        pedometer.stopEventUpdates()
        
        // stop location tracking
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
        firstTimeUpdate = false
        oldLocation = nil
    }
    
    /**
     * Method name: startTrackingSteps
     * Description: Called from startUpdating, starts the collection of pedometer data and updates values
     * Parameters: None
     */
    func startTrackingSteps() {
        pedometer.startUpdates(from: Date()) {
            [weak self] pedometerData, error in guard let pedometerData = pedometerData, error == nil else {
                return
            }
            // handler block
            if self?.cadenceAval == true {
                let cadence = pedometerData.currentCadence?.floatValue
                // cadence comes in at steps per second, want steps per minute
                // if cadence is nil, temp will just be 0 * 60 = 0 steps/min
                var tempCadence: Float = 0.0
                if cadence != nil {
                    tempCadence = cadence! * 60
                }
                
                self?.currentCadence = tempCadence
                PedometerData.shared.currentCadence = tempCadence
            }
            if self?.paceAval == true {
                var pace = pedometerData.currentPace?.floatValue
                // convert seconds per meter to m/s
                // pace is initially set to nil, so need to test for that we can safely force unwrap during conversion
                if pace != nil {
                    // test for if pace is 0 to avoid div by 0 when converting to m/s
                    // if it is, multiplying for paceMPH will still be 0 so no problem
                    if pace != 0 {
                        pace = 1/pace!
                    }
                    // turn pace into a type Double and convert to mph
                    // 1 m/s is 2.237 mph
                    let temp = Double(pace!) * 2.237
                    let paceString = String(format: "%.2f", temp)
                    self!.paceMPH = paceString
                    PedometerData.shared.footstepPace = paceString
                    
                    DispatchQueue.main.async {
                        self!.currentSpeedLabel.text = paceString
                    }
                } else {
                    // else we know the current pedometer reading is nil, so set pace to nil ourselves and the getter will handle the return
                    self?.paceMPH = nil
                    PedometerData.shared.footstepPace = nil
                }
            }
            if self?.distanceAval == true {
                let distance = pedometerData.distance?.floatValue
                
                // multiply distance by 6.24*10^(-4) for miles
                // if distance returns as nil, the distance will just be 0
                // return value will then just be 0
                var tempDistance: Float = 0.0
                if distance != nil {
                    tempDistance = distance! * 0.000621371
                }
                let distanceString = String(format: "%.2f", tempDistance)
                self?.distance = distanceString
                PedometerData.shared.distance = distanceString
                DispatchQueue.main.async {
                    self!.distanceLabel.text = distanceString
                }
            }
            if self?.stepAval == true {
                // numberOfSteps is not an optional, so no need to worry about unwrapping
                self?.footsteps = pedometerData.numberOfSteps.stringValue
                PedometerData.shared.footsteps = pedometerData.numberOfSteps.stringValue
            }
        }
    }
    
    /*
     * Method name: locationManager
     * Description: CLLocation delegate
     * receives updates from the CLLocationManager object
     * increment the poly line drawn on the map
     * first get the newest location data point put in the location array
     * then save the previous location to local temp oldLocation
     * create line with updated 2d array area
     * Parameters: CLLocationManager object, updated location array from CoreLocation
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // get newest location point
        guard let newLocation = locations.last else {
            return
        }

        // create temp local oldlocation
        // if previous location is nil, set it equal to current new location
        guard let oldLocation = self.oldLocation else {
            // Save old location
            self.oldLocation = newLocation
            return
        }
        
        // turn the CLLocation objects into coordinates
        let oldCoordinates = oldLocation.coordinate
        let newCoordinates = newLocation.coordinate
        // create the new area to be plotted
        var area = [oldCoordinates, newCoordinates]
        let polyline = MKPolyline(coordinates: &area, count: area.count)
        mapView.addOverlay(polyline)

        // Save old location
        self.oldLocation = newLocation
    }
    
    /*
     * Method name: mapView
     * Description: create the overlay renderer used by addOverlay()
     * want small blue line to show user location history
     * Parameters: MKMapView object to be rendered on, MKOverlay which actually renders the line
     */
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // make sure the overlay is a line or we don't want to run
        assert(overlay is MKPolyline)
        let lineRenderer = MKPolylineRenderer(overlay: overlay)
        lineRenderer.strokeColor = UIColor.blue
        lineRenderer.lineWidth = 5
        return lineRenderer
    }
    /**
     * Method name: showBottomSheet
     * Description: Used to show the bottom sheet
     * Parameters: N/A
     */
    func showBottomSheet(){
        // Initialize a `FloatingPanelController` object.
        fpc = FloatingPanelController()
        fpc.delegate = self
        // Set a content view controller.
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let contentVC = storyboard.instantiateViewController(withIdentifier: "CustomCurtainViewController") as! CustomCurtainViewController
        contentVC.audioPlayer = audioPlayer
        //print(SongsArr)
        contentVC.SongsArr = SongsArr
                
        fpc.set(contentViewController: contentVC)
        
        fpc.surfaceView.cornerRadius = 10
        fpc.addPanel(toParent: self)
    }
    /**
     * Method name: floatingPanel
     * Description: used to control height of bottom sheet. does not need to be called.
     * Parameters: N/A
     */
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        return MyFloatingPanelLayout()
    }
    /**
     * Method name: onNotification
     * Description: used to receive song data from Selection view
     * Parameters: notification object
     */
    @objc func onNotification(notification:Notification)
    {
        //print("NOTIFICATION IS WORKING")
        if notification.name.rawValue == "startNotification"{
            // used to control timer when paused or resumed
            if (notification.userInfo?["play"])! as! Bool {
                print("timer started")
                runTimer()
            }else{
                pauseTimer()
            }
        }else if notification.name.rawValue == "finishNotification"{
            print("finish button hit")
            //present finish screen
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "FinishViewController") as! FinishViewController
            vc.duration = timerNum.text!
            vc.SongsArr = SongsArr!
            vc.footstep = footsteps ?? "0"
            //Converts meters to miles
            vc.distance = meterToMiles(meters: distance ?? "0")
            vc.fpm = toFpm(steps: footsteps ?? "0", timeInSeconds: secondsElapsed)
            print(vc.fpm!)
            vc.modalPresentationStyle = .currentContext
            present(vc, animated: true, completion:nil)
        }
    }
    /**
     * Method name: meterToMiles
     * Description: takes in the distance in meters as a string and returns the distance in miles as a string
     * Parameters: value of distance in string
     */
    func meterToMiles(meters: String) -> String{
        let distanceInMeters = Measurement(value: Double(meters)!, unit: UnitLength.meters)
        let distanceInMiles = distanceInMeters.converted(to: UnitLength.miles)
        //print(distanceInMiles)
        return MeasurementFormatter().string(from: distanceInMiles)
    }
    /**
     * Method name: toFpm
     * Description: takes in steps and time to calculate FPM, or BPM
     * Parameters: number of steps as a String and the time elapsed in seconds as an Integer
     * Return: FPM as a String
     */
    func toFpm(steps: String, timeInSeconds: Int) -> String{
        // this prevents division by 0
        if secondsElapsed / 60 == 0{
            return steps
        }else{
            return String(Int(footsteps ?? "0")! / (secondsElapsed / 60))
        }
    }
    /**
     * Method name: timeString
     * Description: Formats timer
     * Parameters: N/A
     */
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    /**
     * Method name: runTimer
     * Description: Runs timer
     * Parameters: N/A
     */
    @objc func runTimer(){
        if !firstTimeUpdate {
            startUpdating()
        }
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    /**
     * Method name: pauseTimer
     * Description: Pauses timer
     * Parameters: N/A
     */
    @objc func pauseTimer(){
        // when timer is being paused, we should pause motion and location tracking
        stopUpdating()
        timer.invalidate()
    }
    /**
     * Method name: resetTimer
     * Description: Resets timer
     * Parameters: N/A
     */
    @objc func resetTimer(){
        timer.invalidate()
        timerNum.text = "00:00:00"
        secondsElapsed = 0
    }
    /**
     * Method name: timerAction
     * Description: increments timer and sets label text
     * Parameters: N/A
     */
    @objc func timerAction() {
        secondsElapsed += 1
        timerNum.text = timeString(time: TimeInterval(secondsElapsed))
    }
    /**
     * Method name: viewWillDisappear
     * Description: called when the view is removed from the stack. In this case, it is just used to remove observers.
     * Parameters: a boolean
     */
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: MapViewController.startNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: MapViewController.finishNotification, object: nil)
        
        // end tracking as the run is over
        stopUpdating()
    }

}
class MyFloatingPanelLayout: FloatingPanelLayout {
    public var initialPosition: FloatingPanelPosition {
        return .tip
    }
    public var supportedPositions: Set<FloatingPanelPosition> {
        return [.half, .tip]
    }
    var topInteractionBuffer: CGFloat { return 0.0 }
    var bottomInteractionBuffer: CGFloat { return 0.0 }
    

    func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
        case .full: return 16.0 // A top inset from safe area
        case .half: return 300.0 // A bottom inset from the safe area
        case .tip: return 85.0 // A bottom inset from the safe area
        default: return nil
        }
    }

    func backdropAlphaFor(position: FloatingPanelPosition) -> CGFloat {
        return 0.0
    }
}
/*
 * Shared pedometer data class
 * Should only be used to get the current data of footstep tracking
 */
class PedometerData {
    /*
     * shared instance of the PedometerData class
     * use this to access get functions
     * calling a get function looks like PedometerData.shared.getCadence()
     */
    static let shared = PedometerData()
    
    /*
     * shared variables for pedometer data
     * updated everytime pedometer handler gets new data
     */
    var distance: String?
    var footstepPace: String?
    var footsteps: String?
    var currentCadence: Float?
    
    /*
     * Method name: getPace()
     * Description: returns unwrapped string for current footstep pace
     * Parameters: none
     */
    func getPace() -> String {
        if CMPedometer.isPaceAvailable() {
            return self.footstepPace ?? "0"
        } else {
            return "N/A"
        }
    }
    
    /*
    * Method name: getPace()
    * Description: returns unwrapped string for current number of steps
    * Parameters: none
    */
    func getSteps() -> String {
        if CMPedometer.isStepCountingAvailable() {
            return self.footsteps ?? "0"
        } else {
            return "N/A"
        }
    }
    
    /*
    * Method name: getPace()
    * Description: returns unwrapped string for current distance traveled
    * Parameters: none
    */
    func getDistance() -> String {
        if CMPedometer.isDistanceAvailable() {
            return self.distance ?? "0"
        } else {
            return "N/A"
        }
    }
    
    /*
     * Method name: getCadence()
     * Description: returns unwrapped float for current cadence
     * Returns 0 if current cadence isn't available or is nil
     * Parameters: none
     */
    func getCadence() -> Float {
        if CMPedometer.isCadenceAvailable() {
            return self.currentCadence ?? 0
        } else {
            return 0
        }
    }
}
