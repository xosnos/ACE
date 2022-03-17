//
//  ShotMetricRow.swift
//  swiftRANGR
//
//  Created by Steven Nguyen on 3/16/22.
//

import SwiftUI

struct ShotMetricRow: View {
    var shotMetric: ShotMetric
    var body: some View {
        VStack(alignment: .leading) {
            if let timeStamp = shotMetric.timeStamp {
                Text(timeStamp).padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0)).font(.system(size: 14))
            }
            HStack {
                if let launchAngle = shotMetric.launchAngle,
                   let launchSpeed = shotMetric.launchSpeed {
                    Text("Launch Angle: " + launchAngle + " degrees").padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0)).font(.system(size: 14))
                    Spacer()
                    Text("Launch Speed: " + launchSpeed + " mph").padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0)).font(.system(size: 14))
                }
            }
            HStack {
                if let hangTime = shotMetric.hangTime,
                   let distance = shotMetric.launchSpeed {
                    Text("Hang Time: " + hangTime + " seconds").padding(EdgeInsets(top: 8, leading: 0, bottom: 6, trailing: 0)).font(.system(size: 14))
                    Spacer()
                    Text("Distance: " + distance + " yards").padding(EdgeInsets(top: 8, leading: 0, bottom: 6, trailing: 0)).font(.system(size: 14))
                }
            }
        }
    }
}
