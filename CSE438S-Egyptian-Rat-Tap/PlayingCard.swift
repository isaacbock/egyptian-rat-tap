//
//  PlayingCard.swift
//  CSE438S-Egyptian-Rat-Tap
//
//  Created by Isaac Bock on 11/15/20.
//  Copyright © 2020 Egyptian Rat Tap. All rights reserved.
//

import UIKit

// Reusable xib view via https://stackoverflow.com/a/40104211
@IBDesignable
class PlayingCard: UIView {

    var contentView : UIView!
    
    @IBOutlet weak var cardLabelTop: UILabel!
    @IBOutlet weak var cardLabelBottom: UILabel!
    @IBOutlet weak var cardSuitImageTop: UIImageView!
    @IBOutlet weak var cardSuitImageBottom: UIImageView!
    
    var rank: String?
    var suit: String?
    
    init(rank: String?, suit: String?, frame: CGRect = CGRect(x: 0, y: 0, width: 120, height: 180)) {
        super.init(frame: frame)
        self.rank = rank
        self.suit = suit
        xibSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }

    func xibSetup() {
        contentView = loadViewFromNib()
        
        // Update card elements
        if let rank = self.rank {
            cardLabelTop.text = rank
            cardLabelBottom.text = rank
        }
        else {
            print("Card missing rank.")
            cardLabelTop.text = "?"
            cardLabelBottom.text = "?"
        }
        if let suit = self.suit {
            if suit == "club" || suit == "clubs" {
                cardSuitImageTop.image = UIImage(systemName: "suit.club.fill")
                cardSuitImageBottom.image = UIImage(systemName: "suit.club.fill")
                cardSuitImageTop.tintColor = .black
                cardSuitImageBottom.tintColor = .black
                cardLabelTop.textColor = .black
                cardLabelBottom.textColor = .black
            }
            else if suit == "spade" || suit == "spades" {
                cardSuitImageTop.image = UIImage(systemName: "suit.spade.fill")
                cardSuitImageBottom.image = UIImage(systemName: "suit.spade.fill")
                cardSuitImageTop.tintColor = .black
                cardSuitImageBottom.tintColor = .black
                cardLabelTop.textColor = .black
                cardLabelBottom.textColor = .black
            }
            else if suit == "heart" || suit == "hearts" {
                cardSuitImageTop.image = UIImage(systemName: "suit.heart.fill")
                cardSuitImageBottom.image = UIImage(systemName: "suit.heart.fill")
                cardSuitImageTop.tintColor = .red
                cardSuitImageBottom.tintColor = .red
                cardLabelTop.textColor = .red
                cardLabelBottom.textColor = .red
            }
            else if suit == "diamond" || suit == "dimaonds" {
                cardSuitImageTop.image = UIImage(systemName: "suit.diamond.fill")
                cardSuitImageBottom.image = UIImage(systemName: "suit.diamond.fill")
                cardSuitImageTop.tintColor = .red
                cardSuitImageBottom.tintColor = .red
                cardLabelTop.textColor = .red
                cardLabelBottom.textColor = .red
            }
            else {
                print("Card has invalid suit.")
                cardSuitImageTop.image = UIImage(systemName: "questionmark")
                cardSuitImageBottom.image = UIImage(systemName: "questionmark")
                cardSuitImageTop.tintColor = .black
                cardSuitImageBottom.tintColor = .black
                cardLabelTop.textColor = .black
                cardLabelBottom.textColor = .black
            }
        }
        else {
            print("Card missing suit.")
            cardSuitImageTop.image = UIImage(systemName: "questionmark")
            cardSuitImageBottom.image = UIImage(systemName: "questionmark")
            cardSuitImageTop.tintColor = .black
            cardSuitImageBottom.tintColor = .black
            cardLabelTop.textColor = .black
            cardLabelBottom.textColor = .black
        }
        
        
        // Rotate bottom card elements 180 degrees
        cardSuitImageBottom.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        cardLabelBottom.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        
        // Border
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.black.cgColor

        // use bounds not frame or it'll be offset
        contentView.frame = bounds

        // Make the view stretch with containing view
        contentView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]

        // Adding custom subview on top of our view
        addSubview(contentView)
        
    }

    func loadViewFromNib() -> UIView! {

        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView

        return view
    }
}
