//
//  BeginMultiplayerViewController.swift
//  CSE438S-Egyptian-Rat-Tap
//
//  Created by Isaac Bock on 11/15/20.
//  Copyright © 2020 Egyptian Rat Tap. All rights reserved.
//

import UIKit
import GameKit

class BeginMultiplayerViewController: UIViewController, GKLocalPlayerListener {
    private var gameKitActions: GameKitActions?
    var isAuthenticated: Bool {
        return GKLocalPlayer.local.isAuthenticated
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        gameKitActions = GameKitActions()
        gameKitActions?.delegate = self
        gameKitActions?.authenticatePlayer()
        
    }
        
    @IBAction func userReady(_ sender: Any) {
        gameKitActions?.presentMatchmaker()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? PlayMultiplayerGameViewController,
              let match = sender as? GKMatch else { return }
        
        vc.match = match
    }
    
}

extension BeginMultiplayerViewController: GameKitActionsDelegate {
    func didChangeAuthStatus(isAuthenticated: Bool) {
//        buttonMultiplayer.isEnabled = isAuthenticated
    }
    
    func presentGameCenterAuth(viewController: UIViewController?) {
        guard let vc = viewController else {return}
        self.present(vc, animated: true)
    }
    
    func presentMatchmaking(viewController: UIViewController?) {
        guard let vc = viewController else {return}
        self.present(vc, animated: true)
    }
    
    func presentGame(match: GKMatch) {
        performSegue(withIdentifier: "beginMultiplayerGame", sender: match)
    }
}
