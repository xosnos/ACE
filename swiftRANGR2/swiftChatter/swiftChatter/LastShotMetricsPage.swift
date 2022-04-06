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
        
        ChattStore.shared.getChatts()
        let metrics = ChattStore.shared.jsonObject
        
        let clubTypeView = ClubTypeView.self()
        clubTypeView.clubTypeLabel.text = metrics["club"]
        
        let launchAngleView = LaunchAngleView.self()
        launchAngleView.launchAngleLabel.text = metrics["launch_angle"]
        
        let launchSpeedView = LaunchSpeedView.self()
        launchSpeedView.launchSpeedLabel.text = metrics["launch_speed"]
        
        let hangTimeView = HangTimeView.self()
        hangTimeView.hangTimeLabel.text = metrics["hang_time"]
        
        let distanceView = DistanceView.self()
        distanceView.distanceLabel.text = metrics["distance"]
        
        
    }

}


