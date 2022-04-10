//
//  User.swift
//  swiftChatter
//
//  Created by Steven Nguyen on 4/10/22.
//

import Foundation

final class User {
    static let shared = User()
    private init() {}
    
    var userid = 0
    var loggedIn = false
    
    private let serverUrl = "https://34.70.39.80/"
    
    func mockLogin(_ username: String, _ password: String, _ completion: ((Bool) -> ())?) {
        var success = false
        defer { completion?(success) }
        if username == "ace" && password == "golfer" {
            self.userid = 1
            self.loggedIn = true
            success = true
        }
    }
    
    func mockCreate(_ username: String, _ password: String) {
        self.userid = 7
        self.loggedIn = true
    }
    
    func login(_ username: String, _ password: String, _ completion: ((Bool) -> ())?) {
        guard let apiUrl = URL(string: serverUrl + "accounts/login/") else {
            print("GET: Bad URL")
            return
        }

        var request = URLRequest(url: apiUrl)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            var success = false
            defer { completion?(success) }

            guard let data = data, error == nil else {
                print("GET: NETWORKING ERROR")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("GET: HTTP STATUS: \(httpStatus.statusCode)")
                return
            }

            guard let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String:Int] else {
                print("GET: failed JSON deserialization")
                return
            }
            self.userid = jsonObj["user_id"] ?? 0
            self.loggedIn = true
            success = true
        }.resume()
    }
    
    func create(_ username: String, _ password: String) {
        let jsonObj = ["username": username,
                       "password": password]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObj) else {
            print("POST: jsonData serialization error")
            return
        }
                
        guard let apiUrl = URL(string: serverUrl + "accounts/create/") else {
            print("POST: Bad URL")
            return
        }
        
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data, error == nil else {
                print("POST: NETWORKING ERROR")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("POST: HTTP STATUS: \(httpStatus.statusCode)")
                return
            }
        }.resume()
    }
}
