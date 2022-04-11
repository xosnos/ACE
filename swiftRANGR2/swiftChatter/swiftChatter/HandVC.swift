//
//  HandVC.swift
//  swiftChatter
//
//  Created by Alejandro Moncada on 4/11/22.
//

import UIKit

final class HandVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    func didTapButton(title: String) {
        for view in self.view.subviews as [UIView] {
            if let button = view as? HighlightedButton {
                button.deselectButton(title)
            }
        }
    }
    
    @IBAction func rightHand(_ sender: HighlightedButton) {
        User.shared.hand = "right"
        didTapButton("Right")
    }
    @IBAction func leftHand(_ sender: HighlightedButton) {
        User.shared.hand = "left"
        didTapButton("Left")
    }
    
}
