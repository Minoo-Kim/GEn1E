//
//  InputViewController.swift
//  Voice
//
//  Created by Minoo Kim on 11/21/21.
//

import UIKit
import Firebase
import FirebaseFirestore

class InputViewController: UIViewController {

    @IBOutlet weak var voiceinput: UIButton!
    @IBOutlet weak var patient: UITextField!
    @IBOutlet weak var medicine: UITextField!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var nurse: UITextField!
    @IBOutlet weak var time: UIDatePicker!
    @IBOutlet weak var done: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    // nurse picker list setup
    var nurseList: Array<String> = []
    var pickerView = UIPickerView()

  
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
        nurse.inputView = pickerView
    }
    
    func validateFields()->String?{
        // Check that all fields are filled in
        if patient.text?.trimmingCharacters(in: .whitespacesAndNewlines)=="" ||
            medicine.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            amount.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            nurse.text == "" {
            // add date and time values
            return "Please fill in all fields."
        }
        return nil
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        // Validate the fields
        let error = validateFields()
        if error != nil {
            showError(message:error!)
        }
        else{
            // Store cleaned versions of the data
            let db = Firestore.firestore()
            let patientText = patient.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let medicineText = medicine.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let amountText = amount.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let nurseText = nurse.text
            // get nurseUID; will give inaccurate info if multiple people with the same first names, but worry about that later
            var nurseUID: String = "placeholder"
            
            // not finding any matching documents here?
            db.collection("users").whereField("firstname", isEqualTo: nurseText)
                .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                }
                else{
                    for document in querySnapshot!.documents {
                        nurseUID =  document["uid"] as! String
                    }
                }
            }
            // Send data to firebase; set doc ID as assigned nurse to easily access from nurse's side of view
            db.collection("medical").document(nurseUID).setData(
                                                            ["patient":patientText,
                                                              "medicine":medicineText,
                                                              "amount": amountText,
                                                              "nurse":nurseText]) {(error) in
                        if error != nil {
                            // Show error message
                            self.showError(message:"Error saving user data")
                        }
                    }
            // Transition to home screen
            self.transitionToHome()
            }
        }
        
    
    func setUpElements(){
        // Hide error label
        errorLabel.alpha=0;
        
        // setup non-picker elements
        Utilities.styleTextField(patient)
        Utilities.styleTextField(medicine)
        Utilities.styleTextField(amount)
        Utilities.styleFilledButton(done)
        
        // set up nurse picker via firestore database
        let db = Firestore.firestore()
        db.collection("users").whereField("Doctor", isEqualTo: false)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                }
                else{
                    for document in querySnapshot!.documents {
                        self.nurseList.append(document["firstname"] as! String)
                    }
                }
        }
        pickerView.delegate = self
        pickerView.dataSource = self
    }
 
    func showError( message:String){
        errorLabel.text=message
        errorLabel.alpha=1
    }
    func transitionToHome(){
        let homeViewController =
        storyboard?.instantiateViewController(withIdentifier:
            Constants.Storyboard.homeViewController) as?
            HomeViewController
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }

}

// for nurse picker
extension InputViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return nurseList.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return nurseList[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        nurse.text=nurseList[row]
        nurse.resignFirstResponder()
    }
}
