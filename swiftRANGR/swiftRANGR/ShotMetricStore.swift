//
//  ShotMetricStore.swift
//  swiftRANGR
//
//  Created by Steven Nguyen on 3/16/22.

import Foundation

final class ShotMetricStore: ObservableObject  {
    static let shared = ShotMetricStore()
    private init() {}
    
    @Published private(set) var shotMetrics = [ShotMetric]()
    private let nFields = Mirror(reflecting: ShotMetric()).children.count

    private let serverUrl = "https://34.70.39.80/"
    
    func getShotMetrics(_ completion: ((Bool) -> ())?) {
        guard let apiUrl = URL(string: serverUrl + "get_/") else {
            print("get_: Bad URL")
            return
        }
        
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            var success = false
            defer { completion?(success) }

            guard let data = data, error == nil else {
                print("get_: NETWORKING ERROR")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("get_: HTTP STATUS: \(httpStatus.statusCode)")
                return
            }
            
            guard let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String:Any] else {
                print("get_: failed JSON deserialization")
                return
            }
            let shotMetricsReceived = jsonObj["_"] as? [[String?]] ?? []
            DispatchQueue.main.async {
                self.shotMetrics = [ShotMetric]()
                for shotMetricEntry in shotMetricsReceived {
                    if shotMetricEntry.count == self.nFields {
                        self.shotMetrics.append(ShotMetric(
                            timeStamp: shotMetricEntry[0],
                            launchAngle: shotMetricEntry[1],
                            launchSpeed: shotMetricEntry[2],
                            hangTime: shotMetricEntry[3],
                            distance: shotMetricEntry[4]))
                    } else {
                        print("get_: Received unexpected number of fields: \(shotMetricEntry.count) instead of \(self.nFields).")
                    }
                }
            }
            success = true
        }.resume()
    }
}
