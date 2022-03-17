//
//  ContentView.swift
//  swiftRANGR
//
//  Created by Steven Nguyen on 3/13/22.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Camera", systemImage: "camera")
                }
            ShotsLogView()
                .tabItem {
                    Label("Shots Log", systemImage: "list.number")
                }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
