//
//  ShuffleButton.swift
//  MelodyTracks
//
//  Created by Daniel Loi on 7/1/20.
//  Copyright © 2020 Daniel Loi. All rights reserved.
//

import UIKit

class ShuffleButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    func setupButton() {
        tintColor = UIColor(white:0, alpha:1)
        
    }
    
}
