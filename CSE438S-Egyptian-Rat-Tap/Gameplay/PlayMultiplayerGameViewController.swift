//
//  PlayMultiplayerGameViewController.swift
//  CSE438S-Egyptian-Rat-Tap
//
//  Created by Katie Lund on 11/23/20.
//  Copyright © 2020 Egyptian Rat Tap. All rights reserved.
//

import UIKit
import GameKit

//TO DO:
//  - face card logic
//  - burn logic
//  - winning logic

class PlayMultiplayerGameViewController: UIViewController, GKMatchDelegate {
    @IBOutlet weak var yourCardCountLabel: UILabel!
    @IBOutlet weak var opponentCardCountLabel: UILabel!
    @IBOutlet weak var exitButton: UIButton!
    
    var match: GKMatch?
    private weak var timer: Timer?
    private var playingCardPile: [PlayingCard] = []
    
    private var ratTapModel: RatTapModel! {
        didSet {
            updateUI()
        }
    }
    var yourTurn:Bool = true
    var playerNum:Int = 0
    var otherPlayerNum:Int = 0
    var gestureRecognizerPile: UITapGestureRecognizer?
    var gestureRecognizerDeck: UITapGestureRecognizer?
    var slapTime: Float = 0
    var flippedCard: Card? = nil
    var faceCardPlayed: Bool = false
    var faceCardPlayedByYou: Bool = false
    var faceCardCounter: Int = 0
    var collectFaceCardPile: Bool = false
    //End Message strings for slap message when win pile from face card (fc) or slap (s)...
    let fc:String = "won the pile"
    let s:String = "slapped"
    
    var quitter: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ratTapModel = RatTapModel()
        match?.delegate = self
        setUpGame()
        
