//
//  Deck.swift
//  CSE438S-Egyptian-Rat-Tap
//
//  Created by Isabel Sangimino on 11/20/20.
//  Copyright © 2020 Egyptian Rat Tap. All rights reserved.
//

import Foundation

enum Rank: String, Codable{
    case two, three, four, five, six, seven, eight, nine, ten
    case jack, queen, king, ace
    
    var numOfFlips: Int {
        switch self{
        case .jack: return 1
        case .queen: return 2
        case .king: return 3
        case .ace: return 4
        default: return 0
        }
        
    }
}
    
enum Suit: String, Codable{
    case spades, hearts, diamonds, clubs
}
    
struct Card: Codable {
    var rank: Rank
    var suit: Suit
}
    
struct Deck: Codable {
    var deck: [Card] = []
    
    //stackoverflow.com/questions/24109691/add-a-method-to-card-that-creates-a-full-deck-of-cards-with-one-card-of-each-co
    init() {
        let ranks = [Rank.ace, Rank.two, Rank.three, Rank.four, Rank.five, Rank.six, Rank.seven, Rank.eight, Rank.nine, Rank.ten, Rank.jack, Rank.queen, Rank.king]
        let suits = [Suit.spades, Suit.hearts, Suit.diamonds, Suit.clubs]
        for suit in suits {
            for rank in ranks {
                deck.append(Card(rank: rank, suit: suit))
            }
        }
        deck.shuffle()
    }
    func splitDeck() -> [[Card]]{
        var p1Deck: [Card] = []
        var p2Deck: [Card] = []
        let numCards = deck.count
        
        for i in 0...numCards/2{
            p1Deck[i] = deck[i]
        }
        for i in numCards/2...numCards{
            p2Deck[i] = deck[i]
        }
        return [p1Deck, p2Deck]
    }
}

