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
    
    @IBOutlet weak var mainVerticalStackView: UIStackView!
    @IBOutlet weak var durationVal: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        durationVal.text = duration
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
