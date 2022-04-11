//
//  ClubVC.swift
//  swiftChatter
//
//  Created by Alejandro Moncada on 4/11/22.
//

import UIKit

final class ClubVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for view in self.view.subviews as [UIView] {
            print("here")
            if let button = view as? HighlightedButton {
                if (button.titleLabel?.text == "Driver") {
                    button.tintColor = .green
                    button.isSelected = true
                }
            }
        }
    }
    
    func didTapButton(title: String) {
        for view in self.view.subviews as [UIView] {
            if let button = view as? HighlightedButton {
                button.deselectButton(title: title)
            }
        }
    }
    
    @IBAction func pickDriver(_ sender: HighlightedButton) {
        User.shared.club = "driver"
        sender.tintColor = .green
        didTapButton(title: "Driver")
    }
    @IBAction func pickWood(_ sender: HighlightedButton) {
        User.shared.club = "wood"
        sender.tintColor = .green
        didTapButton(title: "Wood")
    }
    @IBAction func pickIron(_ sender: HighlightedButton) {
        User.shared.club = "iron"
        sender.tintColor = .green
        didTapButton(title: "Iron")
    }
    @IBAction func pickWedge(_ sender: HighlightedButton) {
        User.shared.club = "wedge"
        sender.tintColor = .green
        didTapButton(title: "Wedge")
    }
    
}
