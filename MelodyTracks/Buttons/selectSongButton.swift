//
//  selectSongButton.swift
//  MelodyTracks
//
//  Created by Daniel Loi on 7/10/20.
//  Copyright © 2020 Daniel Loi. All rights reserved.
//

import UIKit

class selectSongButton: UIButton {
    /**
    * Method name: setInitialDetails
    * Description: sets intial shape and text of start button
    * Parameters: N/A
    */
    func setInitialDetails(){
        self.layer.cornerRadius = 10
        self.layer.backgroundColor = #colorLiteral(red: 0.2913584709, green: 0.8262634277, blue: 0.3789584339, alpha: 1)
        self.setSelectSongIcon()
    }
    /**
    * Method name: setSelectSongIcon
    * Description: sets the start button to start button
    * Parameters: N/A
    */
    func setSelectSongIcon(){
        self.setTitle("Select Songs", for: [])
    }
    /**
    * Method name: setSelectSongIcon
    * Description: sets the start button to start button
    * Parameters: N/A
    */
    func setSaveIcon(){
        self.setTitle("Start Run!", for: [])
    }
    /**
    * Method name: setBPMIcon
    * Description: sets the start button to show BPM button
    * Parameters: N/A
    */
    func setMPHIcon(){
        self.setTitle("Show MPH", for: [])
    }
}
