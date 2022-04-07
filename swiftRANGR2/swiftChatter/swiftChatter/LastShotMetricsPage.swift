//
//  LastShotMetricsPage.swift
//  swiftChatter
//
//  Created by Nathan Tsiang on 4/6/22.
//

import Foundation
import UIKit

final class LastShotMetricsPage:UIViewController {

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
        print("METRICS ---------------------")
        print(metrics)
        
        let clubTypeView = ClubTypeView.self()
        clubTypeView.clubTypeLabel.text = metrics["club"] ?? "N/A"

        let launchAngleView = LaunchAngleView.self()
        launchAngleView.launchAngleLabel.text = metrics["launch_angle"] ?? "N/A"

        let launchSpeedView = LaunchSpeedView.self()
        launchSpeedView.launchSpeedLabel.text = metrics["launch_speed"] ?? "N/A"

        let hangTimeView = HangTimeView.self()
        hangTimeView.hangTimeLabel.text = metrics["hang_time"] ?? "N/A"

        let distanceView = DistanceView.self()
        distanceView.distanceLabel.text = metrics["distance"] ?? "N/A"
    }
    
} // LastShotMetricsPage


