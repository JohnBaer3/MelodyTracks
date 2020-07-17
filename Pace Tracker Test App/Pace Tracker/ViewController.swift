/*
    CoreMotion tester app
    Built for spike in sprint 1
    Designed to practice measuring pace of user's phone
    Created 6/30/20
    Last edited: 7/14/20
 */

import UIKit
import CoreMotion
import MapKit
import CoreLocation
import Dispatch


class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    /*
     * initialze the core motion activity manager
     * object that manages access to the motion data of the phone
     */
    private let activityManager = CMMotionActivityManager()
    // initialize the pedometer object for fetching the step counting/pace data
    private let pedometer = CMPedometer()
    // bool for start/stop button interaction
    private var shouldUpdate: Bool = false
    // start date variable used by all the event update functions in CM
    private var startDate: Date? = nil
    // set of binary flags used for indicating the auth status of different motion activities
    private var stepAval = 0
    private var paceAval = 0
    private var distanceAval = 0
    
    /*
     * Map access objects
     * create Core Location manager object to access location data of phone
     * declare variable for holding previous coordinate as map draws poly lines
     */
    private var locationManager:CLLocationManager!
    private var oldLocation: CLLocation?
    
    
    // links for ui storyboard to controller objects
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stepCountLabel: UILabel!
    @IBOutlet weak var currentPaceLabel: UILabel!
    @IBOutlet weak var activityTypeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    // link to storyboard MKMapView
    @IBOutlet weak var mapView: MKMapView!
    
    
    // initialize the start button before the loading of view controller
    override func viewDidLoad() {
        super.viewDidLoad()
        startButton.addTarget(self, action: #selector(didTapStartButton), for: .touchUpInside)
        
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
        mapView.mapType = MKMapType(rawValue: 0)!
        mapView.userTrackingMode = MKUserTrackingMode(rawValue: 2)!
    }
    
    // evertime the view controller updates, update the steps and pace labels
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let startDate = startDate else {
            return
        }
        updateStepsLabel(startDate: startDate)
    }
    
    // function to control the start/stop functionality of the pace tracking
    // if start button is tapped, reverse the bool and start/stop tracking accordingly
    @objc private func didTapStartButton() {
        //reverse the status of the button
        shouldUpdate = !shouldUpdate
        shouldUpdate ? (onStart()) : (onStop())
    }
    
    /*
     * CLLocation delegate
     * receives updates from the CLLocationManager object
     * increment the poly line drawn on the map
     * first get the newest location data point put in the location array
     * then save the previous location to local temp oldLocation
     * create line with updated 2d array area
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
     * create the overlay renderer used by addOverlay()
     * want small blue line to show user location history
     */
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        //make sure the overlay is a polyline, then continue on with the line setup
        assert(overlay is MKPolyline, "overlay must be a line")
        let lineRenderer = MKPolylineRenderer(overlay: overlay)
        lineRenderer.strokeColor = UIColor.blue
        lineRenderer.lineWidth = 5
        return lineRenderer
    }
}

extension ViewController {
    
    // start updating the steps label by by changing the text label for the start button
    // set the date to query data to now, cheeck authorization status, and then start actually tracking data
    private func onStart() {
        startButton.setTitle("Stop", for: .normal)
        startDate = Date()
        checkAuthStatus()
        startUpdating()
    }
    
   // reverse start/stop button text and reset the start date to null, then send message to stop updating
    private func onStop() {
        startButton.setTitle("Start", for: .normal)
        startDate = nil
        stopUpdating()
    }
    
    // check what abilities are available on the phone
    // if activity tracking, step counting, or pace tracking is available, start label updating function
    private func startUpdating() {
        if CMMotionActivityManager.isActivityAvailable() {
            startTrackingActivity()
        } else {
            activityTypeLabel.text = "Motion activity not available"
        }
        
        if CMPedometer.isStepCountingAvailable() {
            stepAval = 1
        } else {
            stepCountLabel.text = "Step counting not available"
        }
        
        // don't want to make another function for pace tracking
        // just using a binary flag to track whether pace tracking is available
        if CMPedometer.isPaceAvailable() {
            paceAval = 1
        } else {
            currentPaceLabel.text = "Pace tracking is not available"
        }
        
        if CMPedometer.isDistanceAvailable() {
            distanceAval = 1
        } else {
            distanceLabel.text = "Distance tracking is not available"
        }
        
        if stepAval == 1 || paceAval == 1 || distanceAval == 1 {
            startCountingSteps()
        }
    }
    
