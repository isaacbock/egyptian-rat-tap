//
//  BeginMultiplayerViewController.swift
//  CSE438S-Egyptian-Rat-Tap
//
//  Created by Isaac Bock on 11/15/20.
//  Copyright © 2020 Egyptian Rat Tap. All rights reserved.
//

import UIKit

class BeginMultiplayerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    @IBAction func userReady(_ sender: Any) {
        // TO-DO:
        // update some variable to track that current user is ready
        
        // TO_DO: update text label of user to show checkmark or some other ready indicator
        
        // TO=DO: if all users are ready {
            // start game
            performSegue(withIdentifier: "beginGame", sender: self)
        // }
    }
    
}
