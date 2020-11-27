//
//  CreateGameViewController.swift
//  CSE438S-Egyptian-Rat-Tap
//
//  Created by Isaac Bock on 11/15/20.
//  Copyright © 2020 Egyptian Rat Tap. All rights reserved.
//

import UIKit

class CreateGameViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var playerName: UITextField!
    @IBOutlet weak var gameCode: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.playerName.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

}
