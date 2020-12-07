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
        
        
        // I can't get this line to run correctly here, but it does still work when called in userReady(). Not sure why but also I don't think I fully understand the authentication process... What I'm trying to do though is immediately open the matchmaker view. -Isaac
        gameKitActions?.presentMatchmaker()
    }
        
    @IBAction func userReady(_ sender: Any) {
        gameKitActions?.presentMatchmaker()
        
        // TO-DO:
        // update some variable to track that current user is ready
        
        // TO-DO: update text label of user to show checkmark or some other ready indicator
        
        // TO-DO: if all users are ready {
            // start game
//            performSegue(withIdentifier: "beginMultiplayerGame", sender: self)
        // }
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
