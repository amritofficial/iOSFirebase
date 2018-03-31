//
//  ContactViewController.swift
//  FirebaseChatApp
//
//  Created by Xcode User on 2018-03-30.
//  Copyright © 2018 iOS Project. All rights reserved.
//

import UIKit
import Firebase

class ContactViewController: UITableViewController {
    
    let cellId = "cellId"
    var users: [String] = []
    var userEmails: [String] = []
    var array: [User] = []
    var dict: [String: AnyObject] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUsers()
        CheckUserStatus()
    }
    
    func CheckUserStatus() {
        if Auth.auth().currentUser?.uid == nil {
            
        } else {
            let uid = Auth.auth().currentUser?.uid
            Database.database().reference().child("users").child(uid!).observe(.value, with: { (snapshot) in
                
                if let data = snapshot.value as? [String: AnyObject] {
                    self.navigationItem.title = data["name"] as? String
                    print(":: \(data["name"])")
                }
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        
        let user = users[indexPath.row]
        let email = userEmails[indexPath.row]
        cell.textLabel?.text = user
        cell.detailTextLabel?.text = email
        return cell
    }
    
    func getUsers() {
        Database.database().reference().child("users").observe(.childAdded) { (snapshot) in
            
//            if let data = snapshot.value as? Dictionary<String, AnyObject>
//            {
//
//            }
            
            if let data = snapshot.value as? Dictionary<String, AnyObject>
            {
                self.dict = data
                
                print(self.dict["name"])
                self.users.append(self.dict["name"] as! String)
                self.userEmails.append(self.dict["email"] as! String)
            }
            
//            if let test = snapshot.value as? User
//            {
//                self.array.append(test)
//                print("Array Test \(self.array)")
//            }
            
            
            
           
            self.tableView.reloadData()
//            if let data = snapshot.value as? [String: AnyObject]
//            {
//                let name = data["name"] as? String
//                let email = data["email"] as? String
//                self.users.append(name!)
//                print(self.users)
//            }
        }
    }


}
