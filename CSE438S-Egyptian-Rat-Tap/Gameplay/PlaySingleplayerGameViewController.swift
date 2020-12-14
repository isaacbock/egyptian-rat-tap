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
    var comCardCount: Int = 26
    var pCardCount: Int = 26
    var faceCardCounter: Int = 0
    var faceCardPlayedByHuman:Bool = true
    var faceCardPlayed:Bool = false
    var collectFaceCardPile:Bool = false
    var comSlapTime: Double = 4
    
    //End Message strings for slap message when win pile from face card (fc) or slap (s)...
    let fc:String = "won the pile"
    let s:String = "slapped"
    
    @IBOutlet weak var comCardCountLabel: UILabel!
    @IBOutlet weak var pCardCountLabel: UILabel!
    @IBOutlet weak var exitButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set up decks
        let deck = Deck()
        let playerDecks = deck.splitDeck()
        pDeck = playerDecks[0]
        comDeck = playerDecks[1]
    
        //used to recognize a slap
        gestureRecognizerPile = UITapGestureRecognizer(target: self, action: #selector(self.humanSlapped(_:)))
        
        // Create a dummy card to look like player's deck:
        let pCard = PlayingCard(rank: "10", suit: "spade")
        pCard.center = CGPoint(x: self.view.center.x, y: self.view.center.y + 250);
        view.addSubview(pCard)
        let gestureRecognizerDeck = UITapGestureRecognizer(target: self, action: #selector(self.flipCard(_:)))
        pCard.addGestureRecognizer(gestureRecognizerDeck)
        
        // Create a dummy card to look like computers's deck:
        let comCard = PlayingCard(rank: "10", suit: "spade")
        comCard.center = CGPoint(x: self.view.center.x, y: self.view.center.y - 250);
        view.addSubview(comCard)
    
        //set up labels
        pCardCountLabel.text = "Player Card Count: \(pCardCount)"
        comCardCountLabel.text = "Computer Card Count: \(comCardCount)"
        switchTurn(toHuman:true)
    }
    
    //when a player plays a card (i.e., flips a card from their deck to the main pile)
    @objc func flipCard(_ sender: UITapGestureRecognizer) {
        if yourTurn {
            print()
            print("------------YOUR TURN------------")
            
            //get card from your deck
            let pop = pDeck.removeFirst()
            pCardCount -= 1
            pCardCountLabel.text = "Player Card Count: \(pCardCount)"
            print(pop.description)
            
            //create and animate PlayingCard
            let card = PlayingCard(rank: pop.rank.rankOnCard, suit: pop.suit.rawValue)
            card.center = CGPoint(x: self.view.center.x, y: self.view.center.y + 250);
            view.addSubview(card)
            
            UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseInOut, animations: {
            card.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                card.flip()
            }
            
            //add card to pile in middle
            fullPile.append(pop)
            pile.append(card)
            
            //add gesture to card
            guard let gesture = gestureRecognizerPile else {
                return
            }
            card.addGestureRecognizer(gesture)
            
            checkPile()
            
            // add not slappable logic??
            if (faceCardPlayed && faceCardPlayedByHuman && comCardCount == 0 && !slappable) {
                gameOver(isHuman: true)
            }
            
            //logic for face cards TO DO
             if self.faceCardCounter > 0 && !faceCardPlayedByHuman{
                self.faceCardCounter -= 1
            }
            
             if faceCardCounter > 0 && !faceCardPlayedByHuman {
                 print("human has to play another card")
                if (pCardCount == 0) {
                    gameOver(isHuman: false)
                }
             }else{
                if(faceCardPlayed && faceCardCounter == 0){
                        self.faceCardOver()
                }else {
                    if (comCardCount > 0) {
                        print("human turn over. switches to comp")
                        self.switchTurn(toHuman:false)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            self.playComp()
                        }
                    }
                }
            }
        }
    }
    
    //computer plays a card
    func playComp() {
        //TO DO: Add in burn boolean to stop computer from playing if you burn a card.
        
        if !yourTurn && !slappable {
            print()
            print("------------COMPUTER TURN------------")
            
            //get card from comp deck
            let pop = comDeck.removeFirst()
            comCardCount -= 1
            comCardCountLabel.text = "Computer Card Count: \(comCardCount)"
            print(pop.description)
            
            //create and animate PlayingCard
            let card = PlayingCard(rank: pop.rank.rankOnCard, suit: pop.suit.rawValue)
            card.center = CGPoint(x: self.view.center.x, y: self.view.center.y - 250);
            view.addSubview(card)
            
            UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseInOut, animations: {
            card.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
               card.flip()
            }
            
            //add card to pile in middle
            fullPile.append(pop)
            pile.append(card)
            
            //add gesture to card
            guard let gesture = gestureRecognizerPile else {
                return
            }
            card.addGestureRecognizer(gesture)
            
            checkPile()
            
            // add not slappable logic??
            if (faceCardPlayed && !faceCardPlayedByHuman && pCardCount == 0) {
                gameOver(isHuman: false)
            }
            
            //face card logic
            if faceCardCounter > 0 && faceCardPlayedByHuman{
                faceCardCounter -= 1
            }
            
            if faceCardCounter > 0 && faceCardPlayedByHuman{
                print("comp has to play another card")
                if (comCardCount == 0) {
                    gameOver(isHuman: true)
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self.playComp()
                    }
                }
            }else{
                if(faceCardPlayed && faceCardCounter == 0){
                        self.faceCardOver()
                }else {
                    if (pCardCount > 0) {
                        print("comp turn over.  humans turn")
                        self.switchTurn(toHuman: true)
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            self.playComp()
                        }
                    }
                }
            }
        }
    }
    
    
    // this function check to see if adjustments need to be made to pile after a card is added
    func checkPile() {
        //case 1: first three cards
        if (pile.count <= 3){
            //moves cards to the left
            for i in 0..<pile.count{
                UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseInOut, animations: {
                    self.pile[i].center = CGPoint(x: self.view.center.x - CGFloat(50*(self.pile.count-1-i)), y: self.view.center.y)
                })
            }
            
            //removes recognizer from bottom cards so only the top card has the recognizer
            guard let gesture = gestureRecognizerPile else {return}
            if (pile.count == 2){
                pile[0].removeGestureRecognizer(gesture)
            }else if (pile.count == 3){
                pile[1].removeGestureRecognizer(gesture)
            }
        }
        
        //case 2: more than three cards have been played
        if pile.count > 3{
            //remove old card
            let oldCard = pile[0];
            pile.remove(at: 0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                oldCard.removeFromSuperview()
            }
            
            //removes recognizer from bottom card so only the top card has the recognizer
            guard let gesture = gestureRecognizerPile else{
                return
            }
            pile[1].removeGestureRecognizer(gesture)
            
            //shifts cards to the left
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
        
        //checks if pile is slappable
        slappable = checkSlap()
        
        if slappable{
            DispatchQueue.main.asyncAfter(deadline: .now() + comSlapTime){
                //computer slaps if human doesn't slap in time
                self.slap(isHuman: false)
            }
        }
        print("slappable bool is \(slappable)")
        
        //TO DO: face card logic
        print("before calling faceCard function: \(faceCardCounter)")
        faceCard()
        print("after calling faceCard function: \(faceCardCounter)")
    }
    
    //checks if pile is slappable
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
        if(slappable || collectFaceCardPile){
            faceCardCounter = 0
            
            if(isHuman && slappable){
                pileWon(isHuman: true)
                slapMessage(isHuman: isHuman, endMessage: s)
            } else if (isHuman && collectFaceCardPile){
                pileWon(isHuman: true)
                slapMessage(isHuman: isHuman, endMessage: fc)
            }else if (slappable){
                self.pileWon(isHuman: false)
                self.slapMessage(isHuman: isHuman, endMessage: s)
            }else{
                self.pileWon(isHuman: false)
                self.slapMessage(isHuman: isHuman, endMessage: fc)
            }
            slappable = false
        } else if (isHuman){
            //burn a card
            if (pCardCount > 0) {
                pCardCount-=1
                pCardCountLabel.text = "Player Card Count: \(pCardCount)"
                burnMessage()
            } else {
                gameOver(isHuman: false)
            }
        }
    }
    
    //the middle pile was won, takes in a parameter of whether the human or comp won
    func pileWon(isHuman: Bool){
        if isHuman {
            //add cards to your deck
            pDeck.append(contentsOf: fullPile)
            switchTurn(toHuman: true)
            
            //change card count
            pCardCount += fullPile.count
            pCardCountLabel.text = "Player Card Count: \(pCardCount)"
            if (pCardCount == 52) {
                gameOver(isHuman: true)
            }
        } else {
            //add cards to comp deck
            comDeck.append(contentsOf: fullPile)
            switchTurn(toHuman: false)
            
            //change card count
            comCardCount += fullPile.count
            comCardCountLabel.text = "Computer Card Count: \(comCardCount)"
            if (comCardCount == 52) {
                gameOver(isHuman: false)
            }
        }

        //remove cards
        fullPile.removeAll()
        for i in 0..<pile.count{
            pile[i].removeFromSuperview()
        }
        pile.removeAll()
        
        faceCardPlayed = false
        collectFaceCardPile = false
    }
    
    func gameOver(isHuman: Bool) {
        gameEnd = true
        if isHuman {
                opponentWon = false
                let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
                let titleFont:[NSAttributedString.Key : AnyObject] = [ NSAttributedString.Key.font : UIFont(name: "Montserrat-Bold", size: 18)! ]
                let messageFont:[NSAttributedString.Key : AnyObject] = [ NSAttributedString.Key.font : UIFont(name: "Montserrat-Regular", size: 14)! ]
                let attributedTitle = NSMutableAttributedString(string: "You won!", attributes: titleFont)
                let attributedMessage = NSMutableAttributedString(string: "Game over.", attributes: messageFont)
                alert.setValue(attributedTitle, forKey: "attributedTitle")
                alert.setValue(attributedMessage, forKey: "attributedMessage")
                alert.addAction(UIAlertAction(title: "Exit game", style: .cancel, handler: { action in
                    self.exitButton.sendActions(for: .touchUpInside)
                }))
            present(alert, animated:true)
        } else {
                opponentWon = true
                let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
                let titleFont:[NSAttributedString.Key : AnyObject] = [ NSAttributedString.Key.font : UIFont(name: "Montserrat-Bold", size: 18)! ]
                let messageFont:[NSAttributedString.Key : AnyObject] = [ NSAttributedString.Key.font : UIFont(name: "Montserrat-Regular", size: 14)! ]
                let attributedTitle = NSMutableAttributedString(string: "Your opponent won.", attributes: titleFont)
                let attributedMessage = NSMutableAttributedString(string: "Game over.", attributes: messageFont)
                alert.setValue(attributedTitle, forKey: "attributedTitle")
                alert.setValue(attributedMessage, forKey: "attributedMessage")
                alert.addAction(UIAlertAction(title: "Exit game", style: .cancel, handler: { action in
                    self.exitButton.sendActions(for: .touchUpInside)
                }))
            present(alert, animated:true)
        }
    }
    
    func slapMessage(isHuman:Bool, endMessage:String) {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        let titleFont:[NSAttributedString.Key : AnyObject] = [ NSAttributedString.Key.font : UIFont(name: "Montserrat-Bold", size: 18)! ]
        let messageFont:[NSAttributedString.Key : AnyObject] = [ NSAttributedString.Key.font : UIFont(name: "Montserrat-Regular", size: 14)! ]
        
        if(isHuman){
            let attributedTitle = NSMutableAttributedString(string: "You \(endMessage)!", attributes: titleFont)
            let attributedMessage = NSMutableAttributedString(string: "You now have \(pCardCount) cards. You need \(52-pCardCount) more cards to win.", attributes: messageFont)
            alert.setValue(attributedTitle, forKey: "attributedTitle")
            alert.setValue(attributedMessage, forKey: "attributedMessage")
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { action in
                print("player slap!")
            }))
        }else{
            let attributedTitle = NSMutableAttributedString(string: "Your opponent \(endMessage)!", attributes: titleFont)
            let attributedMessage = NSMutableAttributedString(string: "They now have \(comCardCount) cards.", attributes: messageFont)
            alert.setValue(attributedTitle, forKey: "attributedTitle")
            alert.setValue(attributedMessage, forKey: "attributedMessage")
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { action in
                print("computer slap!")
                self.playComp()
            }))
        }
        
        present(alert, animated:true)
    }
    
    func burnMessage(){
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        let titleFont:[NSAttributedString.Key : AnyObject] = [ NSAttributedString.Key.font : UIFont(name: "Montserrat-Bold", size: 18)! ]
        let messageFont:[NSAttributedString.Key : AnyObject] = [ NSAttributedString.Key.font : UIFont(name: "Montserrat-Regular", size: 14)! ]
        
        let attributedTitle = NSMutableAttributedString(string: "Incorrect slap!", attributes: titleFont)
        let attributedMessage = NSMutableAttributedString(string: "You have to burn a card.", attributes: messageFont)
        alert.setValue(attributedTitle, forKey: "attributedTitle")
        alert.setValue(attributedMessage, forKey: "attributedMessage")
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { action in
           print("player burn!")
           self.burn()
           self.playComp()
        }))
        
        present(alert, animated:true)
    }
    
    //when a player misslaps, they have to burn a card
    func burn(){
        //get card and animate
        let pop = pDeck.removeFirst()
        let card = PlayingCard(rank: pop.rank.rankOnCard, suit: pop.suit.rawValue)

        card.center = CGPoint(x: self.view.center.x, y: self.view.center.y + 250);
        view.addSubview(card)
        
        view.insertSubview(card, belowSubview: pile[0])
        
        card.flip()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseInOut, animations: {
            card.center = CGPoint(x: self.view.center.x, y: self.view.center.y)})
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                card.removeFromSuperview()
            }
        }
        
        //add to main pile
        fullPile.insert(pop, at: 0)
    }
    
    func faceCard() {
        let lastCard = fullPile[fullPile.count-1]
        if(Int(lastCard.rank.rankOnCard)==nil){
            faceCardPlayed = true
            faceCardCounter = lastCard.rank.numOfFlips
            if(yourTurn){
                faceCardPlayedByHuman = true;
            } else {
                faceCardPlayedByHuman = false;
            }
        }
    }

    func faceCardOver(){
        
        print("face card over")
        
        collectFaceCardPile = true
       
        if !faceCardPlayedByHuman {
            DispatchQueue.main.asyncAfter(deadline: .now() + comSlapTime){
                self.slap(isHuman: false)
            }
            switchTurn(toHuman: false)
        } else {
            switchTurn(toHuman: true)
        }
    }
    
    func switchTurn(toHuman: Bool){
        if(!toHuman){
            yourTurn = false
            comCardCountLabel.layer.shadowColor = UIColor.white.cgColor
            comCardCountLabel.layer.shadowRadius = 4
            comCardCountLabel.layer.shadowOpacity = 0.9
            comCardCountLabel.layer.shadowOffset = CGSize(width: 0,height: 0)
            comCardCountLabel.layer.masksToBounds = false
            pCardCountLabel.layer.shadowRadius = 0
        } else {
            yourTurn = true
            pCardCountLabel.layer.shadowColor = UIColor.white.cgColor
            pCardCountLabel.layer.shadowRadius = 4
            pCardCountLabel.layer.shadowOpacity = 0.9
            pCardCountLabel.layer.shadowOffset = CGSize(width: 0,height: 0)
            pCardCountLabel.layer.masksToBounds = false
            comCardCountLabel.layer.shadowRadius = 0
        }
        

    }
    //TO DO:
    //get rid of weird glitch where you can incorrectly slap if you slap too fast on your lil jack guy when u put it down and then the computer doesnt put down another face card guy 
    
}
