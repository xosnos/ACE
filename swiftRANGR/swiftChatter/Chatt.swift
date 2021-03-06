//
//  Chatt.swift
//  swiftChatter
//
//  Created by Nathan Tsiang on 1/13/22.
//

import Foundation

struct Chatt {
    var userid: String?
    var hand: String?
    var club: String?
    @ChattPropWrapper var videoUrl: String?
}
@propertyWrapper
struct ChattPropWrapper {
    private var _value: String?
    var wrappedValue: String? {
        get { _value }
        set {
            guard let newValue = newValue else {
                _value = nil
                return
            }
            _value = (newValue == "null" || newValue.isEmpty) ? nil : newValue
        }
    }
    
    init(wrappedValue: String?) {
        self.wrappedValue = wrappedValue
    }
}
