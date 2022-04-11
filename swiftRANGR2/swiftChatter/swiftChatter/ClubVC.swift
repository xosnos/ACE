//
//  ClubVC.swift
//  swiftChatter
//
//  Created by Alejandro Moncada on 4/11/22.
//

import UIKit

final class ClubVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    func didTapButton() {
        for view in self.view.subviews as [UIView] {
            if let button = view as? HighlightedButton {
                button.deselectButton()
            }
        }
    }
    
    @IBAction func pickDriver(_ sender: HighlightedButton) {
        User.shared.club = "driver"
        sender.justTapped = true
        didTapButton()
    }
    @IBAction func pickWood(_ sender: HighlightedButton) {
        User.shared.club = "wood"
        sender.justTapped = true
        didTapButton()
    }
    @IBAction func pickIron(_ sender: HighlightedButton) {
        User.shared.club = "iron"
        sender.justTapped = true
        didTapButton()
    }
    @IBAction func pickWedge(_ sender: HighlightedButton) {
        User.shared.club = "wedge"
        sender.justTapped = true
        didTapButton()
    }
    
}
