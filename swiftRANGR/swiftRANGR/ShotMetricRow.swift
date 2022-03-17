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
            HStack {
                if let timeStamp = shotMetric.timeStamp,
                   let club = shotMetric.club {
                    Text(timeStamp)
                        .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0)).font(.system(size: 14))
                    Spacer()
                    Text("Club: " + club)
                        .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0)).font(.system(size: 14))
                }
            }
            HStack {
                if let launchAngle = shotMetric.launchAngle,
                   let hangTime = shotMetric.hangTime {
                    Text("Launch Angle: " + launchAngle + " deg")
                        .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0)).font(.system(size: 14))
                    Spacer()
                    Text("Hang Time: " + hangTime + " sec(s)")
                        .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0)).font(.system(size: 14))
                }
            }
            HStack {
                if let launchSpeed = shotMetric.launchSpeed,
                   let distance = shotMetric.launchSpeed {
                    Text("Launch Speed: " + launchSpeed + " mph")
                        .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)).font(.system(size: 14))
                    Spacer()
                    Text("Distance: " + distance + " yard(s)")
                        .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)).font(.system(size: 14))
                }
            }
        }
    }
}
