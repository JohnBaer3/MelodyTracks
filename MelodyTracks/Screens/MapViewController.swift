//
//  MapViewController.swift
//  MelodyTracks
//
//  Created by Daniel Loi on 7/14/20.
//  Copyright © 2020 Daniel Loi. All rights reserved.
//

import UIKit
import FloatingPanel //https://github.com/SCENEE/FloatingPanel

class MapViewController: UIViewController, FloatingPanelControllerDelegate{
    
    var fpc: FloatingPanelController!
    
    @IBOutlet weak var timerNum: UILabel!
    
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
        
        
    }
    /**
     * Method name: showBottomSheet
     * Description: Used to show the bottom sheet
     * Parameters: <#parameters#>
     */
    func showBottomSheet(){
        // Initialize a `FloatingPanelController` object.
        fpc = FloatingPanelController()
        fpc.delegate = self
        // Set a content view controller.
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let contentVC = storyboard.instantiateViewController(withIdentifier: "CustomCurtainNavController") as! UINavigationController
        fpc.set(contentViewController: contentVC)

        fpc.surfaceView.cornerRadius = 10
        fpc.addPanel(toParent: self)
    }
    /**
     * Method name: floatingPanel
     * Description: <#description#>
     * Parameters: <#parameters#>
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
            vc.modalPresentationStyle = .currentContext
            vc.duration = timerNum.text
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
     * Description: <#description#>
     * Parameters: <#parameters#>
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
