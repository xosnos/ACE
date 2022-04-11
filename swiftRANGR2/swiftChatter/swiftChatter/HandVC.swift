//
//  HandVC.swift
//  swiftChatter
//
//  Created by Alejandro Moncada on 4/11/22.
//

import UIKit

final class HandVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for view in self.view.subviews as [UIView] {
            if let button = view as? HighlightedButton {
                if (button.titleLabel?.text == "Right") {
                    button.tintColor = .green
                    button.isSelected = true
                }
            }
        }
    }
    
    func didTapButton(titleName: String) {
        for view in self.view.subviews as [UIView] {
            if let button = view as? HighlightedButton {
                button.deselectButton(title: titleName)
            }
        }
    }
    
    @IBAction func rightHand(_ sender: HighlightedButton) {
        User.shared.hand = "right"
        sender.tintColor = .green
        didTapButton(titleName: "Right")
    }
    @IBAction func leftHand(_ sender: HighlightedButton) {
        User.shared.hand = "left"
        sender.tintColor = .green
        didTapButton(titleName: "Left")
    }
    
}
