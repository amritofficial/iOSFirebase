//
//  ChatMessagesController.swift
//  FirebaseChatApp
//
//  Created by Xcode User on 2018-04-01.
//  Copyright © 2018 iOS Project. All rights reserved.
//

import UIKit
import Firebase

class ChatMessagesController: UICollectionViewController, UITextFieldDelegate {
    
    
    @IBOutlet var messageTextField: UITextField!
    @IBOutlet var btnSendMessage: UIButton!
    
    @IBAction func sendMessage(sender: UIButton!) {
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let fromId = Auth.auth().currentUser?.uid
        let date = Date()
        let timeInterval = date.timeIntervalSince1970
        let timestamp = Int(timeInterval)
        let values = ["text":messageTextField.text!, "toId": toId, "fromId": fromId, "timestamp": timestamp] as [String : Any]
        childRef.updateChildValues(values)
        messageTextField.text = ""
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = clickedUsername
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
