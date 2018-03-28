//
//  ViewController.swift
//  FirebaseChatApp
//
//  Created by Xcode User on 2018-03-27.
//  Copyright © 2018 iOS Project. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    
    @IBOutlet var loginBtn: UIButton!
    @IBOutlet var nameTf: UITextField!
    @IBOutlet var emailTf: UITextField!
    @IBOutlet var passwordTf: UITextField!
    
    @IBAction func buttonAction(sender: UIButton!)
    {
        Auth.auth().fetchProviders(forEmail: emailTf.text!) { (stringArray, error) in
            if error != nil {
                print(error!)
            } else {
                if stringArray == nil {
                    print("No password. No active account")
                    Auth.auth().createUser(withEmail: self.emailTf.text!, password: self.passwordTf.text!) { (user: User?, error) in
                        if error != nil {
                            print(error)
                        }
                        
                        //Saving user information into the database
                        let databaseUrl: String = "https://fir-chatapp-66b77.firebaseio.com/"
                        var ref: DatabaseReference!
                        ref = Database.database().reference(fromURL: databaseUrl)
                        let data = ["name": self.nameTf.text, "email": self.emailTf.text]
                        let userNode = ref.child("users").child((user?.uid)!)
                        userNode.updateChildValues(data) { (err, ref) in
                            if err != nil {
                                print(err)
                            }
                        }
                        
                    }
                } else {
                    print("Account already exists, please try different email")
                }
            }
        }
        
        
        
        print("Hello World")
    }
    
    func fetchProviders(forEmail email: String, completion: ProviderQueryCallback? = nil) {
        
    }

    @IBAction func unwindToDefaultViewController(sender: UIStoryboardSegue!)
    {
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var ref: DatabaseReference!
        ref = Database.database().reference()
       
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

