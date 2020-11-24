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

    var match: GKMatch?
    private var ratTapModel: RatTapModel! {
        didSet {
            updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ratTapModel = RatTapModel()
        match?.delegate = self
        // Do any additional setup after loading the view.
    }
    
    private func updateUI() {
        //perform UI updates
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

}
