//
//  PlayPauseButton.swift
//  MelodyTracks
//
//  Created by Daniel Loi on 7/1/20.
//  Copyright © 2020 Daniel Loi. All rights reserved.
//

import UIKit

class PlayPauseButton: UIButton {
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
        //layer.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        //let closeImage = UIImage(named:"baseline_play_circle_filled_black_48pt.imageset")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        tintColor = UIColor(white:0, alpha:1)
        //setImage(closeImage, for:[])
    }
    
}
