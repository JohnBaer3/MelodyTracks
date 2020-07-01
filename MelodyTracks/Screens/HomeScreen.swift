//
//  HomeScreen.swift
//  MelodyTracks
//
//  Created by Daniel Loi on 6/28/20.
//  Copyright © 2020 Daniel Loi. All rights reserved.
//

import UIKit

class HomeScreen: UIViewController{
    var bpm:String = ""
    
    @IBOutlet weak var BPM: UILabel!
    @IBOutlet weak var Start: StartButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if UserDefaults.standard.object(forKey: "Pace") != nil{
            BPM.text = UserDefaults.standard.object(forKey: "Pace") as? String
        }else{
            BPM.text = String(0)
        }
        print(BPM.text!)
        
    }
    @IBAction func unwindToHome(_ sender: UIStoryboardSegue){
        if sender.source is Pace{
            if let senderVC = sender.source as? Pace{
                print(sender.source)
                BPM.text = senderVC.bpm
            }
        }
    }
    @IBAction func StartJogTapped(_ sender: UIButton) {
        let selectionVC = storyboard?.instantiateViewController(withIdentifier: "Jogging") as! Jogging
        selectionVC.JoggingDelegate = self
        selectionVC.modalPresentationStyle = .fullScreen
        present(selectionVC, animated:true, completion: nil)
    }
    @IBAction func SetPaceTapped(_ sender: UIButton) {
        //print("at least we're here")
        let selectionVC = storyboard?.instantiateViewController(withIdentifier: "Pace") as! Pace
        selectionVC.selectionDelegate = self
        selectionVC.modalPresentationStyle = .popover
        present(selectionVC, animated:true, completion: nil)
    }
    @IBAction func StopTapped(_ sender: UIButton) {
        Start.backgroundColor =  UIColor.systemGreen
        Start.setTitle("Start", for: [])
    }
    
}


extension HomeScreen: SetPaceDelegate{
    func didFinishTask(bpm: String) {
        print(bpm)
        BPM.text = bpm
    }
}
extension HomeScreen: JoggingDelegate{
    func didFinishTask(color: UIColor, value: String) {
        Start.backgroundColor = color
        Start.setTitle(value, for: [])
        
    }
}
