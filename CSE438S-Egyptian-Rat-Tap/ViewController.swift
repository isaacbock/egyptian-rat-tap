//
//  ViewController.swift
//  CSE438S-Egyptian-Rat-Tap
//
//  Created by Isaac Bock on 11/14/20.
//  Copyright © 2020 Egyptian Rat Tap. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let leftCard = PlayingCard(rank: "A", suit: "clubs")
        leftCard.center = CGPoint(x: self.view.center.x - 40, y: self.view.center.y - 140)
        view.addSubview(leftCard)
        
        let centerCard = PlayingCard(rank: "2", suit: "hearts")
        centerCard.center = CGPoint(x: self.view.center.x, y: self.view.center.y - 100)
        view.addSubview(centerCard)
        
        let rightCard = PlayingCard(rank: "3", suit: "spades")
        rightCard.center = CGPoint(x: self.view.center.x + 40, y: self.view.center.y - 60)
        view.addSubview(rightCard)
    }

    // "X" button in top right corner returns user to main ViewController
    @IBAction func unwind(_ unwindSegue: UIStoryboardSegue) {
        _ = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }

}
