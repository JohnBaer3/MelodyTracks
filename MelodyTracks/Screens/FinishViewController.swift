//
//  FinishViewController.swift
//  MelodyTracks
//
//  Created by Daniel Loi on 7/14/20.
//  Copyright © 2020 Daniel Loi. All rights reserved.
//

import UIKit

class FinishViewController: UIViewController {
    
    static let finishScreenDataNotification = Notification.Name("finishScreenDataNotification")
    
    var duration: String?
    var SongsArr: [Song]?
    var footstep: String?
    var distance: String?
    var fpm: String?
    
    @IBOutlet weak var mainVerticalStackView: UIStackView!
    @IBOutlet weak var durationVal: UILabel!
    @IBOutlet weak var finalFinishButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stepsVal: UILabel!
    @IBOutlet weak var distanceVal: UILabel!
    @IBOutlet weak var bpmVal: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print(duration)
        durationVal.text = duration
        stepsVal.text = footstep
        distanceVal.text = distance
        bpmVal.text = fpm
        finalFinishButton.layer.cornerRadius = 10
        tableView.layer.cornerRadius = 10
        tableView.delegate = self
        tableView.dataSource = self
        //add observer for data from Custom Curtain view
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: FinishViewController.finishScreenDataNotification, object: nil)
    }
    
    @objc func onNotification(notification:Notification)
    {
        //Play song after clicked Start in selection view
        if notification.name.rawValue == "finishScreenDataNotification"{
            print("data from Custom Curtain view receieved")
            //show curtain view
            //show Music if it has been minimized
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: FinishViewController.finishScreenDataNotification, object: nil)
    }
    
}
extension FinishViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return SongsArr!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let song = SongsArr![indexPath.row]
        let songCell = tableView.dequeueReusableCell(withIdentifier: "SongCell") as! SongCell
        songCell.setCell(song: song)
        return songCell
    }
}
