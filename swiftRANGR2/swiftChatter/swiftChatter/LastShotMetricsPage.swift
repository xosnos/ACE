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
        
        
    }

}


