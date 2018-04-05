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
        let timeStampString = String(timestamp)
        let values = ["text":messageTextField.text!, "toId": toId, "fromId": fromId, "timestamp": timeStampString]
        
        //The code below would update all the values into the database for the mesasges
//        childRef.updateChildValues(values)
        
        childRef.updateChildValues(values) {
            (error, ref) in
            
            if error != nil {
                print(error)
            }
            
            let directMessageRef = Database.database().reference().child("direct-messages").child(fromId!)
            
            let messageId = childRef.key
            directMessageRef.updateChildValues([messageId: 1])
            
            let recipientMessageRef = Database.database().reference().child("direct-messages").child(toId)
            recipientMessageRef.updateChildValues([messageId: 1])
            
        }
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
