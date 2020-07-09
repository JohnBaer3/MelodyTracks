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
    static let selectionViewNotification = Notification.Name("selectionViewNotification") // set notification name
    static let homeScreenFinishNotification = Notification.Name("homeScreenFinishNotification") // set notification name

    @IBOutlet weak var BPM: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var song: UILabel!
    @IBOutlet weak var artist: UILabel!
    @IBOutlet weak var albumCover: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var startButton: startButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        
        //set corner of bottom controller
        view.layer.cornerRadius = 10
        
        //used to set heights of bottom controller
        self.curtainController?.curtain.minHeightCoefficient = 0.109
        self.curtainController?.curtain.midHeightCoefficient = 0.35
        self.curtainController?.curtain.maxHeightCoefficient = 0.65
        pauseButton.isHidden = true
        setControlStatus(status: false)
        
        setSliderBPM()
        startButton.setInitialDetails()
        
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
            startButton.setPauseIcon()
            playPlayer()
            setSliderBPM()
            setControlStatus(status: true)
            BPM.isEnabled = (notification.userInfo?["fixedOrAuto"])! as! Bool
            slider.isEnabled = (notification.userInfo?["fixedOrAuto"])! as! Bool
            NotificationCenter.default.post(name: HomeScreen.TimerNotification, object: nil, userInfo:["play": true])
        }else if notification.name.rawValue == "homeScreenFinishNotification"{
            //Stop everything because finished is tapped
            startButton.setStartIcon()
            pausePlayer()
            setControlStatus(status: false)
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
     * Method name: StartJogTapped
     * Description: Listener the Start Button on the top right corner
     * Parameters: button mapped to this function
     */
    @IBAction func StartJogTapped(_ sender: Any) {
        if (startButton.currentTitle == "Pause"){ // Pause Tapped
            NotificationCenter.default.post(name: HomeScreen.TimerNotification, object: nil, userInfo:["play": false])
            pausePlayer()
            startButton.setResumeIcon()
        }else if(startButton.currentTitle == "Start"){ // Start Tapped
            print("start tapped")
            //if start clicked bring up the selection view
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "SelectionViewController") as! SelectionViewController
            vc.modalPresentationStyle = .popover
            //essential for delegate https://www.youtube.com/watch?v=DBWu6TnhLeY
            //vc.selectionDelegate = self  //Removed bc notifications used to send data
            present(vc, animated: true, completion:nil)
        }else{ // Resume Tapped
            NotificationCenter.default.post(name: HomeScreen.TimerNotification, object: nil, userInfo:["play": true])
            playPlayer()
            startButton.setPauseIcon()
        }
        
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
    * Method name: FastForwardTapped
    * Description: listener for fast forward button
    * Parameters: button that is mapped to this func
    */
    @IBAction func FastForwardTapped(_ sender: UIButton) {
        audioPlayer.skipToNextItem()
    }
    /**
    * Method name: BackwardTapped
    * Description: listener for backwards button
    * Parameters: button that is mapped to this func
    */
    @IBAction func BackwardTapped(_ sender: Any) {
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
            startButton.setResumeIcon()
            NotificationCenter.default.post(name: HomeScreen.TimerNotification, object: nil, userInfo:["play": false])
            
        }else{
            playPlayer()
            startButton.setPauseIcon()
            NotificationCenter.default.post(name: HomeScreen.TimerNotification, object: nil, userInfo:["play": true])
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
        audioPlayer.endGeneratingPlaybackNotifications()
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
}
