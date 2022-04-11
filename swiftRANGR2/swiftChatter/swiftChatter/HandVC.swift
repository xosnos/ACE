//
//  HandVC.swift
//  swiftChatter
//
//  Created by Alejandro Moncada on 4/11/22.
//

import UIKit

final class HandVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    func didTapButton() {
        for view in self.view.subviews as [UIView] {
            if let button = view as? HighlightedButton {
                button.deselectButton()
            }
        }
    }
    
    @IBAction func rightHand(_ sender: HighlightedButton) {
        User.shared.hand = "right"
        sender.justTapped = true
        didTapButton()
    }
    @IBAction func leftHand(_ sender: HighlightedButton) {
        User.shared.hand = "left"
        sender.justTapped = true
        didTapButton()
    }
    
}
