//
//  LoginVC.swift
//  swiftChatter
//
//  Created by Steven Nguyen on 4/10/22.
//

import Foundation
import UIKit

class LoginVC : UIViewController {
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func onLogin(_ sender: Any) {
        let username = usernameField.text
        let password = passwordField.text
        if username != "" && password != "" {
            User.shared.login(username!, password!) { success in
                DispatchQueue.main.async {
                    if success {
                        self.performSegue(withIdentifier: "loginSegue", sender: nil)
                    }
                }
            }
        } else {
            print("Error: Username or password not filled in")
        }
    }
    
    @IBAction func onRegister(_ sender: Any) {
        let username = usernameField.text
        let password = passwordField.text
        if username != "" && password != "" {
            User.shared.create(username!, password!)
            onLogin(self)
        } else {
            print("Error: Username or password not filled in")
        }
    }
}
