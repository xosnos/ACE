//
//  ViewController.swift
//  swiftChatter
//
//  Created by Nathan Tsiang on 1/13/22.
//

import UIKit
import Alamofire

final class PostVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    static let shared = PostVC()
    private let serverUrl = "https://34.70.39.80/"
    var jsonObject: [String: String] = [:]
    @IBOutlet weak var SignInOutLabel: UIButton!
    
    @IBAction func SignInOut(_ sender: Any) {
        User.shared.userid = 0
        User.shared.loggedIn = false
    }
    
    @IBOutlet weak var activeClub: UILabel!
    @IBOutlet weak var activeHand: UILabel!
    
    private var videoUrl: URL?
    private var segueChecker = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if User.shared.loggedIn {
            SignInOutLabel.setTitle("Sign Out", for: .normal)
        } else {
            SignInOutLabel.setTitle("Sign In", for: .normal)
        }
        activeHand.text = User.shared.hand
        activeClub.text = User.shared.club
    }
    
    override func viewDidAppear(_ animated: Bool) {
        activeHand.text = User.shared.hand
        activeClub.text = User.shared.club
    }
    @IBAction func pickMedia(_ sender: Any) {
            presentPicker(.photoLibrary)
        }
        
    @IBAction func accessCamera(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            presentPicker(.camera)
        } else {
            print("Camera not available. iPhone simulators don't simulate the camera.")
        }
//        if (segueChecker) {
//            self.performSegue(withIdentifier: "toMetrics", sender: self)
//        }
    }
    
    private func presentPicker(_ sourceType: UIImagePickerController.SourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = sourceType
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.mediaTypes = ["public.movie"]
        imagePickerController.videoMaximumDuration = TimeInterval(30) // secs
        imagePickerController.videoQuality = .typeHigh
        present(imagePickerController, animated: true, completion: nil)
        
    }
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    
    func changePage() {
//        self.performSegue(withIdentifier: "toMetrics", sender: self)
         print("here")
        }
    func postChatt(_ chatt: Chatt) {
        guard let apiUrl = URL(string: serverUrl+"post_shot/") else {
            print("postChatt: Bad URL")
            return
        }
        
        AF.upload(multipartFormData: { mpFD in
            if let userid = chatt.userid?.data(using: .utf8) {
                mpFD.append(userid, withName: "user_id")
            }
            if let hand = chatt.hand?.data(using: .utf8) {
                mpFD.append(hand, withName: "hand")
            }
            if let club = chatt.club?.data(using: .utf8) {
                mpFD.append(club, withName: "club")
            }
            if let urlString = chatt.videoUrl, let videoUrl = URL(string: urlString) {
                mpFD.append(videoUrl, withName: "video", fileName: "chattVideo", mimeType: "video/mp4")
            }
        }, to: apiUrl, method: .post).responseJSON { response in
            switch (response.result) {
            case .success(let value):
                
                print("post return")
                if let jsonObj = value as? [String: String] {
                    User.shared.jsonObject = [
                        "launch_angle": jsonObj["launch_angle"]!,
                        "launch_speed": jsonObj["launch_speed"]!,
                        "hang_time": jsonObj["hang_time"]!,
                        "distance": jsonObj["distance"]!,
                        "club": jsonObj["club"]!]
                }
                self.performSegue(withIdentifier: "toMetrics", sender: self)
                
            case .failure(let error):
                print(error)
                print("post failed")
                self.performSegue(withIdentifier: "toMetrics", sender: self)
            }
        }
        
    }
    @IBOutlet weak var postImage: UIImageView!
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:[UIImagePickerController.InfoKey : Any]) {
        videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL
        let chatt = Chatt(userid: String(User.shared.userid),
                            hand: String(User.shared.hand),
                            club: String(User.shared.club),
                            videoUrl: videoUrl?.absoluteString)
                
        self.postChatt(chatt)
        self.performSegue(withIdentifier: "toCalc", sender: self)
        print("after chatt")
        
        // This is where the URL is stored, we need to send it to the backend
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        segueChecker = false
        picker.dismiss(animated: true, completion: nil)
    }
    
} // class PostVC

