//
//  RoundedButton.swift
//  CSE438S-Egyptian-Rat-Tap
//
//  Created by Isaac Bock on 11/26/20.
//  Copyright © 2020 Egyptian Rat Tap. All rights reserved.
//

import UIKit

// Rounded button adapted from https://stackoverflow.com/a/46684257
class RoundedButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderWidth = 5 / UIScreen.main.nativeScale
        layer.borderColor = UIColor(white: 1.0, alpha: 0.8).cgColor
        contentEdgeInsets = UIEdgeInsets(top: 10, left: 25, bottom: 10, right: 25)
    }
    
    override func layoutSubviews(){
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
        backgroundColor = UIColor.clear
        self.titleLabel?.textColor = UIColor.white
    }
    
}
