//
//  ChatMessagesController.swift
//  FirebaseChatApp
//
//  Created by Xcode User on 2018-04-01.
//  Copyright © 2018 iOS Project. All rights reserved.
//

import UIKit
import Firebase

var profileImageUrl: String?
class ChatMessagesController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout
{
    
    
    let cellId = "cellId"
    var messages = [MessageModel]()
    
    @IBOutlet var activity: UIActivityIndicatorView!
    @IBOutlet var messageTextField: UITextField!
    @IBOutlet var btnSendMessage: UIButton!
    
    @IBAction func sendMessage(sender: UIButton!) {
        let ref = Database.database().reference().child("messages")
        ref.keepSynced(true)
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
        
        print("profileImageURL::: \(profileImageUrl)")
//        let profileImageUrl =
        let url = URL(string: profileImageUrl!)
        let data = try? Data(contentsOf: url!)
        cell.profileImageView.image = UIImage(data: data!)
        
        
        // The code below would set up the message bubbles depending upon the sender/receiver
        // they will be gray and blue depending upon the same
        if message.fromId == Auth.auth().currentUser?.uid {
            //Make a blue bubble
            cell.bubbleView.backgroundColor = UIColor.init(red: 53.0/255, green: 187/255, blue: 255/255, alpha: 1.0)
            cell.textView.textColor = UIColor.white
            cell.profileImageView.isHidden = true
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
        } else {
            //Make a grey bubble
            cell.bubbleView.backgroundColor = UIColor.init(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
            cell.textView.textColor = UIColor.black
            cell.profileImageView.isHidden = false
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
        
        cell.bubbleViewWidth?.constant = calculateFrameForText(text: message.text!).width + 32
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 60
        
        if let text = messages[indexPath.row].text {
            height = calculateFrameForText(text: text).height + 20
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    private func calculateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        activity.isHidden = false
        activity.startAnimating()
        setUpNavbarTitle()
        print("Clicked UserID from Chat Log Controller ::: \(clickedUserId)")
        
        collectionView?.contentInset = UIEdgeInsetsMake(8, 0, 58, 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(8, 0, 58, 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        // Do any additional setup after loading the view.
    }
    
    func setUpNavbarTitle() {
        if clickedUsername == "" {
            let ref = Database.database().reference().child("users").child(clickedUserId);
            ref.keepSynced(true)
            ref.observeSingleEvent(of: .value, with: {
                (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    print("NNNNN: \(dictionary["name"])")
                    self.navigationItem.title = dictionary["name"] as? String
                    profileImageUrl = dictionary["profileImage"] as? String
                    self.getMessageLog()
                }
            }, withCancel: nil)
        } else {
            self.navigationItem.title = clickedUsername as? String
            self.getMessageLog()
        }
    }
    
    func getMessageLog() {
        let uid = Auth.auth().currentUser?.uid
        print("GET MESSAGE LOG FUNCTION HAS BEEN EXECUTED!!!")
        let userMessagesRef = Database.database().reference().child("direct-messages").child(uid!)
        userMessagesRef.keepSynced(true)
        userMessagesRef.observe(.childAdded, with: {
            (snapshot) in
            
            let messageId = snapshot.key
            let messageRef = Database.database().reference().child("messages").child(messageId)
            messageRef.keepSynced(true)
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
               
                self.activity.stopAnimating()
                self.activity.isHidden = true
                print(message.text)
                
            }, withCancel: nil)
        }, withCancel: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
