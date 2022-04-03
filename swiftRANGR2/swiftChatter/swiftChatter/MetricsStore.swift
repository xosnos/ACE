//
//  MetricsStore.swift
//  swiftChatter
//
//  Created by Steven Nguyen on 3/18/22.
//

import Foundation

final class MetricsStore {
    static let shared = MetricsStore()
    private init() {}
    
    var log = [Metrics]()
    private let nFields = Mirror(reflecting: Metrics()).children.count

    private let serverUrl = "https://34.70.39.80/"
    
    func getShotLog(_ completion: ((Bool) -> ())?) {
        guard let apiUrl = URL(string: serverUrl + "get_shot_log/1/10/") else {
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
            
            guard let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String:Any] else {
                print("GET: failed JSON deserialization")
                return
            }
            let dataReceived = jsonObj["data"] as? [[String?]] ?? []
            self.log = [Metrics]()
            for entry in dataReceived {
                if entry.count == self.nFields {
                    self.log.append(Metrics(
                        timeStamp: entry[0],
                        club: entry[1],
                        launchAngle: entry[4],
                        launchSpeed: entry[3],
                        hangTime: entry[5],
                        distance: entry[2]))
                } else {
                    print("GET: Received unexpected number of fields: \(entry.count) instead of \(self.nFields).")
                }
            }
            success = true
        }.resume()
    }
}
