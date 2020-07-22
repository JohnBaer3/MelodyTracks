//
//  selectorButton.swift
//  MelodyTracks
//
//  Created by Daniel Loi on 7/15/20.
//  Copyright © 2020 Daniel Loi. All rights reserved.
//

import UIKit

class selectorButton: UIButton {
    
    func isSelected(){
        self.tintColor = UIColor.white
    }
    func isUnselected(){
        self.tintColor = UIColor.gray
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
