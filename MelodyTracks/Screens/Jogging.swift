//
//  Jogging.swift
//  MelodyTracks
//
//  Created by Daniel Loi on 6/28/20.
//  Copyright © 2020 Daniel Loi. All rights reserved.
//

import UIKit

protocol JoggingDelegate: AnyObject{
    func didFinishTask(color: UIColor, value: String)
}

class Jogging: UIViewController{
    var JoggingDelegate: JoggingDelegate!
    
    @IBAction func PauseTapped(_ sender: UIButton) {
        print("puasing run")
        JoggingDelegate?.didFinishTask(color: UIColor.systemOrange, value: "Resume")
        dismiss(animated:true, completion: nil)
        
    }
    
}
