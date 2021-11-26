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

    @IBOutlet weak var tableView: UITableView!
    var numRow: Int = 0
    override func viewDidLoad() {
        // connect to firestore
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
}
extension CheckinViewController: UITableViewDelegate{
    func tableView(_ tableView:UITableView, didSelectRowAt indexPath: IndexPath){
        // select/highlight the row?
        print("you tapped me")
    }
}
extension CheckinViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // find  number of tasks
        var count: Int = 0
        let db = Firestore.firestore()
        db.collection("medical").whereField("nurseUID", isEqualTo: Auth.auth().currentUser!.uid)
            .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            }
            else{
                for _ in querySnapshot!.documents {
                    count+=1
                }
            }
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        return cell
    }
}
