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
    
    @IBOutlet var btnRegister: UIButton!
    @IBOutlet var nameTf: UITextField!
    @IBOutlet var emailTf: UITextField!
    @IBOutlet var passwordTf: UITextField!
    @IBOutlet var registerFormContainer: UIView!
    @IBOutlet var optionSegmentedControl: UISegmentedControl!
    
    @IBOutlet var loginEmailTf: UITextField!
    @IBOutlet var loginPasswordTf: UITextField!
    @IBOutlet var loginFormContainer: UIView!
    
    @IBOutlet var btnLogin: UIButton!
    
    @IBAction func buttonActionRegister(sender: UIButton!)
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
                        
//                        guard let uid = user?.uid else{
//                            return
//                        }
                        
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
    
    @IBAction func segmentDidChange(sender: UISegmentedControl)
    {
        switch optionSegmentedControl.selectedSegmentIndex {
        case 0:
            hideRegisterForm()
            loginFormContainer.isHidden = false
            loginEmailTf.isHidden = false
            loginPasswordTf.isHidden = false
            btnLogin.isHidden = false
        case 1:
            registerFormContainer.isHidden = false
            nameTf.isHidden = false
            passwordTf.isHidden = false
            emailTf.isHidden = false
            btnRegister.isHidden = false
            hideLoginForm()
        default:
            registerFormContainer.isHidden = false
            nameTf.isHidden = false
            passwordTf.isHidden = false
            emailTf.isHidden = false
            btnRegister.isHidden = false
            loginFormContainer.isHidden = true
            loginEmailTf.isHidden = true
            loginPasswordTf.isHidden = true
            btnLogin.isHidden = true
            
        }
    }
    

    @IBAction func unwindToDefaultViewController(sender: UIStoryboardSegue!)
    {
        
    }
    
    
    func hideLoginForm() {
        loginFormContainer.isHidden = true
        loginEmailTf.isHidden = true
        loginPasswordTf.isHidden = true
        btnLogin.isHidden = true
    }
    
    func hideRegisterForm() {
        registerFormContainer.isHidden = true
        nameTf.isHidden = true
        passwordTf.isHidden = true
        emailTf.isHidden = true
        btnRegister.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // The below code would hide the login controls
        hideLoginForm()
        
        var ref: DatabaseReference!
        ref = Database.database().reference()
       
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

