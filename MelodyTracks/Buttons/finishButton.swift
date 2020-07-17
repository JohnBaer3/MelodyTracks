//
//  finishButton.swift
//  MelodyTracks
//
//  Created by Daniel Loi on 7/8/20.
//  Copyright © 2020 Daniel Loi. All rights reserved.
//

import UIKit

class finishButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    /**
     * Method name: setInitialDetails
     * Description: sets intial shape and text of finish button
     * Parameters: N/A
     */
    func setInitialDetails(){
        self.layer.cornerRadius = 10
        self.frame.size = CGSize(width: 374, height: 44)
        self.setFinish()
    }
    /**
    * Method name: setFinish
    * Description: sets the finish button to finish button
    * Parameters: N/A
    */
    func setFinish(){
        self.setTitle("Finish", for: [])
        
        //self.layer.backgroundColor = #colorLiteral(red: 0.7615019679, green: 0.1136659905, blue: 0.1256904304, alpha: 1)
        self.layer.backgroundColor = UIColor.systemRed.cgColor
    }

}
