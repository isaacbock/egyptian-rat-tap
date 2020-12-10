//
//  PlayMultiplayerGameViewController.swift
//  CSE438S-Egyptian-Rat-Tap
//
//  Created by Katie Lund on 11/23/20.
//  Copyright © 2020 Egyptian Rat Tap. All rights reserved.
//

import UIKit
import GameKit

class PlayMultiplayerGameViewController: UIViewController, GKMatchDelegate {
    @IBOutlet weak var yourCardCountLabel: UILabel!
    @IBOutlet weak var opponentCardCountLabel: UILabel!
    
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
    var slapTimer: Timer?
    var slapTime: Float = 0
    //End Message strings for slap message when win pile from face card (fc) or slap (s)...
    let fc:String = "won the pile"
    let s:String = "slapped"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ratTapModel = RatTapModel()
        match?.delegate = self
        // Do any additional setup after loading the view.
        setUpGame()
        
        let gestureRecognizerDeck = UITapGestureRecognizer(target: self, action: #selector(self.flipCard(_:)))
        
        gestureRecognizerPile = UITapGestureRecognizer(target: self, action: #selector(self.playerSlapped(_:)))
        
        // Create a card:
        let pCard = PlayingCard(rank: "10", suit: "spade")

        // Set initial card location:
        pCard.center = CGPoint(x: self.view.center.x, y: self.view.center.y + 250);
                 view.addSubview(pCard)
                
        let comCard = PlayingCard(rank: "10", suit: "spade")
                
        comCard.center = CGPoint(x: self.view.center.x, y: self.view.center.y - 250);
                view.addSubview(comCard)
                
        pCard.addGestureRecognizer(gestureRecognizerDeck)
        guard let player2Name = match?.players.first?.displayName else { return }
        
        yourCardCountLabel.text = "\(GKLocalPlayer.local.displayName)'s Card Count: 26"
        opponentCardCountLabel.text = "\(player2Name)'s Card Count: 26"
    }
    
    private func updateUI() {
        //perform UI updates
        if !yourTurn && ratTapModel.opponentFlipped {
            guard let pop = ratTapModel.flippedCard else {return}
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
            print("about to check pile for \(GKLocalPlayer.local.displayName)")
            checkPile()
            ratTapModel.opponentFlipped = false
            yourTurn = true
            sendData()
        }
        if yourTurn && ratTapModel.stopTimer {
            slapTimer?.invalidate()
            slapTimer = nil
            slapTime = 0
            slapMessage(won: false, endMessage: self.s)
            //remove cards
            for i in 0..<playingCardPile.count{
                playingCardPile[i].removeFromSuperview()
            }
            playingCardPile.removeAll()
            ratTapModel.stopTimer = false
            sendData()
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
            checkPile()
            ratTapModel.opponentFlipped = true
            ratTapModel.flippedCard = pop
            yourTurn = false
            sendData()
        }
    }
    
    func slap() {
//        if checkSlap() && !ratTapModel.stopTimer {
        if checkSlap() {
            let yourTime = ratTapModel.players[playerNum].slapTime
            slapTimer?.invalidate()
            slapTimer = nil
            slapTime = 0
            let opponentTime = ratTapModel.players[otherPlayerNum].slapTime
            print("your time: \(yourTime), opponent time: \(opponentTime)")
            ratTapModel.stopTimer = true
            if yourTime <= opponentTime {
                print("\(GKLocalPlayer.local.displayName) won the pile")
            } else {
                guard let player2Name = match?.players.first?.displayName else { return }
                print("\(player2Name) won the pile")
            }
            pileWon()
            sendData()
        }
    }
    
    func pileWon() {
        var player = ratTapModel.players[playerNum]
        player.playerDeck.append(contentsOf: ratTapModel.pile)
        ratTapModel.players[playerNum] = player
        yourCardCountLabel.text = "\(GKLocalPlayer.local.displayName)'s Card Count: \(player.playerDeck.count)"
        //remove cards
        for i in 0..<playingCardPile.count{
            playingCardPile[i].removeFromSuperview()
        }
        playingCardPile.removeAll()
        ratTapModel.pile = []
        slapMessage(won: true, endMessage: self.s)
        sendData()
    }
    
    //checks if pile is slappable
    func checkSlap() -> Bool {
        if(playingCardPile.count == 1){
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
            yourTurn = true
            playerNum = 0
            otherPlayerNum = 1
        }
        else {
            yourTurn = false
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
            let slappable = checkSlap()

            if slappable{
                print("starting timer")
                if slapTimer != nil {
                    print("bruh")
                }
                DispatchQueue.main.async {
                    self.slapTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                        print("timer fire")
                        self.slapTime += 0.1
                        var player = self.ratTapModel.players[self.playerNum]
                        player.slapTime = self.slapTime
                        self.ratTapModel.players[self.playerNum] = player
                        self.sendData()
                    }
                }
                
            }
            print(slappable)
//            print(faceCardCounter)
//    //        faceCard()
//            print(faceCardCounter)
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

}
