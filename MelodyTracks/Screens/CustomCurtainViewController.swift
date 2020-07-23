//
//  CustomCurtainViewController.swift
//  MelodyTracks
//
//  Created by Daniel Loi on 7/6/20.
//  Lasted edited by John A. 7/23/20
//  Added engine deallocation after finish button
//

import UIKit
import MediaPlayer
import AVFoundation
import AVKit

class CustomCurtainViewController: UIViewController, MPMediaPickerControllerDelegate{
    
    var audioPlayer: AVAudioPlayerNode?
    var SongsArr: [Song]?
    var currentSong: Song? = nil {
        didSet{
            song.text = currentSong?.title
            artist.text = "Black Eyed Peas"
        }
    }
    var currentSongIndex: Int? = nil
    var previousSongs: [Song] = []
    
    
    var paused = true
    //var audioPlayer = MPMusicPlayerController.systemMusicPlayer
    var PlayPauseBool = true
    // set notification name

    @IBOutlet weak var song: UILabel!
    @IBOutlet weak var artist: UILabel!
    @IBOutlet weak var albumCover: UIImageView!
    @IBOutlet weak var pausePlayButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var finishButton: finishButton!
    
    @IBOutlet weak var testBPMLabel: UILabel!

    let engine = AVAudioEngine()
    let speedControl = AVAudioUnitVarispeed()
    let pitchControl = AVAudioUnitTimePitch()
    
    var timer = Timer()
    
    var smartBPM: Float = 0
    
    var speedOfBPM:Float = 0.0
    typealias SongCompletionHandler = (_ success:Bool) -> Void
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        //set corner of bottom controller
        albumCover.layer.cornerRadius = 10
        finishButton.setInitialDetails()
        
        //Starts music when view loads
        playPauseClickedHelper()
        if !manualSmart{
            var newBpm = changeSpeedToFootsteps(bpm: currentSong!.BPM, footStepFreq: convertMPHtoBPM(mph: chosenMPH))
        }else{
            smartBPM = currentSong!.BPM
        }
        scheduledTimer()
    }
    
    
    func scheduledTimer(){
        timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
    }
    @objc func updateCounting(){
        DispatchQueue.global(qos: .background).async {
            print("This is run on the background queue")
            let cadence=PedometerData.shared.getCadence()
            
            if(manualSmart){
                if cadence > 50{
                    self.smartBPM = self.changeSpeedToFootsteps(bpm: self.smartBPM, footStepFreq: cadence)
                }else{
                    self.smartBPM = self.currentSong!.BPM
                }
            }
            /*DispatchQueue.main.async {
                print("This is run on the main queue, after the previous code in outer block")
            }*/
        }
    }
    /**
    * Method name: startTimer
    * Description: starts timer
    * Parameters: current BPM of song and foot step frequency
    * Output: newBPM of song to be played at
    * Alters: playback pitch and rate to account for new bpm
    */
    /*func timerStart(){
        DispatchQueue.global(qos: .background).async {
            self.timer_test = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                
            }
            RunLoop.current.run()
        }
    }*/
    
    /**
     * Method name: changeSpeedToFootsteps
     * Description: changes speed to footsteps
     * Parameters: current BPM of song and foot step frequency
     * Output: newBPM of song to be played at
     * Alters: playback pitch and rate to account for new bpm
     */
    func changeSpeedToFootsteps(bpm: Float, footStepFreq: Float) -> Float {
        // ratio between footsteps and bpm
        let rate = footStepFreq/bpm
        
        var newBPM: Float
        var pitch: Float
        newBPM = 0
        pitch = 0
        
        // Equation for for finding pitch and rate modification values
        // uses a logarithmic equation to find new pitch
        // 1200 constant can be changed if deemed necesarry
        // this pseudo-timestretching solution does affect audio quality slightly
        
        // Increase BPM
        if (rate >= 1) {
            newBPM = bpm + (footStepFreq - bpm)
            let bpmRatio = newBPM / bpm
            pitch = 1200 * (log(bpmRatio) / log(2))
            pitchControl.pitch -= pitch
            speedControl.rate += rate - 1
        }
            
        // Decrease BPM
        else if (rate < 1) {
            newBPM = bpm - (bpm - footStepFreq)
            let bpmRatio = newBPM / bpm
            pitch = 1200 * (log(bpmRatio) / log(2))
            pitchControl.pitch -= pitch
            speedControl.rate -= 1 - rate
        }
        
        print("Initial BPM: \(bpm)\nNewBpm: \(newBPM)\nRate: \(rate)\nPitch Change: \(pitch)\n")
        return newBPM
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
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        if audioPlayer!.isPlaying{
            playPauseClickedHelper()
        }
        timer.invalidate()
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
        print("song did change")
        //audioPlayer?.scheduleBuffer(<#T##buffer: AVAudioPCMBuffer##AVAudioPCMBuffer#>, completionHandler: <#T##AVAudioNodeCompletionHandler?##AVAudioNodeCompletionHandler?##() -> Void#>)
        /*guard let playerController = notification.object as? MPMusicPlayerController else {
            return
        }
        let item = playerController.nowPlayingItem
        setSongDetails(item)*/
    }
    /**
     * Method name: setSongDetails
     * Description: set song details on the UI
     * Parameters: MPMediaItem
     */
    func setSongDetails(_ item: MPMediaItem?){
//        albumCover.image = item?.artwork?.image(at: albumCover.intrinsicContentSize)
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
        NotificationCenter.default.addObserver(self, selector: #selector(self.systemSongDidChange(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: file)


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
    
    func convertMPHtoBPM(mph: Int) -> Float{
        let milesPerMin = Float(mph)/60
        let oneMileInThisMins = 1/milesPerMin
        
        //For every extra minute to complete the mile, 10 less BPM
        let resultBPM = 250 - 10 * oneMileInThisMins
        return resultBPM
    }
    
    
    /**
     * Method name: removeSuffix
     * Description: <#description#>
     * Parameters: <#parameters#>
     */
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
    /**
    * Method name: deinit
    * Description: called when view is destroyed
    * Parameters: N/A
    */
    deinit {
        print("getting rid of view")
    }
    
    
    
}
