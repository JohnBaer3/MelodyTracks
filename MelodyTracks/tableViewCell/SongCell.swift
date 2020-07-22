//
//  SongCell.swift
//  BPMAnalyser
//
//  Created by John Baer on 7/15/20.
//  Copyright © 2020 Gleb Karpushkin. All rights reserved.
//

import UIKit

class SongCell: UITableViewCell {
    
    @IBOutlet weak var songCellTitle: UILabel!
    @IBOutlet weak var songCellArtist: UILabel!
    @IBOutlet weak var songCellBPM: UILabel!
    
    func setCell(song: Song){
        self.songCellTitle.text = song.title
        self.songCellArtist.text = "The Black Eyed Peas"
//        self.songCellBPM.text = String(song.BPM)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
