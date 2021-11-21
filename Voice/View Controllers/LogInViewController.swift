//
//  LogInViewController.swift
//  comm
//
//  Created by Minoo Kim on 11/13/21.
//

import UIKit
import FirebaseAuth
import  FirebaseFirestore
import grpc

class LogInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        // Validate text fields
        
        // Create cleaned version
        let email =  emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Signing in the user
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
                // Couldn't sign in
                self.errorLabel.text=error!.localizedDescription
                self.errorLabel.alpha=1
            }
            else{
                let db = Firestore.firestore()
                let docRef =  db.collection("users").document("ADzEpZMfCkUGcIVhXEqL")
                docRef.getDocument {(document,error) in
                    if let document = document, document.exists{
                        let val=document.get("Doctor")
                        print(val)
                    }
                    else{
                        print("Document does not exist")
                    }
                }
                // ignore this for now
                let homeViewController =
                self.storyboard?.instantiateViewController(withIdentifier:
                    Constants.Storyboard.homeViewController) as?
                    HomeViewController
                self.view.window?.rootViewController = homeViewController
                self.view.window?.makeKeyAndVisible()
            }
        }
    }
    func setUpElements(){
        // Hide error label
        errorLabel.alpha=0;
        
        // Styling elements
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(loginButton)
    }
    
    
}


//if(position==true){
//    self.transitionToDoctor()
//}
//else{
//    self.transitionToNurse()
//}
