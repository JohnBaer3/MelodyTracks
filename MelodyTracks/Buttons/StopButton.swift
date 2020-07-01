//
//  StopButton.swift
//  MelodyTracks
//
//  Created by Daniel Loi on 6/30/20.
//  Copyright © 2020 Daniel Loi. All rights reserved.
//

import UIKit

class StopButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    func setupButton() {
        layer.cornerRadius = 20
    }
    
}
