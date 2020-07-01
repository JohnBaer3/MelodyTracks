//
//  Jogging.swift
//  MelodyTracks
//
//  Created by Daniel Loi on 6/28/20.
//  Copyright © 2020 Daniel Loi. All rights reserved.
//

import UIKit
import MediaPlayer

protocol JoggingDelegate: AnyObject{
    func didFinishTask(color: UIColor, value: String)
}

class Jogging: UIViewController, MPMediaPickerControllerDelegate{
    var JoggingDelegate: JoggingDelegate!
    let audioPlayer = MPMusicPlayerController.systemMusicPlayer
    var timer = Timer()
    @IBOutlet weak var PlayPauseButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func PauseTapped(_ sender: UIButton) {
        JoggingDelegate?.didFinishTask(color: UIColor.systemOrange, value: "Resume")
        dismiss(animated:true, completion: nil)
    }
    
    @IBAction func PickSongTapped(_ sender: Any) {
        let picker = MPMediaPickerController(mediaTypes:MPMediaType.anyAudio)

        picker.allowsPickingMultipleItems = true
        picker.showsCloudItems = true

        picker.delegate = self

        self.present(picker, animated:false, completion:nil)
    }
    @IBAction func PlayButton(_ sender: UIButton) {
        if audioPlayer.playbackState == MPMusicPlaybackState.playing{
            audioPlayer.pause()
        }else{
            audioPlayer.play()
        }
    }
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController,
        didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        for item in mediaItemCollection.items {
            if let itemName = item.value(forProperty: MPMediaItemPropertyTitle)
                as? String {
                print("Picked item: \(itemName)")
            }
        }
        let musicPlayer = MPMusicPlayerController.systemMusicPlayer
        musicPlayer.setQueue(with: mediaItemCollection)
        self.dismiss(animated: false, completion:nil)
    }

    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        self.dismiss(animated: false, completion:nil)
    }
}

