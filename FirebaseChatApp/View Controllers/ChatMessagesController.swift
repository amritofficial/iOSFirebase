//
//  ChatMessagesController.swift
//  FirebaseChatApp
//
//  Created by Xcode User on 2018-04-01.
//  Copyright © 2018 iOS Project. All rights reserved.
//

import UIKit
import Firebase

class ChatMessagesController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout
{
    
    let cellId = "cellId"
    var messages = [MessageModel]()
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
        print(toId)
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
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        let message = messages[indexPath.row]
        cell.textView.text = message.text
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 60)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavbarTitle()
        print(clickedUserId)
        
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        // Do any additional setup after loading the view.
    }
    
    func setUpNavbarTitle() {
        if clickedUsername == "" {
            let ref = Database.database().reference().child("users").child(clickedUserId);
            ref.observeSingleEvent(of: .value, with: {
                (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    print("NNNNN: \(dictionary["name"])")
                    self.navigationItem.title = dictionary["name"] as? String
                    self.getMessageLog()
                }
            }, withCancel: nil)
        }
    }
    
    func getMessageLog() {
        let uid = Auth.auth().currentUser?.uid
        print("GET MESSAGE LOG FUNCTION HAS BEEN EXECUTED!!!")
        let userMessagesRef = Database.database().reference().child("direct-messages").child(uid!)
        
        userMessagesRef.observe(.childAdded, with: {
            (snapshot) in
            
            let messageId = snapshot.key
            let messageRef = Database.database().reference().child("messages").child(messageId)
            messageRef.observeSingleEvent(of: .value, with: {
                (snapshot) in
                
                guard let dict = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                let message = MessageModel()
                message.fromId = dict["fromId"] as? String
                message.text = dict["text"] as? String
                message.timestamp = dict["timestamp"] as? String
                message.toId = dict["toId"] as? String
                
                let chatPartnerId:String?
                
                if message.fromId == Auth.auth().currentUser?.uid {
                    chatPartnerId = message.toId!
                } else {
                    chatPartnerId = message.fromId!
                }
                
                if chatPartnerId == clickedUserId{
                    self.messages.append(message)
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                }
               
                print(message.text)
                
            }, withCancel: nil)
        }, withCancel: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
