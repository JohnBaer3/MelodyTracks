//
//  SelectionViewController.swift
//  MelodyTracks
//
//  Created by Daniel Loi on 7/6/20.
//  Copyright © 2020 Daniel Loi. All rights reserved.
//

import UIKit
import MediaPlayer

class SelectionViewController: UIViewController, MPMediaPickerControllerDelegate {
    @IBOutlet weak var BPM: UILabel!
    @IBOutlet weak var literalBPM: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var save: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    var audioPlayer = MPMusicPlayerController.systemMusicPlayer
    var hideFinishButton: Bool!
    var fixedOrAuto: Bool!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.layer.cornerRadius = 10
        //set the BPM to a saved value
        if UserDefaults.standard.object(forKey: "Pace") != nil{
            BPM.text = UserDefaults.standard.object(forKey: "Pace") as? String
        }else{
            BPM.text = String(60)
        }
        slider.value = Float(Int(BPM.text!)!)
        
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
     * Method name: fixedAutoSelector
     * Description: lets user choose between fixed BPM or automatic BPM
     * Parameters: the UI element mapped to this function
     */
    @IBAction func fixedAutoSelector(_ sender: UISegmentedControl) {
        if (sender.selectedSegmentIndex == 0){
            print("fixed")
            BPM.isEnabled = true
            slider.isEnabled = true
            literalBPM.isEnabled = true
            fixedOrAuto = true
        }else if(sender.selectedSegmentIndex == 1){
            print("auto")
            BPM.isEnabled = false
            slider.isEnabled = false
            literalBPM.isEnabled = false
            fixedOrAuto = false
        }
    }
    /**
    * Method name: saveButtonTapped
    * Description: Once tapped, this button dismisses the view and returns the previous screen. It also sends data to the previous screen.
    * Parameters: the UI element mapped to this function
    */
    @IBAction func saveButtonTapped(_ sender: Any) {
        if saveButton.title(for: .normal) == "Select Song"{
            let picker = MPMediaPickerController(mediaTypes:MPMediaType.anyAudio)
            picker.allowsPickingMultipleItems = true
            picker.showsCloudItems = true
            picker.delegate = self
            saveButton.setTitle("Save", for: [])
            self.present(picker, animated:false, completion:nil)
        }else{  //send data to Curtain View because Save has been tapped
            NotificationCenter.default.post(name: CustomCurtainViewController.selectionViewNotification, object: nil, userInfo:["player": audioPlayer, "fixedOrAuto": fixedOrAuto ?? true, "BPM": BPM.text!])
            NotificationCenter.default.post(name: HomeScreen.showFinishNotification, object: nil, userInfo:["hideFinishButton": false])
            dismiss(animated: true, completion: nil)
        }
    }
    /**
     * Method name: PickSongTapped
     * Description: func to present pick song screen
     * Parameters: button that is mapped to this func
     */
    func mediaPicker(_ mediaPicker: MPMediaPickerController,
        didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        print(mediaItemCollection.count)
        for item in mediaItemCollection.items {
            if let itemName = item.value(forProperty: MPMediaItemPropertyTitle)
                as? String {
                print("Picked item: \(itemName)")
            }
        }
        audioPlayer.setQueue(with: mediaItemCollection)
        self.dismiss(animated: false, completion:nil)
    }
    /**
     * Method name: mediaPickerDidCancel
     * Description: Called when cancel was clicked in Media Picker view
     * Parameters: MPMediaPickerController
     */
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        self.dismiss(animated: false, completion:nil)
    }
    
}

