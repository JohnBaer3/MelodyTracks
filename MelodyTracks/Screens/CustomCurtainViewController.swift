//
//  CustomCurtainViewController.swift
//  MelodyTracks
//
//  Created by Daniel Loi on 7/6/20.
//

import UIKit
import SweetCurtain
import MediaPlayer
import AVFoundation
import AVKit



class CustomCurtainViewController: UIViewController, MPMediaPickerControllerDelegate{
    
    var audioPlayer = MPMusicPlayerController.systemMusicPlayer
    var PlayPauseBool = true
    // set notification name
    static let selectionViewNotification = Notification.Name("selectionViewNotification")
    static let homeScreenFinishNotification = Notification.Name("homeScreenFinishNotification")
    static let showBPMNotification = Notification.Name("showBPMNotification")

    @IBOutlet weak var BPM: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var song: UILabel!
    @IBOutlet weak var artist: UILabel!
    @IBOutlet weak var albumCover: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        
        //set corner of bottom controller
        view.layer.cornerRadius = 10
        albumCover.layer.cornerRadius = 10
        
        //used to set heights of bottom controller
        self.curtainController?.curtain.minHeightCoefficient = 0 //0
        self.curtainController?.curtain.midHeightCoefficient = 0.33 //0.109
        self.curtainController?.curtain.maxHeightCoefficient = 0.33
        self.curtainController?.curtain.swipeResistance = CurtainSwipeResistance.high
        self.curtainController?.moveCurtain(to: CurtainHeightState.hide, animated: false)
        
        pauseButton.isHidden = true
        setControlStatus(status: false)
        
        setSliderBPM()
        
        //setting up audio player
        audioPlayer.beginGeneratingPlaybackNotifications()
        //check to see if there is current audio playing
        if (audioPlayer.nowPlayingItem != nil){
            setSongDetails(audioPlayer.nowPlayingItem)
            if (audioPlayer.playbackState == MPMusicPlaybackState.playing){ //set pause if music is playing
                pausePlayer()
            }
        }
        
        //add observer for song change
        NotificationCenter.default.addObserver(self, selector: #selector(systemSongDidChange(_:)), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: audioPlayer)
        //add observer for adding songs from Selection view
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: CustomCurtainViewController.selectionViewNotification, object: nil)
        //add observer for adding songs from homeScreen view
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: CustomCurtainViewController.homeScreenFinishNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: CustomCurtainViewController.showBPMNotification, object: nil)

    }
    /**
     * Method name: disableControls
     * Description: disables music player controls
     * Parameters: control status
     */
    func setControlStatus(status: Bool){ 
        
        playButton.isEnabled = status
        backButton.isEnabled = status
        forwardButton.isEnabled = status
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
     * Method name: onNotification
     * Description: used to receive song data from various views
     * Parameters: notification object
     */
    @objc func onNotification(notification:Notification)
    {
        if notification.name.rawValue == "selectionViewNotification"{
            //Play song after clicked save in selection view
            print("Play song after clicked save in selection view")
            audioPlayer = notification.userInfo?["player"] as! MPMusicPlayerController as! MPMusicPlayerController & MPSystemMusicPlayerController
            playPlayer()
            setSliderBPM()
            setControlStatus(status: true)
            BPM.isEnabled = (notification.userInfo?["fixedOrAuto"])! as! Bool
            slider.isEnabled = (notification.userInfo?["fixedOrAuto"])! as! Bool
            NotificationCenter.default.post(name: SelectionViewController.TimerNotification, object: nil, userInfo:["play": true])
            //show curtain view
            self.curtainController?.moveCurtain(to: CurtainHeightState.mid, animated: false)
        }else if notification.name.rawValue == "homeScreenFinishNotification"{
            //Stop everything because finished is tapped
            pausePlayer()
            //get rid of curtain view
            self.curtainController?.moveCurtain(to: CurtainHeightState.hide, animated: true)
            setControlStatus(status: false)
        }else if notification.name.rawValue == "showBPMNotification"{
            self.curtainController?.moveCurtain(to: CurtainHeightState.mid, animated: true)
        }
    }
    /**
     * Method name: systemSongDidChange
     * Description: func used to detect song changes
     * Parameters: notification
    */
    @objc
    func systemSongDidChange(_ notification: Notification) {
        guard let playerController = notification.object as? MPMusicPlayerController else {
            return
        }
        let item = playerController.nowPlayingItem
        setSongDetails(item)
    }
    /**
     * Method name: setSongDetails
     * Description: set song details on the UI
     * Parameters: MPMediaItem
     */
    func setSongDetails(_ item: MPMediaItem?){
        albumCover.image = item?.artwork?.image(at: albumCover.intrinsicContentSize)
        artist.text = item?.albumArtist
        song.text = item?.title
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
    * Method name: fastForwardTapped
    * Description: listener for fast forward button
    * Parameters: button that is mapped to this func
    */
    @IBAction func fastForwardTapped(_ sender: UIButton) {
        audioPlayer.skipToNextItem()
    }
    /**
    * Method name: backwardTapped
    * Description: listener for backwards button
    * Parameters: button that is mapped to this func
    */
    @IBAction func backwardTapped(_ sender: Any) {
        audioPlayer.skipToPreviousItem()
    }
    /**
    * Method name: playPauseButtonTapped
    * Description: listener for play/pause button
    * Parameters: button that is mapped to this func
    */
    @IBAction func playPauseButtonTapped(_ sender: UIButton) {
        if pauseButton.isHidden == false{
            pausePlayer()
            NotificationCenter.default.post(name: SelectionViewController.TimerNotification, object: nil, userInfo:["play": false])
        }else{
            playPlayer()
            NotificationCenter.default.post(name: SelectionViewController.TimerNotification, object: nil, userInfo:["play": true])
        }
    }
    /**
     * Method name: pausePlayer
     * Description: pauses player
     * Parameters: N/A
     */
    func pausePlayer(){
        pauseButton.isHidden = true
        playButton.isHidden = false
        audioPlayer.pause()
    }
    /**
     * Method name: playPlayer
     * Description: plays player
     * Parameters: N/A
     */
    func playPlayer(){
        pauseButton.isHidden = false
        playButton.isHidden = true
        audioPlayer.play()
    }
    /**
    * Method name: deinit
    * Description: called when view is destroyed
    * Parameters: N/A
    */
    deinit {
        print("getting rid of view")
        //stop listening to notifications
        NotificationCenter.default.removeObserver(self, name: CustomCurtainViewController.selectionViewNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: CustomCurtainViewController.homeScreenFinishNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: CustomCurtainViewController.showBPMNotification, object: nil)
        audioPlayer.endGeneratingPlaybackNotifications()
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
}