        gestureRecognizerDeck = UITapGestureRecognizer(target: self, action: #selector(self.flipCard(_:)))
        gestureRecognizerPile = UITapGestureRecognizer(target: self, action: #selector(self.playerSlapped(_:)))
        
        // Create a dummy card:
        let pCard = PlayingCard(rank: "10", suit: "spade")
        pCard.center = CGPoint(x: self.view.center.x, y: self.view.center.y + 250);
                 view.addSubview(pCard)
        guard let flipGesture = gestureRecognizerDeck else {return}
        pCard.addGestureRecognizer(flipGesture)
        
        //opponents card
        let comCard = PlayingCard(rank: "10", suit: "spade")
        comCard.center = CGPoint(x: self.view.center.x, y: self.view.center.y - 250);
                view.addSubview(comCard)
                
        //labels
        guard let player2Name = match?.players.first?.displayName else { return }
        yourCardCountLabel.text = "\(GKLocalPlayer.local.displayName)'s Card Count: 26"
        opponentCardCountLabel.text = "\(player2Name)'s Card Count: 26"
    }
    
    //perform UI updates
    private func updateUI() {
        
        //ANIMATING THE OPPONENT'S CARD FLIPPING
        if (!faceCardPlayed || faceCardPlayedByYou) && !yourTurn && ratTapModel.opponentFlipped {
            ratTapModel.opponentFlipped = false
            guard let pop = ratTapModel.flippedCard else {return}
            // LOCAL RECENTLY FLIPPED CARD COMPARISON ENSURES THE SAME CARD ISN'T FLIPPED TWICE ON AN OPPONENT SLAP
            if flippedCard != nil && pop.rank == flippedCard?.rank && pop.suit == flippedCard?.suit {return}
            flippedCard = pop
            ratTapModel.flippedCard = nil
            sendData()
            faceCard()
            print("faceCardCounter from updateUI: \(faceCardCounter)")

            if faceCardPlayed {
                faceCardCounter -= 1
            }
            if faceCardPlayed && faceCardCounter < 0 {
                var yourPlayer = ratTapModel.players[playerNum]
                yourPlayer.playerDeck.append(contentsOf: ratTapModel.pile)
                ratTapModel.players[playerNum] = yourPlayer
                sendData()
                yourCardCountLabel.text = "\(GKLocalPlayer.local.displayName)'s Card Count: \(yourPlayer.playerDeck.count)"
                ratTapModel.pile = []
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.pileWon(isYou: true, player: self.ratTapModel.players[self.playerNum], endMessage: self.fc)
                    self.yourCardCountLabel.text = "\(GKLocalPlayer.local.displayName)'s Card Count: \(self.ratTapModel.players[self.playerNum].playerDeck.count + self.ratTapModel.pile.count)"
                }
                self.faceCardPlayed = false
                self.faceCardPlayedByYou = false
                self.faceCardCounter = 0
            }
            
            if !faceCardPlayed || !faceCardPlayedByYou {
                switchTurn(toYou: true)
            }
//            switchTurn(toYou: true)
            let card = PlayingCard(rank: pop.rank.rankOnCard, suit: pop.suit.rawValue)
            
            card.center = CGPoint(x: self.view.center.x, y: self.view.center.y - 250);
            view.addSubview(card)
            playingCardPile.append(card)
            
            UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseInOut, animations: {
            card.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
               card.flip()
            }
            
            guard let gesture = gestureRecognizerPile else {
                return
            }
            card.addGestureRecognizer(gesture)
//            switchTurn(toYou: true)
            checkPile()
            sendData()
        }
        
        //UPDATE OPPONENT'S LABEL
        if ratTapModel.players.count>0{
            yourCardCountLabel.text = "\(GKLocalPlayer.local.displayName)'s Card Count: \(ratTapModel.players[playerNum].playerDeck.count)"
            opponentCardCountLabel.text = "\(ratTapModel.players[otherPlayerNum].name)'s Card Count: \(ratTapModel.players[otherPlayerNum].playerDeck.count)"
        }
        
        if ratTapModel.players.count > 1 {
            var player = ratTapModel.players[playerNum]
            var otherPlayer = ratTapModel.players[otherPlayerNum]
            //OTHER PLAYER BURNS
            if player.opponentBurned {
                burnMessage(you: false)
                player.opponentBurned = false
                ratTapModel.players[playerNum] = player
                sendData()
            }
            
            if player.slapTime != 0 && otherPlayer.slapTime != 0 {
                // BOTH SLAP TIMES SET: CHECK WHO WON, DISPLAY YOUR MESSAGE
                let yourTime = player.slapTime
                let opponentTime = otherPlayer.slapTime
                print("your time: \(yourTime), opponent time: \(opponentTime)")
                // RESET TIMES
                player.slapTime = 0
                otherPlayer.slapTime = 0
                ratTapModel.players[playerNum] = player
                ratTapModel.players[otherPlayerNum] = otherPlayer
                sendData()
                
                if yourTime == opponentTime {
                    tieMessage()
                    print("tie")
                }
                else if yourTime < opponentTime {
                    print("\(GKLocalPlayer.local.displayName) won the pile")
                    pileWon(isYou: true, player: player, endMessage: self.s)
                    // NOTIFY OTHER PLAYER THEY LOST
                    otherPlayer.lostSlap = true
                    ratTapModel.players[otherPlayerNum] = otherPlayer
                    sendData()
                } else {
                    guard let player2Name = match?.players.first?.displayName else { return }
                    print("\(player2Name) won the pile")
                    pileWon(isYou: false, player: nil, endMessage: self.s)
                    // NOTIFY OTHER PLAYER THEY WON
                    otherPlayer.wonSlap = true
                    ratTapModel.players[otherPlayerNum] = otherPlayer
                    sendData()
                }
            }
            
            // YOU LOST SLAP
            if player.lostSlap {
                faceCardPlayedByYou = false
                faceCardPlayed = false
                faceCardCounter = 0
                pileWon(isYou: false, player: nil, endMessage: self.s)
                player.lostSlap = false
                ratTapModel.players[playerNum] = player
                sendData()
            }
            // YOU WON SLAP
            if player.wonSlap {
                faceCardPlayedByYou = false
                faceCardPlayed = false
                faceCardCounter = 0
                pileWon(isYou: true, player: player, endMessage: self.s)
                player.wonSlap = false
                ratTapModel.players[playerNum] = player
                sendData()
            }
        }
        
    }
    
