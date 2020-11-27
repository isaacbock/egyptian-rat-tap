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
    var fullPile:[Card] = []
    var pile:[PlayingCard] = []
    var yourTurn:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let deck = Deck()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.flipCard(_:)))
        
        let playerDecks = deck.splitDeck()
        pDeck = playerDecks[0]
        comDeck = playerDecks[1]
        
//        while pDeck.count != 0 && comDeck.count != 0 {
//
//        }
        
        // Create a card:
         let pCard = PlayingCard(rank: "10", suit: "spade")
//
//         Set initial card location:
         pCard.center = CGPoint(x: self.view.center.x, y: self.view.center.y + 250);
         view.addSubview(pCard)
        
        let comCard = PlayingCard(rank: "10", suit: "spade")
        
        comCard.center = CGPoint(x: self.view.center.x, y: self.view.center.y - 250);
        view.addSubview(comCard)
        
        pCard.addGestureRecognizer(gestureRecognizer)
//
////         Animate card to different locations:
//         UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseInOut, animations: {
//             card.center = CGPoint(x: self.view.center.x + 100, y: self.view.center.y + 100)
//         })
////
////         Flip card over (to face up) halfway through the animation:
//         DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            card.flip()
//         }
    }
    
    @objc func flipCard(_ sender: UITapGestureRecognizer) {
        if yourTurn {
            guard let pop = pDeck.popLast() else{
                return
            }
            let card = PlayingCard(rank: pop.rank.rankOnCard, suit: pop.suit.rawValue)
            
            print(pop.description)
            
            card.center = CGPoint(x: self.view.center.x, y: self.view.center.y + 250);
            view.addSubview(card)
            
            UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseInOut, animations: {
            card.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
               card.flip()
                self.yourTurn = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.playComp()
                }
            }
            fullPile.append(pop)
            pile.append(card)
            
            checkPile(card: card)
        }
    }
    
    func playComp() {
        if !yourTurn {
            guard let pop = comDeck.popLast() else{
                return
            }
            let card = PlayingCard(rank: pop.rank.rankOnCard, suit: pop.suit.rawValue)
            
            print(pop.description)
            
            card.center = CGPoint(x: self.view.center.x, y: self.view.center.y - 250);
            view.addSubview(card)
            
            UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseInOut, animations: {
            card.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
               card.flip()
            }
            fullPile.append(pop)
            pile.append(card)
            
            checkPile(card: card)
            
            yourTurn = true
        }
    }
    
    func checkPile(card: PlayingCard) {
        if (pile.count <= 3){
            for i in 0..<pile.count{
                UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseInOut, animations: {
                    self.pile[i].center = CGPoint(x: self.view.center.x - CGFloat(50*(self.pile.count-1-i)), y: self.view.center.y)
                })
            }
        }
        
        if pile.count > 3{
            pile[0].removeFromSuperview()
            pile.remove(at: 0)
            
            UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseInOut, animations: {
                self.pile[0].center = CGPoint(x: self.view.center.x-100, y: self.view.center.y)
            })
            
            UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseInOut, animations: {
                self.pile[1].center = CGPoint(x: self.view.center.x-50, y: self.view.center.y)
            })
            
            UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseInOut, animations: {
                self.pile[2].center = CGPoint(x: self.view.center.x, y: self.view.center.y)
            })
        }
    }
    
    func checkSlap() {
        
    }

}
