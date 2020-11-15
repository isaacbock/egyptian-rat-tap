//
//  BackgroundGradient.swift
//  CSE438S-Egyptian-Rat-Tap
//
//  Created by Isaac Bock on 11/14/20.
//  Copyright © 2020 Egyptian Rat Tap. All rights reserved.
//

import UIKit

//Background gradient via https://medium.com/@sakhabaevegor/create-a-color-gradient-on-the-storyboard-18ccfd8158c2
@IBDesignable
class BackgroundGradient: UIView {
    @IBInspectable var firstColor: UIColor = UIColor.clear {
        didSet {
           updateView()
        }
    }
    @IBInspectable var secondColor: UIColor = UIColor.clear {
        didSet {
            updateView()
        }
    }
    
    override class var layerClass: AnyClass {
        get {
           return CAGradientLayer.self
        }
    }
    func updateView() {
        let layer = self.layer as! CAGradientLayer
        layer.colors = [firstColor, secondColor].map{$0.cgColor}
    }
}
