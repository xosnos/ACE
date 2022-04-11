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
    
    func deselectButton(title: String) {

        if title != titleLabel?.text {
            isEnabled = false
            isSelected = false
            isHighlighted = false
            backgroundColor = .blue
        }
    }
}
