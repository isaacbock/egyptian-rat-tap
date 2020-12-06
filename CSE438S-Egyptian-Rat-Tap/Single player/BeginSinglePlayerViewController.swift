//
//  JoinSinglePlayerViewController.swift
//  CSE438S-Egyptian-Rat-Tap
//
//  Created by Isaac Bock on 11/15/20.
//  Copyright © 2020 Egyptian Rat Tap. All rights reserved.
//

import UIKit

class BeginSinglePlayerViewController: UIViewController {
    
    @IBOutlet weak var easyButton: UIButton!
    @IBOutlet weak var mediumButton: UIButton!
    @IBOutlet weak var hardButton: UIButton!
    
    var comDifficulty: Double = 3

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? PlayViewController
        vc?.comSlapTime = comDifficulty
    }
    
    @IBAction func setEasy(_ sender: Any) {
        setDifficulty(time: 4)
    }
    @IBAction func setMedium(_ sender: Any) {
        setDifficulty(time: 3)
    }
    @IBAction func setHard(_ sender: Any) {
        setDifficulty(time: 2)
    }
    
    func setDifficulty(time: Double) {
        if (comDifficulty != time) {
            comDifficulty = time
            if (time == 4) {
                easyButton.isSelected = true
                mediumButton.isSelected = false
                hardButton.isSelected = false
            }
            if (time == 3) {
                easyButton.isSelected = false
                mediumButton.isSelected = true
                hardButton.isSelected = false
            }
            if (time == 2) {
                easyButton.isSelected = false
                mediumButton.isSelected = false
                hardButton.isSelected = true
            }
        }
    }
    
}
