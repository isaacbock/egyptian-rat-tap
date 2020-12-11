//
//  RatTapPlayer.swift
//  CSE438S-Egyptian-Rat-Tap
//
//  Created by Katie Lund on 11/23/20.
//  Copyright © 2020 Egyptian Rat Tap. All rights reserved.
//

import Foundation
import UIKit

struct RatTapPlayer: Codable {
    var name: String
    var playerDeck: [Card] = []
    var slapTime: Float = 0
}

enum PlayerType: String, Codable, CaseIterable {
    case one
    case two
    
    func index() -> Int {
        switch self {
        case .one:
            return 0
        case .two:
            return 1
        }
    }
}
