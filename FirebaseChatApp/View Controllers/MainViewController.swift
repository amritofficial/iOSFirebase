//
//  LoginViewController.swift
//  FirebaseChatApp
//
//  Created by Xcode User on 2018-03-27.
//  Copyright © 2018 iOS Project. All rights reserved.
// The class is a view when the user is able to successfully sign in
// and has logged on to the application

import UIKit
import Firebase

class MainViewController: UIViewController {
    
    @IBOutlet var findContactButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        CheckUserStatus()
        print("CheckUser Status")
    }
    
    
    
    func CheckUserStatus() {
        if Auth.auth().currentUser?.uid == nil {
            logoutUser()
        } else {
            let uid = Auth.auth().currentUser?.uid
            Database.database().reference().child("users").child(uid!).observe(.value, with: { (snapshot) in
                print("UID \(uid)")
                if let data = snapshot.value as? [String: AnyObject] {
                    self.navigationItem.title = data["name"] as? String
                    print(":: \(data["name"])")
                }
            })
        }
    }
    
    
    @IBAction func logoutUserAction() {
        logoutUser()
    }
    
    func logoutUser() {
        do {
          try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
    }


}
