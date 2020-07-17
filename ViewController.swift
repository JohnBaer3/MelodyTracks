
//
//  ViewController.swift
//  BPMAnalyser
//
//  Created by Gleb Karpushkin on 29/03/2017.
//  Copyright © 2017 Gleb Karpushkin. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer
import Foundation

class ViewController: UIViewController {
    
    let mediaPicker: MPMediaPickerController = MPMediaPickerController(mediaTypes: .music)
    
    let engine = AVAudioEngine()
    let speedControl = AVAudioUnitVarispeed()
    let pitchControl = AVAudioUnitTimePitch()

    let engineBPM = AVAudioEngine()
    let speedControlBPM = AVAudioUnitVarispeed()
    let pitchControlBPM = AVAudioUnitTimePitch()
    
    lazy var bpmLabel: UILabel = {
        let label = UILabel()
        label.frame.size.height = 300
        label.frame.size.width = UIScreen.main.bounds.width - 32
        label.numberOfLines = 2
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mediaPicker.allowsPickingMultipleItems = false
        mediaPicker.delegate = self
        present(mediaPicker, animated: true, completion: nil)
        
        let filePath = Bundle.main.path(forResource: "BillieJean", ofType: "mp3")
        let url = URL(string: filePath!)
        
        let bpmUnparsed = BPMAnalyzer.core.getBpmFrom(url!, completion: nil)
        
        var bpm = convertBPMToFloat(bpmUnparsed)
        
        
        // TODO: Add in function to get current footstep data
        // Using example footstep rate of 120
        var footStepFreq = Float(120)
    
        bpm = changeSpeedToFootsteps(bpm: bpm, footStepFreq: footStepFreq)
        
        let songUrl = Bundle.main.url(forResource: "BillieJean", withExtension: ".mp3")
        do{
            try playSong(songUrl!)}
        catch{}
        
        
//        var runInProgress: Bool
//        while(runInProgress) {
//            // request footstep data
//            bpm = changeSpeedToFootsteps(bpm: bpm, footStepFreq: footStepFreq)
//            sleep(1)
//        }
        
        for _ in 0...10 {
            sleep(2)
            footStepFreq += 5
            bpm = changeSpeedToFootsteps(bpm: bpm, footStepFreq: footStepFreq)
        }
        
        for _ in 0...10 {
            sleep(2)
            footStepFreq -= 5
            bpm = changeSpeedToFootsteps(bpm: bpm, footStepFreq: footStepFreq)
        }

        // TODO: get metronome working and synced up
//        let metronomeUrl = Bundle.main.url(forResource: "100BPM", withExtension: ".mp3")
//        do{
//            try playMetronome(metronomeUrl!)}
//        catch{}
        
    }
}

extension ViewController: MPMediaPickerControllerDelegate {

    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems
        mediaItemCollection: MPMediaItemCollection) {
        guard let asset = mediaItemCollection.items.first,
            let url = asset.assetURL else {return}
        _ = BPMAnalyzer.core.getBpmFrom(url, completion: {[weak self] (bpm) in
            self?.addLabelWith(bpm)
            self?.mediaPicker.dismiss(animated: true, completion: nil)
        })
    }
    
    // TODO: Remove this
    func addLabelWith(_ bpmString: String) {
        let bpm = convertBPMToFloat(bpmString)
        print(bpm)
        
        
        bpmLabel.text = String(describing:bpm)
        view.addSubview(bpmLabel)
        bpmLabel.center = view.center
        view.layoutIfNeeded()
    }
    
    // Input: the bpm of the song in its string format
    // Output: the bpm extract from the string in float
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
    
    
    // Input: current bpm of song and foot step frequency
    // Output: newBPM of song to be played at
    // Alters: playback pitch and rate to account for new bpm
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
        if (rate > 1) {
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
    
    // Input: URL of file to be played
    // Action: plays song at path
    func playSong(_ url: URL) throws {
        // 1: load the file
        let file = try AVAudioFile(forReading: url)

        // 2: create the audio player
        let audioPlayer = AVAudioPlayerNode()

        // 3: connect the components to our playback engine
        engine.attach(audioPlayer)
        engine.attach(pitchControl)
        engine.attach(speedControl)

        // 4: arrange the parts so that output from one is input to another
        engine.connect(audioPlayer, to: speedControl, format: nil)
        engine.connect(speedControl, to: pitchControl, format: nil)
        engine.connect(pitchControl, to: engine.mainMixerNode, format: nil)

        // 5: prepare the player to play its file from the beginning
        audioPlayer.scheduleFile(file, at: nil)

        // 6: start the engine and player
        try engine.start()
        audioPlayer.play()
    }
    
    func playMetronome(_ url: URL) throws {
        // 1: load the file
        let file = try AVAudioFile(forReading: url)

        // 2: create the audio player
        let audioPlayer = AVAudioPlayerNode()

        // 3: connect the components to our playback engine
        engineBPM.attach(audioPlayer)
        engineBPM.attach(pitchControlBPM)
        engineBPM.attach(speedControlBPM)
        
        // 4: arrange the parts so that output from one is input to another
        engineBPM.connect(audioPlayer, to: speedControlBPM, format: nil)
        engineBPM.connect(speedControlBPM, to: pitchControlBPM, format: nil)
        engineBPM.connect(pitchControlBPM, to: engineBPM.mainMixerNode, format: nil)

        // 5: prepare the player to play its file from the beginning
        audioPlayer.scheduleFile(file, at: nil)
        
        // 6: start the engine and player
        try engineBPM.start()
        audioPlayer.play()
    }
}
