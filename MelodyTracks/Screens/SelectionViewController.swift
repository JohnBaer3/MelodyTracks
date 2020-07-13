//
//  SelectionViewController.swift
//  MelodyTracks
//
//  Created by Daniel Loi on 7/6/20.
//  Copyright © 2020 Daniel Loi. All rights reserved.
//

import UIKit
import MediaPlayer

class SelectionViewController: UIViewController, MPMediaPickerControllerDelegate {
    @IBOutlet weak var BPM: UILabel!
    @IBOutlet weak var literalBPM: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var save: startButton!
    @IBOutlet weak var saveButton: selectSongButton!
    @IBOutlet weak var finishButton: finishButton!
    @IBOutlet weak var timerNum: UILabel!
    @IBOutlet weak var selector: UISegmentedControl!
    // set notification name
    static let showFinishNotification = Notification.Name("showFinishNotification")
    static let TimerNotification = Notification.Name("TimerNotification")
    
    var audioPlayer = MPMusicPlayerController.systemMusicPlayer
    var hideFinishButton: Bool!
    var fixedOrAuto: Bool!
    var timer = Timer()
    var counter = 0  //holds value of timer
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.setInitialDetails()
        setSliderBPM()
        finishButton.setInitialDetails()
        finishButton.isHidden = true
        timerNum.isHidden = true
        //add observer for Start button from Curtain view
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: SelectionViewController.TimerNotification, object: nil)
    }
    /**
     * Method name: onNotification
     * Description: used to receive song data from Selection view
     * Parameters: notification object
     */
    @objc func onNotification(notification:Notification)
    {
        print("NOTIFICATION IS WORKING")
        if notification.name.rawValue == "TimerNotification"{
            // used to control timer when paused or resumed
            if (notification.userInfo?["play"])! as! Bool {
                print("timer started")
                runTimer()
            }else{
                timer.invalidate()
            }
        }
    }
    /**
     * Method name: setSliderBPM
     * Description: sets the slider and BPM to the saved value
     * Parameters: N/A
     */
    @objc
    func setSliderBPM(){
        if UserDefaults.standard.object(forKey: "Pace") != nil{
            BPM.text = UserDefaults.standard.object(forKey: "Pace") as? String
        }else{
            BPM.text = String(90)
        }
        slider.value = Float(Int(BPM.text!)!)
    }
    /**
    * Method name: slider
    * Description: func to set slider value
    * Parameters: slider element
    */
    @IBAction func slider(_ sender: UISlider) {
        BPM.text = String(Int(sender.value))
        print(BPM.text!)
        UserDefaults.standard.set(BPM.text, forKey:"Pace")
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
     * Method name: timerAction
     * Description: increments timer and sets label text
     * Parameters: N/A
     */
    @objc func timerAction() {
        counter += 1
        timerNum.text = timeString(time: TimeInterval(counter))
    }
    /**
    * Method name: runningUI
    * Description: Show running UI
    * Parameters: N/A
    */
    @objc func runningUI(){
        finishButton.isHidden = false
        timerNum.isHidden = false
        save.setTitle("Show BPM", for: [])
        BPM.isHidden = true
        slider.isHidden = true
        literalBPM.isHidden = true
        selector.isHidden = true
    }
    /**
    * Method name: resetUI
    * Description: Resets UI elements to original positions
    * Parameters: N/A
    */
    @objc func resetUI(){
        finishButton.isHidden = true
        timerNum.isHidden = true
        save.setTitle("Select Song", for: [])
        BPM.isHidden = false
        slider.isHidden = false
        literalBPM.isHidden = false
        selector.isHidden = false
        //reset timer
        timer.invalidate()
        timerNum.text = "00:00:00"
        counter = 0
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
     * Method name: fixedAutoSelector
     * Description: lets user choose between fixed BPM or automatic BPM
     * Parameters: the UI element mapped to this function
     */
    @IBAction func fixedAutoSelector(_ sender: UISegmentedControl) {
        if (sender.selectedSegmentIndex == 0){
            print("fixed")
            BPM.isEnabled = true
            slider.isEnabled = true
            literalBPM.isEnabled = true
            fixedOrAuto = true
        }else if(sender.selectedSegmentIndex == 1){
            print("auto")
            BPM.isEnabled = false
            slider.isEnabled = false
            literalBPM.isEnabled = false
            fixedOrAuto = false
        }
    }
    /**
    * Method name: saveButtonTapped
    * Description: Once tapped, this button dismisses the view and returns the previous screen. It also sends data to the previous screen.
    * Parameters: the UI element mapped to this function
    */
    @IBAction func saveButtonTapped(_ sender: Any) {
        if saveButton.title(for: .normal) == "Select Song"{
            let picker = MPMediaPickerController(mediaTypes:MPMediaType.anyAudio)
            picker.allowsPickingMultipleItems = true
            picker.showsCloudItems = true
            picker.delegate = self
            saveButton.setSaveIcon()
            self.present(picker, animated:false, completion:nil)
        }else if saveButton.title(for: .normal) == "Save"{  //send data to Curtain View because Save has been tapped
            NotificationCenter.default.post(name: CustomCurtainViewController.selectionViewNotification, object: nil, userInfo:["player": audioPlayer, "fixedOrAuto": fixedOrAuto ?? true, "BPM": BPM.text!])
            runningUI()
        }else{
            NotificationCenter.default.post(name: CustomCurtainViewController.showBPMNotification, object: nil, userInfo:["showBPMTapped": true])
        }
    }
    /**
     * Method name: PickSongTapped
     * Description: func to present pick song screen
     * Parameters: button that is mapped to this func
     */
    func mediaPicker(_ mediaPicker: MPMediaPickerController,
        didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        print(mediaItemCollection.count)
        for item in mediaItemCollection.items {
            if let itemName = item.value(forProperty: MPMediaItemPropertyTitle)
                as? String {
                print("Picked item: \(itemName)")
            }
        }
        print(mediaItemCollection.items)
        audioPlayer.setQueue(with: mediaItemCollection)
        self.dismiss(animated: false, completion:nil)
    }
    /**
     * Method name: mediaPickerDidCancel
     * Description: Called when cancel was clicked in Media Picker view
     * Parameters: MPMediaPickerController
     */
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        self.dismiss(animated: false, completion:nil)
    }
    
    deinit{
        //stop listening to notifications
        NotificationCenter.default.removeObserver(self, name: SelectionViewController.TimerNotification, object: nil)
    }
}

