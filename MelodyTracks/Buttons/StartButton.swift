//
//  startButton.swift
//  MelodyTracks
//
//  Created by Daniel Loi on 7/8/20.
//  Copyright © 2020 Daniel Loi. All rights reserved.
//

import UIKit

class startButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    /**
     * Method name: setInitialDetails
     * Description: sets intial shape and text of start button
     * Parameters: N/A
     */
    func setInitialDetails(){
        self.layer.cornerRadius = 10
        self.setStartIcon()
    }
    /**
     * Method name: setResume
     * Description: sets the start button to resume button
     * Parameters: N/A
    */
    func setResumeIcon(){
        self.setTitle("Resume", for: [])
        setGreen()
    }
    /**
    * Method name: setPause
    * Description: sets the start button to pause button
    * Parameters: N/A
    */
    func setPauseIcon(){
        self.setTitle("Pause", for: [])
        self.layer.backgroundColor = UIColor.systemOrange.cgColor
    }
    /**
    * Method name: setStart
    * Description: sets the start button to start button
    * Parameters: N/A
    */
    func setStartIcon(){
        self.setTitle("Start", for: [])
        setGreen()
    }
    /**
    * Method name: setBPMIcon
    * Description: sets the start button to show BPM button
    * Parameters: N/A
    */
    func setBPMIcon(){
        self.setTitle("Show BPM", for: [])
        setGreen()
    }
    /**
    * Method name: setGreen
    * Description: sets the start button's color to green
    * Parameters: N/A
    */
    private func setGreen(){
        self.layer.backgroundColor = #colorLiteral(red: 0.2913584709, green: 0.8262634277, blue: 0.3789584339, alpha: 1)
    }
}
