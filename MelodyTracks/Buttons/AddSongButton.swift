//
//  AddSongButton.swift
//  MelodyTracks
//
//  Created by Daniel Loi on 7/1/20.
//  Copyright © 2020 Daniel Loi. All rights reserved.
//

import UIKit

class AddSongButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    func setupButton() {
        //layer.borderWidth = 20
        //layer.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        //let closeImage = UIImage(named:"baseline_add_black_36pt")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        tintColor = UIColor(white:0, alpha:1)
        //setImage(closeImage, for:[])
    }
    
}
