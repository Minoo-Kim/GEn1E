//
//  SignUpViewController.swift
//  comm
//
//  Created by Minoo Kim on 11/13/21.
//

import UIKit

class SignUpViewController: UIViewController {
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
    }
    func setUpElements(){
        // Hide error label
        errorLabel.alpha=0;
        
        // Styling elements
        Utilities.styleTextField(firstNameTextField)
        Utilities.styleTextField(lastNameTextField)
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
    }
    

}
