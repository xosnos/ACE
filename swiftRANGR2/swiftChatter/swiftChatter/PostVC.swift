//
//  ViewController.swift
//  swiftChatter
//
//  Created by Nathan Tsiang on 1/13/22.
//

import UIKit

final class PostVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private var videoUrl: URL?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
    }
    
    private func presentPicker(_ sourceType: UIImagePickerController.SourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = sourceType
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.mediaTypes = ["public.movie"]
        imagePickerController.videoMaximumDuration = TimeInterval(5) // secs
        imagePickerController.videoQuality = .typeHigh
        present(imagePickerController, animated: true, completion: nil)
    }
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    @IBAction func submitChatt(_ sender: Any) {
        let chatt = Chatt(username: self.usernameLabel.text,
                                  message: self.messageTextView.text,
                                  imageUrl: nil,
                                  videoUrl: videoUrl?.absoluteString)
                
        ChattStore.shared.postChatt(chatt, image: postImage.image)

        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var postImage: UIImageView!
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:[UIImagePickerController.InfoKey : Any]) {
        videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL
        // This is where the URL is stored, we need to send it to the backend
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
} // class PostVC

