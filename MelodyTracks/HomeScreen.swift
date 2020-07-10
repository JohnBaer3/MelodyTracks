//  Daniel Loi
//  HomeScreen.swift
//  MelodyTracks
//
//
//

import UIKit

class HomeScreen: UIViewController{
    @IBOutlet weak var finishButton: finishButton!
    @IBOutlet weak var timerNum: UILabel!
    @IBOutlet weak var startButton: startButton!
    // set notification name
    static let showFinishNotification = Notification.Name("showFinishNotification")
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
        timerNum.isHidden = true
        
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow") //used to remove tiny bar between navigation bar and view
        //add observer for adding songs from Selection view
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: HomeScreen.showFinishNotification, object: nil)
        //add observer for Start button from Curtain view
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: HomeScreen.TimerNotification, object: nil)
        startButton.setInitialDetails()
        
    }
    /**
     * Method name: startJogTapped
     * Description: Listener the Start Button
     * Parameters: button mapped to this function
     */
    @IBAction func startJogTapped(_ sender: Any) {
        if(startButton.currentTitle == "Start"){ // Start Tapped
            print("start tapped")
            //if start clicked bring up the selection view
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "SelectionViewController") as! SelectionViewController
            vc.modalPresentationStyle = .popover
            //essential for delegate https://www.youtube.com/watch?v=DBWu6TnhLeY
            //vc.selectionDelegate = self  //Removed bc notifications used to send data
            present(vc, animated: true, completion:nil)
        }else if (startButton.currentTitle == "Show BPM"){
            NotificationCenter.default.post(name: CustomCurtainViewController.showBPMNotification, object: nil, userInfo:["showBPMTapped": true])
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
     * Method name: onNotification
     * Description: used to receive song data from Selection view
     * Parameters: notification object
     */
    @objc func onNotification(notification:Notification)
    {
        if notification.name.rawValue == "showFinishNotification"{
            //runs when saved is clicked on selection view
            finishButton.isHidden = false
            startButton.setBPMIcon()
        }else if notification.name.rawValue == "TimerNotification"{
            // used to control timer when paused or resumed
            if (notification.userInfo?["play"])! as! Bool {
                print("timer started")
                timerNum.isHidden = false
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
    * Description: Listener for the Stop Button
    * Parameters: button mapped to this function
    */
    @IBAction func finishTapped(_ sender: Any) {
        NotificationCenter.default.post(name: CustomCurtainViewController.homeScreenFinishNotification, object: nil, userInfo:["finishTapped":true])
        
        resetUI()
    }
    /**
    * Method name: resetUI
    * Description: Resets UI elements to original positions
    * Parameters: N/A
    */
    @objc func resetUI(){
        finishButton.isHidden = true
        timerNum.isHidden = true
        startButton.setStartIcon()
        //reset timer
        timer.invalidate()
        timerNum.text = "00:00:00"
        counter = 0
    }
    deinit{
        //stop listening to notifications
        NotificationCenter.default.removeObserver(self, name: HomeScreen.showFinishNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: HomeScreen.TimerNotification, object: nil)
    }
    
}
