/*
    CoreMotion tester app
    Built for spike in sprint 1
    Designed to practice measuring pace of user's phone
 */

import UIKit
import CoreMotion
import Dispatch


class ViewController: UIViewController {
    
    // get live walking data
    // setup core motion objects
    private let activityManager = CMMotionActivityManager()
    private let pedometer = CMPedometer()
    private var shouldUpdate: Bool = false
    private var startDate: Date? = nil
    private var paceAval = 0
    
    // links for ui storyboard to controller objects
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stepCountLabel: UILabel!
    @IBOutlet weak var currentPaceLabel: UILabel!
    @IBOutlet weak var activityTypeLabel: UILabel!
    
    // first function loaded when application opens (I think)
    // start with just setting up the start button so when the user presses it the tracking starts
    override func viewDidLoad() {
        super.viewDidLoad()
        startButton.addTarget(self, action: #selector(didTapStartButton), for: .touchUpInside)
    }
    
    // notify view controller that it's about to be added to view hierarchy
    // start updating the steps label
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let startDate = startDate else {
            return
        }
        updateStepsLabel(startDate: startDate)
    }
    
    // if start button is tapped, reverse the bool and start/stop tracking accordingly
    @objc private func didTapStartButton() {
        //reverse the status of the button
        shouldUpdate = !shouldUpdate
        shouldUpdate ? (onStart()) : (onStop())
    }
}

extension ViewController {
    
    // steps to start tracking
    private func onStart() {
        startButton.setTitle("Stop", for: .normal)
        startDate = Date()
        checkAuthStatus()
        startUpdating()
    }
    
    // steps to stop tracking
    private func onStop() {
        startButton.setTitle("Start", for: .normal)
        startDate = nil
        stopUpdating()
    }
    
    // check what abilities are available on the phone
    // if activity is available, start updating it
    private func startUpdating() {
        if CMMotionActivityManager.isActivityAvailable() {
            startTrackingActivity()
        } else {
            activityTypeLabel.text = "Motion activity not available"
        }
        
        if CMPedometer.isStepCountingAvailable() {
            startCountingSteps()
        } else {
            stepCountLabel.text = "Motion activity not available"
        }
        
        // don't want to make another function for pace tracking
        // just using a binary flag to track whether pace tracking is available
        if CMPedometer.isPaceAvailable() {
            paceAval = 1
        } else {
            currentPaceLabel.text = "Current pace is not available"
        }
    }
    
    // check if the phone is allowed to access motion events as requested in the plist file
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
    
    // update the steps label and the current pace label pulling from queue
    // using live data instead of getting history of motion
    private func updateStepsLabel(startDate: Date) {
        pedometer.queryPedometerData(from: startDate, to: Date()) {
            [weak self] pedometerData, error in
            // if there's an error, report the error
            // else pull from the queue and update the step and pace labels
            if let error = error {
                self?.error(error: error)
            } else if let pedometerData = pedometerData {
                DispatchQueue.main.async {
                    self?.stepCountLabel.text = String(describing: pedometerData.numberOfSteps)
                    if self?.paceAval == 1 {
                        self?.currentPaceLabel.text = String(describing: pedometerData)
                    }
                }
            }
        }
    }

    // start tracking what activity the phone is doing
    // again just throw the event update to the main queue for UI updates
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

    // put motion events onto the queue
    // convert to string values so they can easily update the labels
    // using an asynchronous queue so that the main thread isn't blocking
    private func startCountingSteps() {
        pedometer.startUpdates(from: Date()) {
            [weak self] pedometerData, error in
            guard let pedometerData = pedometerData, error == nil else { return }
            DispatchQueue.main.async {
                self?.stepCountLabel.text = pedometerData.numberOfSteps.stringValue
                if self?.paceAval == 1 {
                    self?.currentPaceLabel.text = pedometerData.currentPace?.stringValue
                }
            }
        }
    }
}

