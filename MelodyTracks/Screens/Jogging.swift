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
    var PlayPauseBool = true
    @IBOutlet weak var AlbumCover: UIImageView!
    @IBOutlet weak var PlayPauseButton: UIButton!
    @IBOutlet weak var JoggingBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*JoggingBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        JoggingBar.shadowImage = UIImage()
        JoggingBar.isTranslucent = true
        JoggingBar.backgroundColor = UIColor.clear*/
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
        print(currentSong.albumTitle!)
        audioPlayer.play()
        self.dismiss(animated: false, completion:nil)
    }

    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        self.dismiss(animated: false, completion:nil)
    }
    
}

