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
    private init() {}                // and make the constructor private so no other
                                     // instances can be created
    let propertyNotifier = NotificationCenter.default
    let propertyName = NSNotification.Name("ChattStore")
    var chatts = [Chatt]() {
        didSet {
            propertyNotifier.post(name: propertyName, object: nil)
        }
    }
    private let nFields = Mirror(reflecting: Chatt()).children.count

    private let serverUrl = "https://35.237.18.183/"
    // Once you have your own back-end server set up, you will replace mobapp.eecs.umich.edu with your server’s IP address.

    func postChatt(_ chatt: Chatt, image: UIImage?) {
            guard let apiUrl = URL(string: serverUrl+"postimages/") else {
                print("postChatt: Bad URL")
                return
            }
            
            AF.upload(multipartFormData: { mpFD in
                if let username = chatt.username?.data(using: .utf8) {
                    mpFD.append(username, withName: "username")
                }
                if let message = chatt.message?.data(using: .utf8) {
                    mpFD.append(message, withName: "message")
                }
                if let jpegImage = image?.jpegData(compressionQuality: 1.0) {
                    mpFD.append(jpegImage, withName: "image", fileName: "chattImage", mimeType: "image/jpeg")
                }
                if let urlString = chatt.videoUrl, let videoUrl = URL(string: urlString) {
                    mpFD.append(videoUrl, withName: "video", fileName: "chattVideo", mimeType: "video/mp4")
                }
            }, to: apiUrl, method: .post).response { response in
                switch (response.result) {
                case .success:
                    self.getChatts()
                    print("postChatt: chatt posted!")
                case .failure:
                    print("postChatt: posting failed")
                }
            }
        }

    

    func getChatts() {
        guard let apiUrl = URL(string: serverUrl+"getimages/") else {
            print("getChatts: bad URL")
            return
        }
        
        AF.request(apiUrl, method: .get).responseJSON { response in
            guard let data = response.data, response.error == nil else {
                print("getChatts: NETWORKING ERROR")
                return
            }
            if let httpStatus = response.response, httpStatus.statusCode != 200 {
                print("getChatts: HTTP STATUS: \(httpStatus.statusCode)")
                return
            }
            
            guard let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String:Any] else {
                print("getChatts: failed JSON deserialization")
                return
            }
            let chattsReceived = jsonObj["chatts"] as? [[String?]] ?? []
            self.chatts = [Chatt]()
            for chattEntry in chattsReceived {
                if (chattEntry.count == self.nFields) {
                    self.chatts.append(Chatt(username: chattEntry[0],
                                     message: chattEntry[1],
                                     timestamp: chattEntry[2],
                                     imageUrl: chattEntry[3],
                                     videoUrl: chattEntry[4]))
                } else {
                    print("getChatts: Received unexpected number of fields: \(chattEntry.count) instead of \(self.nFields).")
                }
            }
        }
    }
} // class ChattStore

