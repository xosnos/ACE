//
//  ChattTableCell.swift
//  swiftChatter
//
//  Created by Nathan Tsiang on 1/13/22.
//

import UIKit

final class ChattTableCell: UITableViewCell {
    var playVideo: (() -> Void)?  // a closure
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
//    this two are in different order than video due to error
    @IBOutlet weak var chattImageView: UIImageView!
    @IBAction func videoTapped(_ sender: UIButton) {
        self.playVideo?()
    }
    @IBOutlet weak var videoButton: UIButton!
}
