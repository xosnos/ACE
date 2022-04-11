//
//  HighlightedButton.swift
//  swiftChatter
//
//  Created by Alejandro Moncada on 4/5/22.
//

import UIKit

class HighlightedButton: UIButton {

    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? .blue : .green
        }
    }
    
    var justTapped = false
    
    func deselectButton() {

        if !justTapped {
            isEnabled = false
            isHighlighted = false
            backgroundColor = .blue
        }
        
        justTapped = false
    }
}
