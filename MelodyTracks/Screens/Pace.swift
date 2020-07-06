//
//  Pace.swift
//  MelodyTracks
//
//  Created by Daniel Loi on 6/29/20.
//  Copyright © 2020 Daniel Loi. All rights reserved.
//

import UIKit

protocol SetPaceDelegate: AnyObject{
    func didFinishTask(bpm: String)
}

class Pace: UIViewController{
    @IBOutlet var Label: UILabel!
    @IBOutlet weak var Slider: UISlider!
    
    var bpm: String!
    var selectionDelegate: SetPaceDelegate!
    
    

    @IBAction func SavePace(_ sender: UIButton) {
        print("exiting pace set")
        selectionDelegate?.didFinishTask(bpm: Label.text!)
        dismiss(animated:true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print(UserDefaults.standard.object(forKey: "Pace") != nil)
        if UserDefaults.standard.object(forKey: "Pace") != nil{
            Label.text = UserDefaults.standard.object(forKey: "Pace") as? String
        }else{
            Label.text = String(0)
        }
        Slider.value = Float(Int(Label.text!)!)
    }
    
}
