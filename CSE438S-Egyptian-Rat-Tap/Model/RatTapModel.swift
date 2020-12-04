//
//  RatTapModel.swift
//  CSE438S-Egyptian-Rat-Tap
//
//  Created by Katie Lund on 11/23/20.
//  Copyright © 2020 Egyptian Rat Tap. All rights reserved.
//

import Foundation
import UIKit
import GameKit

struct RatTapModel: Codable {
    var players: [RatTapPlayer] = []
    var pile: [Card] = []
    var opponentFlipped: Bool = false
    var flippedCard: Card? = nil
    
    func encode() -> Data? {
        return try? JSONEncoder().encode(self)
    }
    
    static func decode(data: Data) -> RatTapModel? {
        return try? JSONDecoder().decode(RatTapModel.self, from: data)
    }
}

