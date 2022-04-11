//
//  ClubVC.swift
//  swiftChatter
//
//  Created by Alejandro Moncada on 4/11/22.
//

import UIKit

final class ClubVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    func didTapButton(title: String) {
        for view in self.view.subviews as [UIView] {
            if let button = view as? HighlightedButton {
                button.deselectButton(title)
            }
        }
    }
    
    @IBAction func pickDriver(_ sender: HighlightedButton) {
        User.shared.club = "driver"
        didTapButton("Driver")
    }
    @IBAction func pickWood(_ sender: HighlightedButton) {
        User.shared.club = "wood"
        didTapButton("Wood")
    }
    @IBAction func pickIron(_ sender: HighlightedButton) {
        User.shared.club = "iron"
        didTapButton("Iron")
    }
    @IBAction func pickWedge(_ sender: HighlightedButton) {
        User.shared.club = "wedge"
        didTapButton("Wedge")
    }
    
}
