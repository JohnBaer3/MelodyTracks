//  Daniel Loi
//  HomeScreen.swift
//  MelodyTracks
//
//
//

import UIKit

class HomeScreen: UIViewController{
    @IBOutlet weak var homeBarItem: UINavigationItem!
    @IBOutlet weak var finishButton: finishButton!
    @IBOutlet weak var timerNum: UILabel!
    
    static let showFinishNotification = Notification.Name("showFinishNotification") // set notification name
    static let TimerNotification = Notification.Name("TimerNotification")
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    var timer = Timer()
    var counter = 0  //holds value of timer
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //used to set corner buttons
        finishButton.setInitialDetails()
        finishButton.isHidden = true
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow") //used to remove tiny bar between navigation bar and view
        //add observer for adding songs from Selection view
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: HomeScreen.showFinishNotification, object: nil)
        //add observer for Start button from Curtain view
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: HomeScreen.TimerNotification, object: nil)
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
     * Method name: onNotification
     * Description: used to receive song data from Selection view
     * Parameters: notification object
     */
    @objc func onNotification(notification:Notification)
    {
        if notification.name.rawValue == "showFinishNotification"{
            finishButton.isHidden = false
        }else if notification.name.rawValue == "TimerNotification"{
            if (notification.userInfo?["play"])! as! Bool {
                print("timer started")
                runTimer()
            }else{
                timer.invalidate()
            }
        }
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
    * Method name: FinishTapped
    * Description: Listener for the Stop Button on the top left corner
    * Parameters: button mapped to this function
    */
    @IBAction func FinishTapped(_ sender: Any) {
        NotificationCenter.default.post(name: CustomCurtainViewController.homeScreenFinishNotification, object: nil, userInfo:["finishTapped":true])
        finishButton.isHidden = true
        //reset timer
        timer.invalidate()
        timerNum.text = "00:00:00"
        counter = 0
    }
    deinit{
        //stop listening to notifications
        NotificationCenter.default.removeObserver(self, name: HomeScreen.showFinishNotification, object: nil)
    }
}