    @objc func playerSlapped(_ sender: UITapGestureRecognizer){
        slap()
    }
    
    @objc func flipCard(_ sender: UITapGestureRecognizer) {
        if yourTurn {
            var player = ratTapModel.players[playerNum]
            let pop = player.playerDeck.removeFirst()
            ratTapModel.players[playerNum] = player
            
            let card = PlayingCard(rank: pop.rank.rankOnCard, suit: pop.suit.rawValue)
            yourCardCountLabel.text = "\(GKLocalPlayer.local.displayName)'s Card Count: \(player.playerDeck.count)"
            
            card.center = CGPoint(x: self.view.center.x, y: self.view.center.y + 250);
            view.addSubview(card)
            
            UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseInOut, animations: {
            card.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                card.flip()
            }
            
            ratTapModel.pile.append(pop)
            playingCardPile.append(card)
            guard let gesture = gestureRecognizerPile else {
                return
            }
            card.addGestureRecognizer(gesture)
            guard let flipGesture = gestureRecognizerDeck else {return}
            card.removeGestureRecognizer(flipGesture)
            ratTapModel.opponentFlipped = true
            ratTapModel.flippedCard = pop
            flippedCard = pop
            sendData()
            checkPile()
            faceCard()
            print("faceCardCounter from flipCard: \(faceCardCounter)")
            checkSlappable()
            sendData()
            //facecard if
            if !faceCardPlayed || faceCardPlayedByYou {
                switchTurn(toYou: false)
            }
            //            if faceCardCounter > 0 && !faceCardPlayedByYou {
            if faceCardPlayed && faceCardCounter >= 0 {
                faceCardCounter -= 1
            }
            if faceCardPlayed && faceCardCounter < 0 && !faceCardPlayedByYou {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.faceCardOver()
                }
            }
            
        }
        
    }
    
    func faceCardOver() {
        collectFaceCardPile = true
        faceCardPlayed = false
        faceCardPlayedByYou = false
        faceCardCounter = 0
        if !faceCardPlayedByYou {
            slap()
        }
    }
    
    func slap() {
        if checkSlap() {
            faceCardPlayedByYou = false
            faceCardPlayed = false
            faceCardCounter = 0
            // GET UNIX TIMESTAMP FOR NOW
            let yourTime = Date().timeIntervalSince1970
            var player = ratTapModel.players[playerNum]
            player.slapTime = yourTime
            ratTapModel.players[playerNum] = player
            var otherPlayer = ratTapModel.players[otherPlayerNum]
            if otherPlayer.slapTime == 0 {
                // OTHER PLAYER HAS NOT SLAPPED YET
                // THIS SHOULD HELP WITH SIMULTANEOUS SLAPS
                otherPlayer.slapTime = yourTime + 1
            }
            ratTapModel.players[otherPlayerNum] = otherPlayer
            ratTapModel.opponentFlipped = false
            sendData()
        } else if collectFaceCardPile {
            pileWon(isYou: false, player: nil, endMessage: self.fc)
//            slapMessage(won: false, endMessage: fc)
            collectFaceCardPile = false
            switchTurn(toYou: false)
        } else {
            if (ratTapModel.players[playerNum].playerDeck.count > 0) {
                var otherPlayer = ratTapModel.players[otherPlayerNum]
                otherPlayer.opponentBurned = true
                ratTapModel.players[otherPlayerNum] = otherPlayer
                ratTapModel.opponentFlipped = false
                sendData()
                burnMessage(you: true)
            } else {
                gameOver(isHuman: false)
            }
        }
    }
    
    func pileWon(isYou: Bool, player: RatTapPlayer?, endMessage: String) {
        if collectFaceCardPile && !isYou {
            let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
            let titleFont:[NSAttributedString.Key : AnyObject] = [ NSAttributedString.Key.font : UIFont(name: "Montserrat-Bold", size: 18)! ]
            let messageFont:[NSAttributedString.Key : AnyObject] = [ NSAttributedString.Key.font : UIFont(name: "Montserrat-Regular", size: 14)! ]
            let opponent = ratTapModel.players[otherPlayerNum]
            let attributedTitle = NSMutableAttributedString(string: "Your opponent \(endMessage)!", attributes: titleFont)
            let attributedMessage = NSMutableAttributedString(string: "They now have \(opponent.playerDeck.count + ratTapModel.pile.count) cards.", attributes: messageFont)
            alert.setValue(attributedTitle, forKey: "attributedTitle")
            alert.setValue(attributedMessage, forKey: "attributedMessage")
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { action in
            }))
            present(alert, animated:true)
        }
        else if isYou {
            guard var yourPlayer = player else {return}
            yourPlayer.playerDeck.append(contentsOf: ratTapModel.pile)
            ratTapModel.players[playerNum] = yourPlayer
            sendData()
            yourCardCountLabel.text = "\(GKLocalPlayer.local.displayName)'s Card Count: \(yourPlayer.playerDeck.count)"
            ratTapModel.pile = []
            slapMessage(won: true, endMessage: endMessage)
            switchTurn(toYou:true)
        }
        else {
            slapMessage(won: false, endMessage: endMessage)
            switchTurn(toYou:false)
        }
        // REMOVE CARDS
        for i in 0..<playingCardPile.count{
            playingCardPile[i].removeFromSuperview()
        }
        playingCardPile.removeAll()
        sendData()
    }
    
    //checks if pile is slappable
    func checkSlap() -> Bool {
        if collectFaceCardPile {return false}
        if(playingCardPile.count <= 1){
            return false
        } else if (playingCardPile.count>2 && playingCardPile[0].rank==playingCardPile[2].rank){ //sandwich
            return true
        } else{
            let card0 = playingCardPile[playingCardPile.count-2].rank
            let card1 = playingCardPile[playingCardPile.count-1].rank
            
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
    
    private func sendData() {
        guard let match = match else { return }
        
        do {
            guard let data = ratTapModel.encode() else { return }
            try match.sendData(toAllPlayers: data, with: .reliable)
        } catch {
            print("Send data failed")
        }
    }

    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        guard let model = RatTapModel.decode(data: data) else { return }
        ratTapModel = model
    }
    
    private func setUpGame() {
        guard let player2Name = match?.players.first?.displayName else { return }
        
        let wholeDeck = Deck().deck
        let numOfCards = wholeDeck.count/2
        
        var player1Deck: [Card] = []
        var player2Deck: [Card] = []
        for i in 0..<numOfCards{
            player1Deck.append(wholeDeck[i])
        }
        for i in numOfCards..<wholeDeck.count {
            player2Deck.append(wholeDeck[i])
        }
        
        let player1 = RatTapPlayer(name: GKLocalPlayer.local.displayName, playerDeck: player1Deck)
        let player2 = RatTapPlayer(name: player2Name, playerDeck: player2Deck)
        
        ratTapModel.players = [player1, player2]
        
        ratTapModel.players.sort { (player1, player2) -> Bool in
    player1.name < player2.name
        }
        
        if getLocalPlayerType() == .one {
            //yourTurn = true
            switchTurn(toYou: true)
            playerNum = 0
            otherPlayerNum = 1
        }
        else {
            //yourTurn = false
            switchTurn(toYou: false)
            playerNum = 1
            otherPlayerNum = 0
        }

        sendData()
    }
    
    private func getLocalPlayerType() -> PlayerType {
        if ratTapModel.players.first?.name == GKLocalPlayer.local.displayName {
            return .one
        } else {
            return .two
        }
    }
    
    func checkPile() {
            if (playingCardPile.count <= 3){
                for i in 0..<playingCardPile.count{
                    UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseInOut, animations: {
                        self.playingCardPile[i].center = CGPoint(x: self.view.center.x - CGFloat(50*(self.playingCardPile.count-1-i)), y: self.view.center.y)
                    })
                }
                guard let gesture = gestureRecognizerPile else {return}
                if (playingCardPile.count == 2){
                    playingCardPile[0].removeGestureRecognizer(gesture)
                }else if (playingCardPile.count == 3){
                    playingCardPile[1].removeGestureRecognizer(gesture)
                }
            }

            if playingCardPile.count > 3{
                playingCardPile[0].removeFromSuperview()
                playingCardPile.remove(at: 0)

                guard let gesture = gestureRecognizerPile else{
                    return
                }
                playingCardPile[1].removeGestureRecognizer(gesture)

                UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseInOut, animations: {
                    self.playingCardPile[0].center = CGPoint(x: self.view.center.x-100, y: self.view.center.y)
                })

                UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseInOut, animations: {
                    self.playingCardPile[1].center = CGPoint(x: self.view.center.x-50, y: self.view.center.y)
                })

                UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseInOut, animations: {
                    self.playingCardPile[2].center = CGPoint(x: self.view.center.x, y: self.view.center.y)
                })
            }
        }
    
    func checkSlappable() {
        let slappable = checkSlap()

        if slappable{
            print("starting timing")
            // GET CURRENT UNIX TIMESTAMP
            // DON'T ACTUALLY THINK THIS IS NECESSARY BUT LEAVING FOR NOW
            ratTapModel.slappableBegan = Date().timeIntervalSince1970
            print(Date().timeIntervalSince1970)
            sendData()
        }
        print(slappable)
    }
    
    func slapMessage(won: Bool, endMessage:String) {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        let titleFont:[NSAttributedString.Key : AnyObject] = [ NSAttributedString.Key.font : UIFont(name: "Montserrat-Bold", size: 18)! ]
        let messageFont:[NSAttributedString.Key : AnyObject] = [ NSAttributedString.Key.font : UIFont(name: "Montserrat-Regular", size: 14)! ]
        
        if won {
            let player = ratTapModel.players[playerNum]
            let attributedTitle = NSMutableAttributedString(string: "You \(endMessage)!", attributes: titleFont)
            let attributedMessage = NSMutableAttributedString(string: "You now have \(player.playerDeck.count) cards. You need \(52-player.playerDeck.count) more cards to win.", attributes: messageFont)
            alert.setValue(attributedTitle, forKey: "attributedTitle")
            alert.setValue(attributedMessage, forKey: "attributedMessage")
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { action in
                print("player slap!")
            }))
        }
        else{
            let opponent = ratTapModel.players[otherPlayerNum]
            let attributedTitle = NSMutableAttributedString(string: "Your opponent \(endMessage)!", attributes: titleFont)
            let attributedMessage = NSMutableAttributedString(string: "They now have \(opponent.playerDeck.count) cards.", attributes: messageFont)
            alert.setValue(attributedTitle, forKey: "attributedTitle")
            alert.setValue(attributedMessage, forKey: "attributedMessage")
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { action in
                print("opponent slap!")
            }))
        }
                
        present(alert, animated:true)
    }
    
    func faceCard() {
        if ratTapModel.pile.count == 0 {return}
        let lastCard = ratTapModel.pile[ratTapModel.pile.count-1]
        if(Int(lastCard.rank.rankOnCard)==nil){
            faceCardPlayed = true
            faceCardCounter = lastCard.rank.numOfFlips
            if yourTurn {
                faceCardPlayedByYou = true;
                print("Face card played by you")
            } else {
                faceCardPlayedByYou = false;
                print("Face card played by opponent")
            }
        }
    }
    
    func tieMessage() {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        let titleFont:[NSAttributedString.Key : AnyObject] = [ NSAttributedString.Key.font : UIFont(name: "Montserrat-Bold", size: 18)! ]
        let messageFont:[NSAttributedString.Key : AnyObject] = [ NSAttributedString.Key.font : UIFont(name: "Montserrat-Regular", size: 14)! ]
        
        let attributedTitle = NSMutableAttributedString(string: "You and your opponent tied!", attributes: titleFont)
        let attributedMessage = NSMutableAttributedString(string: "Keep playing to win the pile.", attributes: messageFont)
        alert.setValue(attributedTitle, forKey: "attributedTitle")
        alert.setValue(attributedMessage, forKey: "attributedMessage")
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { action in
            print("player slap!")
        }))
                
        present(alert, animated:true)
    }
    
    func burnMessage(you: Bool){
        var player: String = ""
        if you{
            player = "You have"
        }else{
            player = "Opponent has"
        }
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        let titleFont:[NSAttributedString.Key : AnyObject] = [ NSAttributedString.Key.font : UIFont(name: "Montserrat-Bold", size: 18)! ]
        let messageFont:[NSAttributedString.Key : AnyObject] = [ NSAttributedString.Key.font : UIFont(name: "Montserrat-Regular", size: 14)! ]

        let attributedTitle = NSMutableAttributedString(string: "Incorrect slap!", attributes: titleFont)
        let attributedMessage = NSMutableAttributedString(string: "\(player) to burn a card.", attributes: messageFont)
        alert.setValue(attributedTitle, forKey: "attributedTitle")
        alert.setValue(attributedMessage, forKey: "attributedMessage")
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { action in
             self.burn(you: you)
        }))

        present(alert, animated:true)
    }
       
       //when a player misslaps, they have to burn a card
    func burn(you: Bool){
        if you{
           //get card and animate
           var player = ratTapModel.players[playerNum]
           let pop = player.playerDeck.removeFirst()
           ratTapModel.players[playerNum] = player
           ratTapModel.flippedCard = pop
            
           let card = PlayingCard(rank: pop.rank.rankOnCard, suit: pop.suit.rawValue)
           card.center = CGPoint(x: self.view.center.x, y: self.view.center.y + 250);
           view.addSubview(card)
            
            if playingCardPile.count > 0 {
                view.insertSubview(card, belowSubview: playingCardPile[0])
            }

           card.flip()

           DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
               UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseInOut, animations: {
               card.center = CGPoint(x: self.view.center.x, y: self.view.center.y)})
               DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                   card.removeFromSuperview()
               }
           }
            
           //add to main pile
          ratTapModel.pile.insert(pop, at:0)
          sendData()
        } else {
            guard let pop = ratTapModel.flippedCard else {return}
            let card = PlayingCard(rank: pop.rank.rankOnCard, suit: pop.suit.rawValue)
            card.center = CGPoint(x: self.view.center.x, y: self.view.center.y - 250);
            view.addSubview(card)
            
            if playingCardPile.count > 0 {
                view.insertSubview(card, belowSubview: playingCardPile[0])
            }
            
            card.flip()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseInOut, animations: {
                card.center = CGPoint(x: self.view.center.x, y: self.view.center.y)})
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    card.removeFromSuperview()
                }
            }
            
            sendData()
        }
       }
    
    func gameOver(isHuman: Bool) {
           if isHuman {
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
    
    func switchTurn(toYou: Bool){
        if(!toYou){
            yourTurn = false
            opponentCardCountLabel.layer.shadowColor = UIColor.white.cgColor
            opponentCardCountLabel.layer.shadowRadius = 4
            opponentCardCountLabel.layer.shadowOpacity = 0.9
            opponentCardCountLabel.layer.shadowOffset = CGSize(width: 0,height: 0)
            opponentCardCountLabel.layer.masksToBounds = false
            yourCardCountLabel.layer.shadowRadius = 0
        } else {
            yourTurn = true
            yourCardCountLabel.layer.shadowColor = UIColor.white.cgColor
            yourCardCountLabel.layer.shadowRadius = 4
            yourCardCountLabel.layer.shadowOpacity = 0.9
            yourCardCountLabel.layer.shadowOffset = CGSize(width: 0,height: 0)
            yourCardCountLabel.layer.masksToBounds = false
            opponentCardCountLabel.layer.shadowRadius = 0
        }
    }
    
    @IBAction func quit(_ sender: Any) {
        DispatchQueue.main.async {
            self.quitter = GKLocalPlayer.local.displayName
            self.match?.disconnect()
        }
        print("you quit the game")
       }
    
    func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
       if quitter == nil {
        quitter = ratTapModel.players[otherPlayerNum].name
        }
        if(quitter != GKLocalPlayer.local.displayName){
            opponentQuit=true
            DispatchQueue.main.async {
                self.exitButton.sendActions(for: .touchUpInside)
            }
        }
    }
}
