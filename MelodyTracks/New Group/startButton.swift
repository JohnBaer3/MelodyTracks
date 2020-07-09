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
        self.layer.cornerRadius = 6
        self.layer.borderWidth = 2
        self.setStartIcon()
    }
    /**
     * Method name: setResume
     * Description: sets the start button to resume button
     * Parameters: N/A
    */
    func setResumeIcon(){
        self.setTitle("Resume", for: [])
        self.layer.borderColor = #colorLiteral(red: 0.2913584709, green: 0.8262634277, blue: 0.3789584339, alpha: 1)
        self.layer.backgroundColor = #colorLiteral(red: 0.2913584709, green: 0.8262634277, blue: 0.3789584339, alpha: 1)
    }
    /**
    * Method name: setPause
    * Description: sets the start button to pause button
    * Parameters: N/A
    */
    func setPauseIcon(){
        self.setTitle("Pause", for: [])
        self.layer.backgroundColor = #colorLiteral(red: 0.9687728286, green: 0.5706424713, blue: 0.1171230599, alpha: 1)
        self.layer.borderColor = #colorLiteral(red: 0.9687728286, green: 0.5706424713, blue: 0.1171230599, alpha: 1)
    }
    /**
    * Method name: setStart
    * Description: sets the start button to start button
    * Parameters: N/A
    */
    func setStartIcon(){
        self.setTitle("Start", for: [])
        self.layer.backgroundColor = #colorLiteral(red: 0.2913584709, green: 0.8262634277, blue: 0.3789584339, alpha: 1)
        self.layer.borderColor = #colorLiteral(red: 0.2913584709, green: 0.8262634277, blue: 0.3789584339, alpha: 1)
    }
}
