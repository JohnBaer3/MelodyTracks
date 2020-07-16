//
//  SelectionViewController.swift
//  MelodyTracks
//
//  Created by Daniel Loi on 7/6/20.
//  Copyright © 2020 Daniel Loi. All rights reserved.
//

import UIKit
import MediaPlayer

//stuff from AVAudioPlayer port
//var paused = true  //moved to Custom Curtain View
//var SongsArr: [Song] = [] //moved to Custom Curtain View
//var currentSong: Song? = nil //declared in Custom Curtain View
//var currentSongIndex: Int? = nil //declared in Custom Curtain View
//var previousSongs: [Song] = [] //declared in Custom Curtain View
//let audioPlayer = AVAudioPlayerNode()

struct Song {
    var title: String = ""
    var BPM: Float = 0
    var played: Bool = false
}


class SelectionViewController: UIViewController, MPMediaPickerControllerDelegate {
    @IBOutlet weak var MPH: UILabel!
    @IBOutlet weak var saveButton: selectSongButton!
    @IBOutlet weak var customStepper: UIStackView!
    @IBOutlet weak var walkButton: UIButton!
    @IBOutlet weak var jogButton: UIButton!
    @IBOutlet weak var runButton: UIButton!
    @IBOutlet weak var fixedButton: selectorButton!
    @IBOutlet weak var autoButton: selectorButton!
    @IBOutlet weak var walkJogRunStackView: UIStackView!
    @IBOutlet weak var mphStackView: customStepper!
    @IBOutlet weak var descriptionText: UITextField!
    // set notification name
    static let showFinishNotification = Notification.Name("showFinishNotification")
    static let TimerNotification = Notification.Name("TimerNotification")
    
    //stuff from AVAudioPlayer port
    let engine = AVAudioEngine()
    let speedControl = AVAudioUnitVarispeed()
    let pitchControl = AVAudioUnitTimePitch()

    let engineBPM = AVAudioEngine()
    let speedControlBPM = AVAudioUnitVarispeed()
    let pitchControlBPM = AVAudioUnitTimePitch()
    
    var speedOfBPM:Float = 0.0
    //stuff from AVAudioPlayer port
    
    //var audioPlayer = MPMusicPlayerController.systemMusicPlayer
    let audioPlayer = AVAudioPlayerNode()
    let picker = MPMediaPickerController(mediaTypes:MPMediaType.anyAudio)
    var trackList : MPMediaItemCollection?
    var hideFinishButton: Bool!
    var SongsArr: [Song] = []
    
    var higherBoundMPH = 15
    var lowerBoundMPH = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.setInitialDetails()
        setInitialMPH()
        //check to see if there is current audio playing
        if audioPlayer.isPlaying == true {
            audioPlayer.pause()
        }
        /*if (audioPlayer.nowPlayingItem != nil){
            if (audioPlayer.playbackState == MPMusicPlaybackState.playing){ //set pause if music is playing
                audioPlayer.pause()
            }
        }*/
        fixedAutoSwap(tapped: fixedButton, other: autoButton)
        walkButton.layer.cornerRadius = 10
        jogButton.layer.cornerRadius = 10
        runButton.layer.cornerRadius = 10
        
        getBPMofSongs()
        
