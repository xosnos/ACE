//
//  ChattStore.swift
//  swiftChatter
//
//  Created by Nathan Tsiang on 1/13/22.
//

import Foundation
import Alamofire

final class ChattStore {
    static let shared = ChattStore() // create one instance of the class to be shared
    
    var jsonObject: [String: String] = [:]
    
    private init() {}                // and make the constructor private so no other
                                     // instances can be created
    let propertyNotifier = NotificationCenter.default
    let propertyName = NSNotification.Name("ChattStore")
    var done = false
    var chatts = [Chatt]() {
        didSet {
            propertyNotifier.post(name: propertyName, object: nil)
        }
    }
    private let nFields = Mirror(reflecting: Chatt()).children.count

    private let serverUrl = "https://34.70.39.80/"
    // Once you have your own back-end server set up, you will replace mobapp.eecs.umich.edu with your server’s IP address.

    
    
    

    

    func getChatts(_ completion: ((Bool) -> ())?) {
        guard let apiUrl = URL(string: serverUrl+"get_user_last_shot/" + String(User.shared.userid)) else {
            print("getChatts: bad URL")
            return
        }

        // for each thing get_user_last_shot/userid ... hand ...
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
            
            guard let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String:String] else {
                print("GET: failed JSON deserialization")
                return
            }


            self.jsonObject = [
                "launch_angle": jsonObj["launch_angle"]!,
                "launch_speed": jsonObj["launch_speed"]!,
                "hang_time": jsonObj["hang_time"]!,
                "distance": jsonObj["distance"]!,
                "club": jsonObj["club"]!,
                "time": jsonObj["time"]!]
            success = true

        }.resume() // AF.request
//        let temp
//        print(temp)
        return
    } // getChatts
} // class ChattStore

