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
                button.deselectButton(title: title)
            }
        }
    }
    
    @IBAction func pickDriver(_ sender: HighlightedButton) {
        User.shared.club = "driver"
        sender.backgroundColor = .green
        didTapButton(title: "Driver")
    }
    @IBAction func pickWood(_ sender: HighlightedButton) {
        User.shared.club = "wood"
        sender.backgroundColor = .green
        didTapButton(title: "Wood")
    }
    @IBAction func pickIron(_ sender: HighlightedButton) {
        User.shared.club = "iron"
        sender.backgroundColor = .green
        didTapButton(title: "Iron")
    }
    @IBAction func pickWedge(_ sender: HighlightedButton) {
        User.shared.club = "wedge"
        sender.backgroundColor = .green
        didTapButton(title: "Wedge")
    }
    
}
