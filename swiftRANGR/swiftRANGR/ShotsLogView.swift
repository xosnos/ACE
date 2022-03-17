//
//  ShotsLogView.swift
//  swiftRANGR
//
//  Created by Steven Nguyen on 3/16/22.
//

import SwiftUI

struct ShotsLogView: View {
    @ObservedObject var store = ShotMetricStore.shared
    var body: some View {
        List(store.shotMetrics.indices, id: \.self) { index in
            ShotMetricRow(shotMetric: store.shotMetrics[index])
        }.listStyle(.plain)
            .refreshable {
                store.getShotMetrics(nil)
            }
    }
}

struct ShotsLogView_Previews: PreviewProvider {
    static var previews: some View {
        ShotsLogView()
    }
}
