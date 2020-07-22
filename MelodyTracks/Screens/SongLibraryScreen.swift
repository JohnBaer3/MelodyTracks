//
//  SongLibraryScreen.swift
//  MelodyTracks
//
//  Created by John Baer on 7/20/20.
//  Copyright © 2020 Daniel Loi. All rights reserved.
//


import UIKit

class SongLibraryScreen: UIViewController{
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
}



extension SongLibraryScreen: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return SongsArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let song = SongsArr[indexPath.row]
        let songCell = tableView.dequeueReusableCell(withIdentifier: "SongCell") as! SongCell
        songCell.setCell(song: song)
        
        return songCell
    }
}
