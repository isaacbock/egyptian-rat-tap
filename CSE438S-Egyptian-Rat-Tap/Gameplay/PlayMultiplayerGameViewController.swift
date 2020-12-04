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
    private var timer: Timer?
    
    private var ratTapModel: RatTapModel! {
        didSet {
            updateUI()
        }
    }
    var yourTurn:Bool = true
    var gestureRecognizerPile: UITapGestureRecognizer?
    
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
    }
    
    @objc func playerSlapped(_ sender: UITapGestureRecognizer){
        slap(isYou: true)
    }
    
    @objc func flipCard(_ sender: UITapGestureRecognizer) {
    }
    
    func slap(isYou: Bool) {
    
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

        sendData()
    }
    
    private func getLocalPlayerType() -> PlayerType {
        if ratTapModel.players.first?.name == GKLocalPlayer.local.displayName {
            return .one
        } else {
            return .two
        }
    }
    
    private func addCardToPile(){
        let localPlayer = getLocalPlayerType()
    
        let flippingCard = ratTapModel.players[localPlayer.index()].playerDeck.popLast()
        guard let card = flippingCard else{return }
        ratTapModel.pile.append(card)
        print(ratTapModel.players[localPlayer.index()].playerDeck.count)
        sendData()
    }

}
