//
//  ViewController.swift
//  swiftChatter
//
//  Created by Nathan Tsiang on 1/13/22.
//

import UIKit

final class PostVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var SignInOutLabel: UIButton!
    
    @IBAction func SignInOut(_ sender: Any) {
        User.shared.userid = 0
        User.shared.loggedIn = false
    }
    
    
    private var videoUrl: URL?
    private var segueChecker = true
    private var activeHand = "right"
    private var activeClub = "driver"
    override func viewDidLoad() {
        super.viewDidLoad()
        if User.shared.loggedIn {
            SignInOutLabel.setTitle("Sign Out", for: .normal)
        } else {
            SignInOutLabel.setTitle("Sign In", for: .normal)
        }
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
        if (segueChecker) {
            self.performSegue(withIdentifier: "toMetrics", sender: self)
        }
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
    @IBAction func submitChatt(_ sender: Any) {
        let chatt = Chatt(userid: String(User.shared.userid),
                            hand: String(User.shared.hand),
                            club: String(User.shared.club),
                        videoUrl: videoUrl?.absoluteString)
                
        ChattStore.shared.postChatt(chatt)

        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var postImage: UIImageView!
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:[UIImagePickerController.InfoKey : Any]) {
        videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL
        let chatt = Chatt(userid: String(User.shared.userid),
                            hand: String(User.shared.hand),
                            club: String(User.shared.club),
                            videoUrl: videoUrl?.absoluteString)
                
        ChattStore.shared.postChatt(chatt)
        // This is where the URL is stored, we need to send it to the backend
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        segueChecker = false
        picker.dismiss(animated: true, completion: nil)
    }
    
} // class PostVC

