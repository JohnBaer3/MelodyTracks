//
//  MapViewController.swift
//  MelodyTracks
//
//  Created by Daniel Loi on 7/14/20.
//  Last Edited by John A. on 7/17/20
//

import UIKit
import FloatingPanel //https://github.com/SCENEE/FloatingPanel
import AVKit
import CoreLocation
import MapKit

class MapViewController: UIViewController, FloatingPanelControllerDelegate, CLLocationManagerDelegate, MKMapViewDelegate{
    //passed from MapViewController
    var audioPlayer: AVAudioPlayerNode?
    var SongsArr: [Song]?
    
    var fpc: FloatingPanelController!
    
    @IBOutlet weak var timerNum: UILabel!
    // link to storyboard map
    @IBOutlet weak var mapView: MKMapView!
    
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
    var counter = 0  //holds value of timer

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: MapViewController.startNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: MapViewController.finishNotification, object: nil)
        //Starts the timer upon screen load
        runTimer()
        //Has to manually show bottom screen
        showBottomSheet()
        
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
    /**
     * Method name: <#name#>
     * Description: <#description#>
     * Parameters: <#parameters#>
     */
    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mapToCustom"{
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let controller = segue.destination as! CustomCurtainViewController
                controller.selectedName = objects[indexPath.row]
            }
        }
    }*/
    
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
        
        //make sure the overlay is a polyline, then continue on with the line setup
        assert(overlay is MKPolyline, "overlay must be a line")
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
            print(timerNum.text)
            vc.modalPresentationStyle = .currentContext
            present(vc, animated: true, completion:nil)
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
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    /**
     * Method name: pauseTimer
     * Description: Pauses timer
     * Parameters: N/A
     */
    @objc func pauseTimer(){
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
        counter = 0
    }
    /**
     * Method name: timerAction
     * Description: increments timer and sets label text
     * Parameters: N/A
     */
    @objc func timerAction() {
        counter += 1
        timerNum.text = timeString(time: TimeInterval(counter))
    }
    /**
     * Method name: viewWillDisappear
     * Description: called when the view is removed from the stack. In this case, it is just used to remove observers.
     * Parameters: a boolean
     */
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: MapViewController.startNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: MapViewController.finishNotification, object: nil)
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
