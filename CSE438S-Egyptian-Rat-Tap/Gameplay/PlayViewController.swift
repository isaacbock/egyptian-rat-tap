//
//  PlayViewController.swift
//  CSE438S-Egyptian-Rat-Tap
//
//  Created by Isaac Bock on 11/15/20.
//  Copyright © 2020 Egyptian Rat Tap. All rights reserved.
//

import UIKit

class PlayViewController: UIViewController {

    var pDeck:[Card] = []
    var comDeck:[Card] = []
    var pile:[Card] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let deck = Deck()
        
        let playerDecks = deck.splitDeck()
        pDeck = playerDecks[0]
        comDeck = playerDecks[1]
        
        // Create a card:
        // let card = PlayingCard(rank: "10", suit: "spade")
        
        // Set initial card location:
        // card.center = CGPoint(x: self.view.center.x, y: self.view.center.y);
        // view.addSubview(card)
        
        // Animate card to different locations:
        // UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseInOut, animations: {
        //     card.center = CGPoint(x: self.view.center.x + 100, y: self.view.center.y + 100)
        // })
        
        // Flip card over (to face up) halfway through the animation:
        // DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        //    card.flip()
        // }
        
    }

}
