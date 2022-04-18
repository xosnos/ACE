//
//  User.swift
//  swiftChatter
//
//  Created by Steven Nguyen on 4/10/22.
//

import Foundation
import Alamofire

final class User {
    static let shared = User()
    private init() {}
    
    var userid = 0
    var hand = "right"
    var club = "driver"
    var loggedIn = false
    
    private let serverUrl = "https://34.70.39.80/"
    var jsonObject: [String: String] = [:]
    
    func login(_ username: String, _ password: String, _ completion: ((Bool) -> ())?) {
        guard let apiUrl = URL(string: serverUrl + "accounts/login/?username=" + username + "&password=" + password) else {
            print("ACCOUNT LOGIN: Bad URL")
            return
        }

        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"

        URLSession.shared.dataTask(with: request) { data, response, error in
            var success = false
            defer { completion?(success) }

            guard let data = data, error == nil else {
                print("ACCOUNT LOGIN: NETWORKING ERROR")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("ACCOUNT LOGIN: HTTP STATUS: \(httpStatus.statusCode)")
                return
            }

            guard let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String:Int] else {
                print("ACCOUNT LOGIN: failed JSON deserialization")
                return
            }
            self.userid = jsonObj["user_id"] ?? 0
            self.loggedIn = true
            success = true
        }.resume()
    }
    
    func create(_ username: String, _ password: String) {
        guard let apiUrl = URL(string: serverUrl + "accounts/create/?username=" + username + "&password=" + password) else {
            print("ACCOUNT CREATE: BAD URL")
            return
        }
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data, error == nil else {
                print("ACCOUNT CREATE: NETWORKING ERROR")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("ACCOUNT CREATE: HTTP STATUS: \(httpStatus.statusCode)")
                return
            }
        }.resume()
    }
}