    // checck if the phone is allowed to access motion events as requested in the plist file
    private func checkAuthStatus() {
        switch CMMotionActivityManager.authorizationStatus() {
        case CMAuthorizationStatus.denied:
            onStop()
            activityTypeLabel.text = "Motion activity not available"
            stepCountLabel.text = "Motion activity not available"
        default:
            break
        }
    }
    
    // cleanup steps to stop tracking everything
    private func stopUpdating() {
        activityManager.stopActivityUpdates()
        pedometer.stopUpdates()
        pedometer.stopEventUpdates()
    }
    
    private func error(error: Error) {
        // handle error
        // in the future we can set up a popup notifying of the error
    }
    
    /*
     * update the steps label and the current pace label pulling from queue
     * used everytime the view controller refreshes
     * using live data instead of getting history of motion
     */
    private func updateStepsLabel(startDate: Date) {
        pedometer.queryPedometerData(from: startDate, to: Date()) {
            [weak self] pedometerData, error in
            // if there's an error, report the error
            // else get the pedometer data and put it  in the main queue for UI updates of motion of events
            // using an asynchronous queue so that the main thread isn't blocking
            if let error = error {
                self?.error(error: error)
            } else if let pedometerData = pedometerData {
                var pace: float_t?
                var paceMPH: double_t?
                if self?.paceAval == 1 {
                    pace = pedometerData.currentPace?.floatValue
                    // convert seconds per meter to m/s
                    // pace is initially set to nil, so test for that
                    if pace != nil {
                        // test for if pace is to avoid div by 0 when converting to m/s
                        // if it is, multiplying for paceMPH will still be 0 so no problem
                        if pace != 0 {
                            pace = 1/pace!
                        }
                        // turn pace into a type Double and convert to mph
                        paceMPH = Double(pace!) * 2.237
                    }
                }
                DispatchQueue.main.async {
                    if self?.stepAval == 1 {
                        self?.stepCountLabel.text = String(describing: pedometerData.numberOfSteps)
                    }
                    if self?.paceAval == 1 {
                        if pace != nil {
                            self?.currentPaceLabel.text = String(format: "%.2f", paceMPH!) + " mph"
                        } else {
                            self?.currentPaceLabel.text = pedometerData.currentPace?.stringValue
                        }
                    }
                    if self?.distanceAval == 1 {
                        let distance = pedometerData.distance!.stringValue + " meters"
                        self?.distanceLabel.text = distance
                    }
                }
            }
        }
    }

    /*
     * start tracking what activity the phone is doing (ie walking or running)
     * put the event update on the main UI queue
     * phone will automatically execute the handler block when it senses the activity changes
     */
    private func startTrackingActivity() {
        activityManager.startActivityUpdates(to: OperationQueue.main) {
            [weak self] (activity: CMMotionActivity?) in
            guard let activity = activity else { return }
            DispatchQueue.main.async {
                if activity.walking {
                    self?.activityTypeLabel.text = "Walking"
                } else if activity.stationary {
                    self?.activityTypeLabel.text = "Stationary"
                } else if activity.running {
                    self?.activityTypeLabel.text = "Running"
                } else if activity.automotive {
                    self?.activityTypeLabel.text = "Automotive"
                }
            }
        }
    }

    /*
     * start updates of the pedometer by calling CM startUpdates()
     * start reporting data from now [Date()]
     * will then repeatedly call the handler block as new pedometer data arrives
     * use the handler block to put motion events onto main UI queue asynchronously
     */
    private func startCountingSteps() {
        pedometer.startUpdates(from: Date()) {
            [weak self] pedometerData, error in
            guard let pedometerData = pedometerData, error == nil else { return }
            var pace: float_t?
            var paceMPH: double_t?
            if self?.paceAval == 1 {
                pace = pedometerData.currentPace?.floatValue
                // convert seconds per meter to m/s
                // pace is initially set to nil, so test for that
                if pace != nil {
                    // test for if pace is to avoid div by 0 when converting to m/s
                    // if it is, multiplying for paceMPH will still be 0 so no problem
                    if pace != 0 {
                        pace = 1/pace!
                    }
                    // turn pace into a type Double and convert to mph
                    paceMPH = Double(pace!) * 2.237
                }
            }
            DispatchQueue.main.async {
                if self?.stepAval == 1 {
                    self?.stepCountLabel.text = String(describing: pedometerData.numberOfSteps)
                }
                if self?.paceAval == 1 {
                    if pace != nil {
                        self?.currentPaceLabel.text = String(format: "%.2f", paceMPH!) + " mph"
                    } else {
                        self?.currentPaceLabel.text = pedometerData.currentPace?.stringValue
                    }
                }
                if self?.distanceAval == 1 {
                    let distance = pedometerData.distance!.stringValue + " meters"
                    self?.distanceLabel.text = distance
                }
            }
        }
    }
}

