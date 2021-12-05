//
//  CheckinViewController.swift
//  Voice
//
//  Created by Minoo Kim on 11/25/21.
//

import UIKit
import Firebase
import FirebaseFirestore

class CheckinViewController: UIViewController {

    @IBOutlet weak var TableView: UITableView!
    var data = [String]()
    // making firstore synchronous basically
    var didFinishLoading = false {
        didSet {
            self.TableView.reloadData()
        }
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // connect to firestore
        getData()
        // setup table
        TableView.delegate = self
        TableView.dataSource = self
        
    }
}
extension CheckinViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView:UITableView, didSelectRowAt indexPath: IndexPath){
        // select/highlight the row?
        print("you tapped me")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return number of tasks for nurse
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CheckInTableViewCell
        cell.TextView.text! = data[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func getData(){
        let db = Firestore.firestore()
        db.collection("medical").whereField("nurseUID", isEqualTo: Auth.auth().currentUser!.uid)
            .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            }
            else{
                for document in querySnapshot!.documents {
                    let amount = document["amount"]  as! String
                    let medicine = document["medicine"]  as! String
                    let patient = document["patient"]  as! String
                    let time = document["time"] as! String
                    let res = "Give " + amount +  " of " + medicine + " to " +  patient + " at " + time
                    if(document["completed"] as! Bool == false){
                        self.data.append(res)
                    }
                }
                self.didFinishLoading = true
            }
        }
    }
}
