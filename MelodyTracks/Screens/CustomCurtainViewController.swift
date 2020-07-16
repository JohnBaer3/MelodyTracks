//
//  CustomCurtainViewController.swift
//  MelodyTracks
//
//  Created by Daniel Loi on 7/6/20.
//

import UIKit
import MediaPlayer
import AVFoundation
import AVKit



class CustomCurtainViewController: UIViewController, MPMediaPickerControllerDelegate{
    
    var audioPlayer = MPMusicPlayerController.systemMusicPlayer
    var PlayPauseBool = true
    // set notification name
    static let selectionViewNotification = Notification.Name("selectionViewNotification")
    static let homeScreenFinishNotification = Notification.Name("homeScreenFinishNotification")
    static let showMPHNotification = Notification.Name("showMPHNotification")

    @IBOutlet weak var song: UILabel!
    @IBOutlet weak var artist: UILabel!
    @IBOutlet weak var albumCover: UIImageView!
    @IBOutlet weak var pausePlayButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var finishButton: finishButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        //set corner of bottom controller
        albumCover.layer.cornerRadius = 10
        finishButton.setInitialDetails()

        
        //setting up audio player
        audioPlayer.beginGeneratingPlaybackNotifications()
        playPlayer()
        
        
        
        //add observer for song change
        NotificationCenter.default.addObserver(self, selector: #selector(systemSongDidChange(_:)), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: audioPlayer)
        //add observer for adding songs from Selection view
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: CustomCurtainViewController.selectionViewNotification, object: nil)
        //add observer for adding songs from homeScreen view
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: CustomCurtainViewController.homeScreenFinishNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: CustomCurtainViewController.showMPHNotification, object: nil)
    }
    /**
     * Method name: onNotification
     * Description: used to receive song data from various views
     * Parameters: notification object
     */
    @objc func onNotification(notification:Notification)
    {
        //Play song after clicked Start in selection view
        /*if notification.name.rawValue == "selectionViewNotification"{
            print("data from Selection view receieved")
            audioPlayer = notification.userInfo?["player"] as! MPMusicPlayerController as! MPMusicPlayerController & MPSystemMusicPlayerController
            //send data to selection View to start timer
            NotificationCenter.default.post(name: SelectionViewController.TimerNotification, object: nil, userInfo:["play": true])
            playPlayer()
            var MPH_string = (notification.userInfo?["MPH"]) as? String
            //show curtain view
        //show Music if it has been minimized
        }else if notification.name.rawValue == "showMPHNotification"{
            print("SHOW NOTIF WORKING")
        }*/
    }
    /**
    * Method name: FinishTapped
    * Description: Listener for the Stop Button
    * Parameters: button mapped to this function
    */
    @IBAction func finishTapped(_ sender: Any) {
        print("finished")
        //pause song when leaving this screen
        audioPlayer.pause()
        NotificationCenter.default.post(name: FinishViewController.finishScreenDataNotification, object: nil, userInfo:["play": false])
        NotificationCenter.default.post(name: MapViewController.finishNotification, object: nil, userInfo:["play": false])
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
        if pausePlayButton.currentImage == UIImage(systemName: "pause.fill"){
            pausePlayer()
            NotificationCenter.default.post(name: MapViewController.startNotification, object: nil, userInfo:["play": false])
        }else{
            playPlayer()
            NotificationCenter.default.post(name: MapViewController.startNotification, object: nil, userInfo:["play": true])
        }
    }
    /**
     * Method name: pausePlayer
     * Description: pauses or plays player
     * Parameters: N/A
     */
    func pausePlayer(){
        pausePlayButton.setImage(UIImage(systemName: "play.fill"), for:[])
        audioPlayer.pause()
    }
    /**
     * Method name: playPlayer
     * Description: plays player
     * Parameters: N/A
     */
    func playPlayer(){
        pausePlayButton.setImage(UIImage(systemName: "pause.fill"), for:[])
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
        NotificationCenter.default.removeObserver(self, name: CustomCurtainViewController.showMPHNotification, object: nil)
        audioPlayer.endGeneratingPlaybackNotifications()
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
}
