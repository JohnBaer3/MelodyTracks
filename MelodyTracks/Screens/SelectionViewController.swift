//
//  SelectionViewController.swift
//  MelodyTracks
//
//  Created by Daniel Loi on 7/6/20.
//  Copyright © 2020 Daniel Loi. All rights reserved.
//

import UIKit
import MediaPlayer
import SweetCurtain

class SelectionViewController: UIViewController, MPMediaPickerControllerDelegate {
    @IBOutlet weak var MPH: UILabel!
    @IBOutlet weak var saveButton: selectSongButton!
    @IBOutlet weak var selector: UISegmentedControl!
    @IBOutlet weak var customStepper: UIStackView!
    // set notification name
    static let showFinishNotification = Notification.Name("showFinishNotification")
    static let TimerNotification = Notification.Name("TimerNotification")
    
    var audioPlayer = MPMusicPlayerController.systemMusicPlayer
    var hideFinishButton: Bool!
    
    var higherBoundMPH = 15
    var lowerBoundMPH = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.setInitialDetails()
        setInitialMPH()
        //check to see if there is current audio playing
        if (audioPlayer.nowPlayingItem != nil){
            if (audioPlayer.playbackState == MPMusicPlaybackState.playing){ //set pause if music is playing
                audioPlayer.pause()
            }
        }
        
        //add observer for Start button from Curtain view
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: SelectionViewController.TimerNotification, object: nil)
    }
    /**
     * Method name: setInitialMPH
     * Description: sets MPH to the saved value
     * Parameters: N/A
     */
    @objc
    func setInitialMPH(){
        if UserDefaults.standard.object(forKey: "Pace") != nil{
            MPH.text = UserDefaults.standard.object(forKey: "Pace") as? String
        }else{
            MPH.text = String(90)
        }
    }
    /**
     * Method name: onNotification
     * Description: used to receive song data from Selection view
     * Parameters: notification object
     */
    @objc func onNotification(notification:Notification)
    {
        //print("NOTIFICATION IS WORKING")
        /*if notification.name.rawValue == "TimerNotification"{
            // used to control timer when paused or resumed
            if (notification.userInfo?["play"])! as! Bool {
                print("timer started")
                runTimer()
            }else{
                timer.invalidate()
            }
        }*/
    }
    /**
     * Method name: incrementMPH
     * Description: Increments the MPH, but MPH to 15
     * Parameters: N/A
     */
    @IBAction func incrementMPH(_ sender: Any) {
        let MPHInt: Int? = Int(MPH.text!)
        if MPHInt! < higherBoundMPH{
            MPH.text = String(MPHInt! + 1)
            UserDefaults.standard.set(MPH.text, forKey:"Pace") // save value
        }
    }
    /**
     * Method name: decrementMPH
     * Description: Decrements the MPH, but MPH to 0
     * Parameters: N/A
     */
    @IBAction func decrementMPH(_ sender: Any) {
        let MPHInt: Int? = Int(MPH.text!)
        if MPHInt! > lowerBoundMPH{
            MPH.text = String(MPHInt! - 1)
            UserDefaults.standard.set(MPH.text, forKey:"Pace") // save value
        }
    }
    
    /**
    * Method name: saveButtonTapped
    * Description: Once tapped, this button dismisses the view and returns the previous screen. It also sends data to the previous screen.
    * Parameters: the UI element mapped to this function
    */
    @IBAction func saveButtonTapped(_ sender: Any) {
        if saveButton.title(for: .normal) == "Select Songs"{
            let picker = MPMediaPickerController(mediaTypes:MPMediaType.anyAudio)
            picker.allowsPickingMultipleItems = true
            picker.showsCloudItems = true
            picker.delegate = self
            saveButton.setSaveIcon()
            self.present(picker, animated:false, completion:nil)
        }else if saveButton.title(for: .normal) == "Start Run!"{  //send data to Curtain View because Save has been tapped
            NotificationCenter.default.post(name: CustomCurtainViewController.selectionViewNotification, object: nil, userInfo:["player": audioPlayer, "MPH": MPH.text!])
            
            //code to show Map View
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
            NotificationCenter.default.post(name: MapViewController.startNotification, object: nil, userInfo:["start": true])
            NotificationCenter.default.post(name: CustomCurtainViewController.showMPHNotification, object: nil, userInfo:["show": true])
            vc.modalPresentationStyle = .currentContext
            present(vc, animated: true, completion:nil)
        }else{ //show MPH when bottom screen is minimized
            NotificationCenter.default.post(name: CustomCurtainViewController.showMPHNotification, object: nil, userInfo:["showMPHTapped": true])
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
        saveButton.setSelectSongIcon() // forces user to select song
        self.dismiss(animated: false, completion:nil)
    }
    
    deinit{
        //stop listening to notifications
        NotificationCenter.default.removeObserver(self, name: SelectionViewController.TimerNotification, object: nil)
    }
}

