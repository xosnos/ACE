//
//  postVideoPopup.swift
//  swiftRANGR
//
//  Created by Ben Wozniak on 3/15/22.
//
import Foundation
import SwiftUI

func replayTapped() {
//    do something
}

struct replayButton: View {
    
    var body: some View {
        Button(action: {
            replayTapped()
        }) {
            Text("Replay").background(RoundedRectangle(cornerRadius: 4).fill(Color.white).frame(width: 150, height: 50))
        }
    }
}

func metricsTapped() {
//    do something
}

struct metricsButton: View {
    
    var body: some View {
        Button(action: {
            metricsTapped()
        }) {
            Text("Metrics").background(RoundedRectangle(cornerRadius: 4).fill(Color.white).frame(width: 150, height: 50))
        }
    }
}

func redoTapped() {
//    do something
}

struct redoButton: View {
    
    var body: some View {
        Button(action: {
            redoTapped()
        }) {
            Text("Redo").background(RoundedRectangle(cornerRadius: 4).fill(Color.white).frame(width: 150, height: 50))
        }
    }
}

struct Popup<T: View>: ViewModifier {
    let popup: T
    let isPresented: Bool

    // 1.
    init(isPresented: Bool, @ViewBuilder content: () -> T) {
        self.isPresented = isPresented
        popup = content()
    }

    // 2.
    func body(content: Content) -> some View {
        content
            .overlay(popupContent())
    }

    // 3.
    @ViewBuilder private func popupContent() -> some View {
        GeometryReader { geometry in
            if isPresented {
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        ZStack {
                            Color.gray
                            VStack {
                                Spacer()
                                metricsButton()
                                Spacer()
                                replayButton()
                                Spacer()
                                redoButton()
                                Spacer()
                            }
                            .accentColor(Color.black)
                        }
                        .frame(width: 200, height: 270)
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
    }
}
