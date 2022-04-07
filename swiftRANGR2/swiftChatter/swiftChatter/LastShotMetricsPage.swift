//
//  LastShotMetricsPage.swift
//  swiftChatter
//
//  Created by Nathan Tsiang on 4/6/22.
//

import Foundation
import UIKit

final class LastShotMetricsPage:UIViewController {

    @IBOutlet weak var clubLabel: UILabel!
    @IBOutlet weak var clubTypeLabel: UILabel!

    @IBOutlet weak var launchAngleLabel: UILabel!
    @IBOutlet weak var launchAngleLabelValue: UILabel!
    @IBOutlet weak var degreeLabel: UILabel!
    
    @IBOutlet weak var launchSpeedLabel: UILabel!
    @IBOutlet weak var launchSpeedLabelValue: UILabel!
    @IBOutlet weak var mphLabel: UILabel!
    
    @IBOutlet weak var hangTimeLabel: UILabel!
    @IBOutlet weak var hangTimeLabelValue: UILabel!
    @IBOutlet weak var secLabel: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceLabelValue: UILabel!
    @IBOutlet weak var ydsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeGetRequest()
    }
    
    func makeGetRequest() {
        ChattStore.shared.getChatts {
            success in DispatchQueue.main.async {
                if success {
                    self.setValues()
                } // if success
            } // DispatchQueue
        } // getChatts
    } // func call
    
    func setValues() {
        let metrics = ChattStore.shared.jsonObject
        print(metrics)
        self.clubTypeLabel.text = metrics["club"] ?? "N/A"
        self.launchAngleLabelValue.text = metrics["launch_angle"] ?? "N/A"
        self.launchSpeedLabelValue.text = metrics["launch_speed"] ?? "N/A"
        self.hangTimeLabelValue.text = metrics["hang_time"] ?? "N/A"
        self.distanceLabelValue.text = metrics["distance"] ?? "N/A"

//
//        let hangTimeView = HangTimeView()
//        hangTimeView.hangTimeLabel.text = metrics["hang_time"] ?? "N/A"
//
//        let distanceView = DistanceView()
//        distanceView.distanceLabel.text = metrics["distance"] ?? "N/A"
    }
    
} // LastShotMetricsPage


