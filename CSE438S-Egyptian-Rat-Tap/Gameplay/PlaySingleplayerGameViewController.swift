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
    var slappable:Bool = false
    var gestureRecognizerPile: UITapGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let deck = Deck()
        
        let gestureRecognizerDeck = UITapGestureRecognizer(target: self, action: #selector(self.flipCard(_:)))
        
        gestureRecognizerPile = UITapGestureRecognizer(target: self, action: #selector(self.humanSlapped(_:)))
        
        let playerDecks = deck.splitDeck()
        pDeck = playerDecks[0]
        comDeck = playerDecks[1]
        
        // Create a card:
         let pCard = PlayingCard(rank: "10", suit: "spade")

//        Set initial card location:
         pCard.center = CGPoint(x: self.view.center.x, y: self.view.center.y + 250);
         view.addSubview(pCard)
        
        let comCard = PlayingCard(rank: "10", suit: "spade")
        
        comCard.center = CGPoint(x: self.view.center.x, y: self.view.center.y - 250);
        view.addSubview(comCard)
        
        pCard.addGestureRecognizer(gestureRecognizerDeck)
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
            let pop = pDeck.removeFirst()
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
            
            guard let gesture = gestureRecognizerPile else {
                return
            }
            card.addGestureRecognizer(gesture)
            
            checkPile(card: card)
        }
    }
    
    func playComp() {
        if !yourTurn && !slappable {
            let pop = comDeck.removeFirst()
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
            
            guard let gesture = gestureRecognizerPile else {
                return
            }
            card.addGestureRecognizer(gesture)
            
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
            guard let gesture = gestureRecognizerPile else {return}
            if (pile.count == 2){
                pile[0].removeGestureRecognizer(gesture)
            }else if (pile.count == 3){
                pile[1].removeGestureRecognizer(gesture)
            }
        }
        
        if pile.count > 3{
            pile[0].removeFromSuperview()
            pile.remove(at: 0)
            
            guard let gesture = gestureRecognizerPile else{
                return
            }
            pile[1].removeGestureRecognizer(gesture)
            
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
        slappable = checkSlap()
        
        if slappable{
            DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                self.slap(isHuman: false)
            }
        }
        
        print(slappable)
    }
    
    func checkSlap() -> Bool {
        if(pile.count == 1){
            return false
        } else if (pile.count>2 && pile[0].rank==pile[2].rank){ //sandwich
            return true
        } else{
            let card0 = pile[pile.count-2].rank
            let card1 = pile[pile.count-1].rank
            
            if(card0 == card1){ //doubles
                return true
            } else if (card0=="K" && card1=="Q" || card0=="Q" && card1=="K"){ //marriage
                return true
            } else if (card0 != nil && card1 != nil){
                let card0Num = Int(card0!) ?? 11
                let card1Num = Int(card1!) ?? 11
                if (card0Num + card1Num == 10){
                    return true
                }
            }
        }
        return false
    }
    
    @objc func humanSlapped(_ sender: UITapGestureRecognizer){
        slap(isHuman: true)
    }
    
    func slap(isHuman: Bool) {
        if(slappable){
            
            slappable = false
            
            if(isHuman){
                pDeck.append(contentsOf: fullPile)
                yourTurn = true
                fullPile.removeAll()
                for i in 0..<pile.count{
                    pile[i].removeFromSuperview()
                }
                pile.removeAll()
                print("player slap!")
            }else {
                comDeck.append(contentsOf: fullPile)
                yourTurn = false
                print("computer slap!")
                fullPile.removeAll()
                for i in 0..<pile.count{
                    pile[i].removeFromSuperview()
                }
                pile.removeAll()
                playComp()
            }
        }
    }
    
}
