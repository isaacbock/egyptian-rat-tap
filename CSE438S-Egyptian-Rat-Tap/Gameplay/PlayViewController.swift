//
//  PlayViewController.swift
//  CSE438S-Egyptian-Rat-Tap
//
//  Created by Isaac Bock on 11/15/20.
//  Copyright © 2020 Egyptian Rat Tap. All rights reserved.
//

import UIKit

class PlayViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Create 3 test cards and add them to the screen. Update: yay, it works! 
        let card3 = PlayingCard(rank: "10", suit: "spade")
        card3.center = CGPoint(x: self.view.center.x - 30, y: self.view.center.y - 30);
        view.addSubview(card3)
        
        let card2 = PlayingCard(rank: "3", suit: "diamond")
        card2.center = CGPoint(x: self.view.center.x - 0, y: self.view.center.y - 0);
        view.addSubview(card2)
        
        let card1 = PlayingCard(rank: "K", suit: "club")
        card1.center = CGPoint(x: self.view.center.x + 30, y: self.view.center.y + 30);
        view.addSubview(card1)
    }

}
