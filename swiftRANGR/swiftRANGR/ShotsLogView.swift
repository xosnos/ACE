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
        NavigationView {
            List {
                ForEach(store.shotMetrics.indices, id: \.self) {
                    ShotMetricRow(shotMetric: store.shotMetrics[$0])
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color(($0 % 2 == 0) ? .systemGray5 : .systemGray6))
                }
            }.refreshable {
                store.getShotMetrics(nil)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Shot Log")
                }
            }
            .task {
                store.getShotMetrics(nil)
            }
        }
    }
}

struct ShotsLogView_Previews: PreviewProvider {
    static var previews: some View {
        ShotsLogView()
    }
}
