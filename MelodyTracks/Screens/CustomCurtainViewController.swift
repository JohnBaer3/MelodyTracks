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
    
    var audioPlayer: AVAudioPlayerNode?
    var SongsArr: [Song]?
    var currentSong: Song? = nil
    var currentSongIndex: Int? = nil
    var previousSongs: [Song] = []
    
    
    var paused = true
    //var audioPlayer = MPMusicPlayerController.systemMusicPlayer
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
    
    let engine = AVAudioEngine()
    let speedControl = AVAudioUnitVarispeed()
    let pitchControl = AVAudioUnitTimePitch()

    let engineBPM = AVAudioEngine()
    let speedControlBPM = AVAudioUnitVarispeed()
    let pitchControlBPM = AVAudioUnitTimePitch()
    
    var speedOfBPM:Float = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        //set corner of bottom controller
        albumCover.layer.cornerRadius = 10
        finishButton.setInitialDetails()

        //print(SongsArr)
        //setting up audio player
        //audioPlayer.beginGeneratingPlaybackNotifications()
        playPauseClickedHelper()
        
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
        //DO NOT REMOVE THIS CHECK. REMOVAL WILL RESULT IN CRASHES WHEN ATTEMPTING TO START PLAYER AGAIN FROM SELECTION VIEW.
        if audioPlayer!.isPlaying{
            playPauseClickedHelper()
        }
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
    /*@IBAction func fastForwardTapped(_ sender: UIButton) {
        audioPlayer.skipToNextItem()
    }*/
    @IBAction func nextClicked(_ sender: Any) {
        previousSongs.append(currentSong!)
        //No more songs!
        if currentSongIndex == SongsArr!.count-1{
            for i in 0...SongsArr!.count-1{
                SongsArr![i].played = false
            }
            currentSong = SongsArr![0]
            currentSongIndex = 0
        }else{
            currentSongIndex! += 1
            currentSong = SongsArr![currentSongIndex!]
            let filePathSong = Bundle.main.path(forResource: removeSuffix(songName: currentSong!.title), ofType: "mp3", inDirectory: "Songs")
            let songUrl = URL(string: filePathSong!)
//                let BPMOfSong = BPMAnalyzer.core.getBpmFrom(songUrl!, completion: nil)
            do { try play(songUrl!)
            }catch{}
        }
    }
    /**
    * Method name: backwardTapped
    * Description: listener for backwards button
    * Parameters: button that is mapped to this func
    */
    /*@IBAction func backwardTapped(_ sender: Any) {
        audioPlayer.skipToPreviousItem()
    }*/
    @IBAction func prevClicked(_ sender: Any) {
        if previousSongs.count == 0{
            currentSongIndex! = 0
            currentSong = SongsArr![currentSongIndex!]
        }else{
            currentSongIndex! -= 1
            currentSong = previousSongs.popLast()
        }
        let filePathSong = Bundle.main.path(forResource: removeSuffix(songName: currentSong!.title), ofType: "mp3", inDirectory: "Songs")
        let songUrl = URL(string: filePathSong!)
//                let BPMOfSong = BPMAnalyzer.core.getBpmFrom(songUrl!, completion: nil)
        do { try play(songUrl!)
        }catch{}
    }
    /**
    * Method name: playPauseButtonTapped
    * Description: listener for play/pause button
    * Parameters: button that is mapped to this func
    */
    /*@IBAction func playPauseButtonTapped(_ sender: UIButton) {
        if pausePlayButton.currentImage == UIImage(systemName: "pause.fill"){
            pausePlayer()
            NotificationCenter.default.post(name: MapViewController.startNotification, object: nil, userInfo:["play": false])
        }else{
            playPlayer()
            NotificationCenter.default.post(name: MapViewController.startNotification, object: nil, userInfo:["play": true])
        }
    }*/
    /**
     * Method name:playPauseClicked
     * Description: plays and pauses player
     * Parameters: a button
     */
    @IBAction func playPauseClicked(_ sender: Any) {
        playPauseClickedHelper()
    }
    /**
     * Method name: playPauseClickedHelper
     * Description: helper function so that playPauseClicked can be called without pressing a button
     * Parameters: N/A
     */
    func playPauseClickedHelper(){
        paused = !paused
                
        if !paused{
            if currentSong == nil{
                //find a song to play, currently just the first song in the BPMArr
                print(SongsArr ?? [])
                currentSong = SongsArr![0]
                
                currentSongIndex = 0
                SongsArr![0].played = true
                let filePathSong = Bundle.main.path(forResource: removeSuffix(songName: currentSong!.title), ofType: "mp3", inDirectory: "Songs")
                let songUrl = URL(string: filePathSong!)
//                let BPMOfSong = BPMAnalyzer.core.getBpmFrom(songUrl!, completion: nil)
                do {
                    try play(songUrl!)
                }catch{}
            }else{
                playPlayer()
                NotificationCenter.default.post(name: MapViewController.startNotification, object: nil, userInfo:["play": true])
            }
        }else{
            pausePlayer()
            NotificationCenter.default.post(name: MapViewController.startNotification, object: nil, userInfo:["play": false])
        }
    }
    /**
     * Method name: pausePlayer
     * Description: pauses or plays player
     * Parameters: N/A
     */
    func pausePlayer(){
        pausePlayButton.setImage(UIImage(systemName: "play.fill"), for:[])
        audioPlayer?.pause()
    }
    /**
     * Method name: playPlayer
     * Description: plays player
     * Parameters: N/A
     */
    func playPlayer(){
        pausePlayButton.setImage(UIImage(systemName: "pause.fill"), for:[])
        do {
           try AVAudioSession.sharedInstance().setCategory(.playback)
        } catch(let error) {
            print(error.localizedDescription)
        }
        audioPlayer?.play()
    }
    /**
     * Method name: play
     * Description: <#description#>
     * Parameters: URL
     */
    func play(_ url: URL) throws {
        print("runs special play")
        // 1: load the file
        let file = try AVAudioFile(forReading: url)

        // 3: connect the components to our playback engine
        engine.attach(audioPlayer ?? AVAudioPlayerNode())
        engine.attach(pitchControl)
        engine.attach(speedControl)
        
        // 4: arrange the parts so that output from one is input to another
        engine.connect(audioPlayer ?? AVAudioPlayerNode(), to: speedControl, format: nil)
        engine.connect(speedControl, to: pitchControl, format: nil)
        engine.connect(pitchControl, to: engine.mainMixerNode, format: nil)

        // 5: prepare the player to play its file from the beginning
        audioPlayer?.scheduleFile(file, at: nil)
        
        // 6: start the engine and player
        try engine.start()
        do {
           try AVAudioSession.sharedInstance().setCategory(.playback)
        } catch(let error) {
            print(error.localizedDescription)
        }
        audioPlayer?.play()
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
        //audioPlayer.endGeneratingPlaybackNotifications()
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
}
