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
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var tableView: UITableView!
    // set notification name
    static let showFinishNotification = Notification.Name("showFinishNotification")
    static let TimerNotification = Notification.Name("TimerNotification")
    
    //stuff from AVAudioPlayer port
    //var engine : AVAudioEngine!
    let engine = AVAudioEngine()
    let speedControl = AVAudioUnitVarispeed()
    let pitchControl = AVAudioUnitTimePitch()

    let engineBPM = AVAudioEngine()
    //var engineBPM : AVAudioEngine!
    let speedControlBPM = AVAudioUnitVarispeed()
    let pitchControlBPM = AVAudioUnitTimePitch()
    
    var speedOfBPM:Float = 0.0
    //stuff from AVAudioPlayer port
    
    //var audioPlayer = MPMusicPlayerController.systemMusicPlayer
    let audioPlayer = AVAudioPlayerNode()
    //var audioPlayer : AVAudioPlayerNode!
    let picker = MPMediaPickerController(mediaTypes:MPMediaType.anyAudio)
    var trackList : MPMediaItemCollection?
    var hideFinishButton: Bool!
    var SongsArr: [Song] = []
    
    var higherBoundMPH = 15
    var lowerBoundMPH = 0
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.setInitialDetails()
        setInitialMPH()
        getBPMofSongs()
        tableView.delegate = self
        tableView.dataSource = self
        
        //check to see if there is current audio playing
        if audioPlayer.isPlaying == true {
            audioPlayer.pause()
        }
        fixedAutoSwap(tapped: fixedButton, other: autoButton)
        walkButton.layer.cornerRadius = 10
        jogButton.layer.cornerRadius = 10
        runButton.layer.cornerRadius = 10

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
            let title =  removeSuffix(songName: song)
            let filePathSong = Bundle.main.path(forResource: title, ofType: "mp3", inDirectory: "Songs")
            let songUrl = URL(string: filePathSong!)
            let BPMOfSong = BPMAnalyzer.core.getBpmFrom(songUrl!, completion: nil)
            //Have to parse BPMOfSong to actually get the BPM, then convert it to Float
            
            let newSong = Song(title: title, BPM: convertBPMToFloat(BPMOfSong))
            SongsArr.append(newSong)
        }
    }
    /**
     * Method name: convertBPMToFloat
     * Description: converts BPM to Float
     * Parameters: BPM of the song in its string format
     * Output: BPM extract from the string in float
     */

    func convertBPMToFloat(_ bpmString: String) -> Float {
        // Really dirty way to parse the string return form BPMAnalyzer
        // Definitely a better way to do this
        let bpmSplitArray = bpmString.components(separatedBy: " ")
        let splitBPMSpaces = bpmSplitArray[2]
        let splitBPMComma = splitBPMSpaces.components(separatedBy: ",")
        let toBeConvertedFromString = splitBPMComma[0]
        let bpmFloat = Float(toBeConvertedFromString)
        
        return bpmFloat!
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
            MPH.text = String(0)
        }
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
            
            //code to show Map View
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController

            vc.audioPlayer = audioPlayer
            vc.SongsArr = SongsArr

            vc.modalPresentationStyle = .currentContext
            present(vc, animated: true, completion:nil)
        }
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
    
    deinit{
        //stop listening to notifications
        NotificationCenter.default.removeObserver(self, name: SelectionViewController.TimerNotification, object: nil)
    }
}

extension SelectionViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return SongsArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let song = SongsArr[indexPath.row]
        let songCell = tableView.dequeueReusableCell(withIdentifier: "SongCell") as! SongCell
        songCell.setCell(song: song)
        return songCell
    }
}
