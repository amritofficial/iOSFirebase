//
//  ViewController.swift
//  FirebaseChatApp
//
//  Created by Xcode User on 2018-03-27.
//  Copyright © 2018 iOS Project. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var registerPhoto: UIImageView!
    
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
                    Auth.auth().createUser(withEmail: self.emailTf.text!, password: self.passwordTf.text!) { (user, error) in
                        if error != nil {
                            print(error)
                        }
                        
                        guard let uid = user?.uid else{
                            return
                        }
                    
                        let imageName = NSUUID().uuidString
                        let storageReference = Storage.storage().reference(forURL: "gs://fir-chatapp-66b77.appspot.com/").child("profile_images").child("\(imageName).jpeg")
//                        let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).png")
//                        let uploadData = UIImagePNGRepresentation(self.registerPhoto.image!)
//                        storageRef.putData(uploadData!)
                        
                        var profileImage: String = ""
                        if let uploadData = UIImageJPEGRepresentation(self.registerPhoto.image!, 0)
                        {
                            storageReference.putData(uploadData, metadata: nil, completion:
                                {(metadata, error) in
                                    if(error != nil)
                                    {
                                        print(error)
                                        return
                                    }
                                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                                        
                                        
                                        print("URL::::::: \(profileImageUrl)")
                                        
                                        let databaseUrl: String = "https://fir-chatapp-66b77.firebaseio.com/"
                                        var ref: DatabaseReference!
                                        ref = Database.database().reference(fromURL: databaseUrl)
                                        let data = ["name": self.nameTf.text!, "email": self.emailTf.text, "profileImage": profileImageUrl] as [String : Any]
                                        let userNode = ref.child("users").child((uid))
                                        userNode.updateChildValues(data) { (err, ref) in
                                            if err != nil {
                                                print(err)
                                            }
                                        }
                                    }
                                
                            })
                        }
                        self.signInUserFromRegisterForm()
                        print("URL::! \(profileImage)")
                        
//                        if let uploadImageData = UIImagePNGRepresentation((self.registerPhoto.image)!){
//                            storageRef.putData(uploadImageData, metadata: nil, completion: { (metaData, error) in
//                                storageRef.downloadURL(completion: { (url, error) in
//                                    if let profileImageURL = url?.absoluteString {
//
//                                        let values = ["name": self.nameTf.text!, "email": self.emailTf.text, "profileImage": profileImageURL] as! [String: AnyObject]
//                                        print("URL:::: \(profileImageURL)")
////                                        self.registerUserInDatabase(uid: uid, values: values)
//                                    }
//                                })
//                            })
//                        }
                        
//                        let databaseUrl: String = "https://fir-chatapp-66b77.firebaseio.com/"
//                        var ref: DatabaseReference!
//                        ref = Database.database().reference(fromURL: databaseUrl)
//                        let data = ["name": self.nameTf.text!, "email": self.emailTf.text, "profileImage": profileImage]
//                        let userNode = ref.child("users").child((uid))
//                        userNode.updateChildValues(data) { (err, ref) in
//                            if err != nil {
//                                print(err)
//                            }
//                        }
                    }
                } else {
                    print("Account already exists, please try different email")
                }
            }
        }
        print("Hello World")
    }
    
    
    private func registerUserInDatabase(uid: String, values: [String: AnyObject]){
        //Saving user information into the database
        let databaseUrl: String = "https://fir-chatapp-66b77.firebaseio.com/"
        var ref: DatabaseReference!
        ref = Database.database().reference(fromURL: databaseUrl)
        let userNode = ref.child("users").child((uid))
        userNode.updateChildValues(values) { (err, ref) in
            if err != nil {
                print(err)
            }
            else {
                print("Success!!!!!!")
            }
        }
    }
    
    @IBAction func loginAction(sender: UIButton!) {
        signInUser()
    }
    
    func signInUserFromRegisterForm() {
        Auth.auth().signIn(withEmail: emailTf.text!, password: passwordTf.text!) { (user, error) in
            
            if(error != nil) {
                print(error)
            }
        }
    }
    
    func signInUser() {
        Auth.auth().signIn(withEmail: loginEmailTf.text!, password: loginPasswordTf.text!) { (user, error) in
            
            if(error != nil) {
                print(error)
                let alert = UIAlertController(title: "Warning", message: "Invalid Email or Password", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Retry", style:.default, handler: nil))
                self.present(alert, animated: true)
            } else if (error == nil) {
                self.performSegue(withIdentifier: "viewMainSegue", sender: UIButton.self)
            }
        }
        
        print("Login Form Action")
    }
    
    @IBAction func selectImage(_ sender: UITapGestureRecognizer) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
//        var selectedImageFromPicker: UIImage?
        let selectedPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
        registerPhoto.image = selectedPhoto
        dismiss(animated: true, completion: nil)
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
            registerPhoto.isHidden = false
            loginFormContainer.isHidden = false
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
        registerPhoto.isHidden = true
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

