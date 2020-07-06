//
//  Jogging.swift
//  MelodyTracks
//
//  Created by Daniel Loi on 6/28/20.
//  Copyright © 2020 Daniel Loi. All rights reserved.
//

import UIKit
import MediaPlayer
import aubio


protocol JoggingDelegate: AnyObject{
    func didFinishTask(color: UIColor, value: String)
}

class Jogging: UIViewController, MPMediaPickerControllerDelegate{
    var JoggingDelegate: JoggingDelegate!
    let audioPlayer = MPMusicPlayerController.systemMusicPlayer
    var PlayPauseBool = true
    @IBOutlet weak var AlbumCover: UIImageView!
    @IBOutlet weak var PlayPauseButton: UIButton!
    @IBOutlet weak var JoggingBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioPlayer.beginGeneratingPlaybackNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(systemSongDidChange(_:)), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: self.audioPlayer)
    }
    
    @objc func systemSongDidChange(_ notification: Notification) {
        guard let playerController = notification.object as? MPMusicPlayerController else {
            return
        }
        let item = playerController.nowPlayingItem
        AlbumCover.image = item?.artwork?.image(at: AlbumCover.intrinsicContentSize)
        print(item?.title! as Any)
    }
    
    deinit {
        print("getting rid of view")
        JoggingDelegate?.didFinishTask(color: UIColor.systemOrange, value: "Resume")
        audioPlayer.endGeneratingPlaybackNotifications()
        NotificationCenter.default.removeObserver(self)
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
    
    @IBAction func FastForwardTapped(_ sender: UIButton) {
        audioPlayer.skipToNextItem()
    }
    
    @IBAction func BackwardTapped(_ sender: Any) {
        audioPlayer.skipToPreviousItem()
    }
    
    @IBAction func shuffleTapped(_ sender: Any) {
    }
    
    @IBAction func loopTapped(_ sender: Any) {
    }
    
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController,
        didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        for item in mediaItemCollection.items {
            if let itemName = item.value(forProperty: MPMediaItemPropertyTitle)
                as? String {
                print("Picked item: \(itemName)")
            }
        }
        audioPlayer.setQueue(with: mediaItemCollection)
        let currentSong: MPMediaItem = mediaItemCollection.items[0]
        let url = currentSong.assetURL
        /*if (path != nil) {
            let hop_size : uint_t = 512
            let a = new_fvec(hop_size)
            let b = new_aubio_source(path, 0, hop_size)
            var read: uint_t = 0
            var total_frames : uint_t = 0
            while (true) {
                aubio_source_do(b, a, &read)
                total_frames += read
                if (read < hop_size) { break }
            }
            print("read", total_frames, "frames at", aubio_source_get_samplerate(b), "Hz")
            del_aubio_source(b)
            del_fvec(a)
        } else {
            print("could not find file")
        }*/
        print(currentSong.albumTitle!)
        audioPlayer.play()
        self.dismiss(animated: false, completion:nil)
    }

    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        self.dismiss(animated: false, completion:nil)
    }
    
}

