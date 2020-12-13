//
//  ViewController.swift
//  CSE438S-Egyptian-Rat-Tap
//
//  Created by Isaac Bock on 11/14/20.
//  Copyright © 2020 Egyptian Rat Tap. All rights reserved.
//

import UIKit

var opponentQuit: Bool = false

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // create left card and position off screen in bottom left
        let leftCard = PlayingCard(rank: "A", suit: "clubs")
        leftCard.center = CGPoint(x: -300, y: self.view.center.y * 2 + 100)
        view.addSubview(leftCard)
        
        // create center card and position off screen in top right
        let centerCard = PlayingCard(rank: "2", suit: "hearts")
        centerCard.center = CGPoint(x: self.view.center.x + 100, y: -200)
        view.addSubview(centerCard)
        
        // create right card and position off screen in bottom right
        let rightCard = PlayingCard(rank: "3", suit: "spades")
        rightCard.center = CGPoint(x: self.view.center.x * 2 + 300, y: self.view.center.y * 2 + 100)
        view.addSubview(rightCard)
        
        // animate in cards to correct positions in middle of screen
        flyInCards(leftCard: leftCard, centerCard: centerCard, rightCard: rightCard)
    }
    
    func flyInCards(leftCard: PlayingCard, centerCard: PlayingCard, rightCard: PlayingCard) {
        // animate in left card
        UIView.animate(withDuration: 1.5, delay: 0, options: .curveEaseInOut, animations: {
            leftCard.center = CGPoint(x: self.view.center.x - 40, y: self.view.center.y - 140)
        })
        // flip over left card after 0.65 sec delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
            leftCard.flip()
        }
        // animate in center card
        UIView.animate(withDuration: 1.5, delay: 0.75, options: .curveEaseInOut, animations: {
            centerCard.center = CGPoint(x: self.view.center.x, y: self.view.center.y - 100)
        })
         // flip over center card after 1.2 sec delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            centerCard.flip()
        }
        // animate in right card
        UIView.animate(withDuration: 1.5, delay: 1.0, options: .curveEaseInOut, animations: {
            rightCard.center = CGPoint(x: self.view.center.x + 40, y: self.view.center.y - 60)
        })
        // flip over right card after 1.5 sec delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            rightCard.flip()
        }
    }

    // "X" button in top right corner returns user to main ViewController
    @IBAction func unwind(_ unwindSegue: UIStoryboardSegue) {
        _ = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
       // opponentQuitMessage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(opponentQuit){
            opponentQuitMessage()
            opponentQuit=false
        }
    }
    
    
    func opponentQuitMessage(){
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        let titleFont:[NSAttributedString.Key : AnyObject] = [ NSAttributedString.Key.font : UIFont(name: "Montserrat-Bold", size: 18)! ]
        let messageFont:[NSAttributedString.Key : AnyObject] = [ NSAttributedString.Key.font : UIFont(name: "Montserrat-Regular", size: 14)! ]

        let attributedTitle = NSMutableAttributedString(string: "Your opponent left the game.", attributes: titleFont)
        let attributedMessage = NSMutableAttributedString(string: "You win by default.", attributes: messageFont)
        alert.setValue(attributedTitle, forKey: "attributedTitle")
        alert.setValue(attributedMessage, forKey: "attributedMessage")
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { action in
             print("your opponent quit")
        }))

        present(alert, animated:true)
    }

}