        //add observer for Start button from Curtain view
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: SelectionViewController.TimerNotification, object: nil)
    }
    /**
     * Method name: getBPMofSongs()
     * Description: used to get BPM of the songs in the user's library
     * Parameters: N/A
     */
    func getBPMofSongs(){
        let fm = FileManager.default
        let filePath = Bundle.main.path(forAuxiliaryExecutable: "Songs")
        let songs = try! fm.contentsOfDirectory(atPath: filePath!)
        for song in songs{
            //let filePathSong = Bundle.main.path(forResource: removeSuffix(word: song), ofType: "mp3", inDirectory: "Songs")
            //let songUrl = URL(string: filePathSong!)
            //let BPMOfSong = BPMAnalyzer.core.getBpmFrom(songUrl!, completion: nil)
            //Have to parse BPMOfSong to actually get the BPM, then convert it to Float
            let newSong = Song(title: removeSuffix(songName: song), BPM: 100)
            SongsArr.append(newSong)
        }
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
     * Method name:fixedTapped
     * Description: transforms the UI when the Fixed Button is tapped
     * Parameters: N/A
     */
    @IBAction func fixedTapped(_ sender: selectorButton) {
        fixedHideorNot(value: false)
        descriptionText.text = "Choose your pace"
        fixedAutoSwap(tapped: fixedButton, other: autoButton)
    }
    /**
     * Method name: autoTapped
     * Description: transforms the UI when the Auto Button is tapped
     * Parameters: N/A
     */
    @IBAction func autoTapped(_ sender: selectorButton) {
        fixedHideorNot(value: true)
        descriptionText.text = "Let our algorithm decide"
        fixedAutoSwap(tapped: autoButton, other: fixedButton)
        
    }
    /**
     * Method name:fixedHideorNot
     * Description: helper function to hide UI elements
     * Parameters: N/A
     */
    func fixedHideorNot(value: Bool){
        walkJogRunStackView.isHidden = value
        mphStackView.isHidden = value
    }
    /**
     * Method name: fixedAutoSwap
     * Description: used to swap color of Fixed or Auto button when one is tapped
     * Parameters: a tapped button and the other button
     */
    func fixedAutoSwap(tapped: selectorButton, other: selectorButton ){
        if (tapped.isEnabled == true){
            tapped.isSelected()
            other.isUnselected()
        }else{
            tapped.isUnselected()
            other.isSelected()
        }
    }
    /**
     * Method name: walkTapped
     * Description: Listener for the walk button. Changes MPH to 4 and saves value.
     * Parameters: N/A
     */
    @IBAction func walkTapped(_ sender: Any) {
        MPH.text = "4"
        UserDefaults.standard.set(MPH.text, forKey:"Pace") // save value
    }
    /**
     * Method name: jogTapped
     * Description:  Listener for the jog button. Changes MPH to 6 and saves value.
     * Parameters: N/A
     */
    @IBAction func jogTapped(_ sender: Any) {
        MPH.text = "6"
        UserDefaults.standard.set(MPH.text, forKey:"Pace") // save value
    }
    /**
     * Method name: runTapped
     * Description:  Listener for the run button. Changes MPH to 48and saves value.
     * Parameters: N/A
     */
    @IBAction func runTapped(_ sender: Any) {
        MPH.text = "8"
        UserDefaults.standard.set(MPH.text, forKey:"Pace") // save value
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
     * Method name: unwindToSelectionViewController
     * Description: used by the Finish button in the finish view controller to jump back to the selection view screen
     * Parameters: N/A
     */
    @IBAction func unwindToSelectionViewController(segue:UIStoryboardSegue) { }
    /**
    * Method name: saveButtonTapped
    * Description: Once tapped, this button dismisses the view and returns the previous screen. It also sends data to the previous screen.
    * Parameters: the UI element mapped to this function
    */
    @IBAction func saveButtonTapped(_ sender: Any) {
        if saveButton.title(for: .normal) == "Select Songs"{
            
            //let picker = MPMediaPickerController(mediaTypes:MPMediaType.anyAudio)
            //picker.allowsPickingMultipleItems = true
            //picker.showsCloudItems = true
            //picker.delegate = self
            saveButton.setSaveIcon()
            //self.present(picker, animated:false, completion:nil)
            
        }else if saveButton.title(for: .normal) == "Start Run!"{  //send data to Curtain View because Save has been tapped
            NotificationCenter.default.post(name: CustomCurtainViewController.selectionViewNotification, object: nil, userInfo:["player": audioPlayer, "MPH": MPH.text!])
            
            //code to show Map View
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
            //NotificationCenter.default.post(name: MapViewController.startNotification, object: nil, userInfo:["start": true])
            //NotificationCenter.default.post(name: CustomCurtainViewController.showMPHNotification, object: nil, userInfo:["show": true])
            vc.audioPlayer = audioPlayer
            vc.SongsArr = SongsArr
            vc.modalPresentationStyle = .currentContext
            present(vc, animated: true, completion:nil)
        }else{ //show MPH when bottom screen is minimized
            NotificationCenter.default.post(name: CustomCurtainViewController.showMPHNotification, object: nil, userInfo:["showMPHTapped": true])
        }
    }
    /**
     * Method name: mediaPicker
     * Description: func to present pick song screen
     * Parameters: button that is mapped to this func
     */
    //OLD MEDIA PICKER. SAVED FOR REFERENCE.
    /*func mediaPicker(_ mediaPicker: MPMediaPickerController,
        didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        print(mediaItemCollection.count)
        /*for item in mediaItemCollection.items {
            if let itemName = item.value(forProperty: MPMediaItemPropertyTitle)
                as? String {
                print("Picked item: \(itemName)")
            }
        }*/
        print(mediaItemCollection.items)
        trackList = mediaItemCollection
        audioPlayer.setQueue(with: mediaItemCollection)
        self.dismiss(animated: false, completion:nil)
    }*/
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems
        mediaItemCollection: MPMediaItemCollection) {
        guard let asset = mediaItemCollection.items.first,
            let url = asset.assetURL else {return}
        //_ = BPMAnalyzer.core.getBpmFrom(url, completion: {[weak self] (bpm) in
        //    self?.mediaPicker.dismiss(animated: true, completion: nil)
        //})
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
    
    /**
     * Method name: removeSuffix
     * Description: <#description#>
     * Parameters: <#parameters#>
     */
    //FiRST PAGE ~
    func removeSuffix(songName: String) -> String{
        var output = ""
        for letter in songName{
            if letter != "."{
                output += String(letter)
            }else{
                break
            }
        }
        return output
    }
    //~ FiRST PAGE
    
    deinit{
        //stop listening to notifications
        NotificationCenter.default.removeObserver(self, name: SelectionViewController.TimerNotification, object: nil)
    }
}

