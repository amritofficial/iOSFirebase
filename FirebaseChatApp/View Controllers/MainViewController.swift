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

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cellId")
        let cell = myTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let message = messages[indexPath.row]
//        let toId = messageToId[indexPath.row]
//        let timestamps = messageTimeStamps[indexPath.row]
        
        if let toId = message.toId {
            let ref = Database.database().reference().child("users").child(toId)
            ref.observe(.value, with: { (snapshot) in
                
                if let dict = snapshot.value as? [String: AnyObject] {
                    cell.textLabel?.text = dict["name"] as? String
                    if let profileImageUrl = dict["profileImage"] as? String {
                        let url = URL(string: profileImageUrl)
                        let data = try? Data(contentsOf: url!)
                        cell.profileImageView.image = UIImage(data: data!)
                    }
                }
                
               
                
            }, withCancel: nil)
        }
        
//        let ref = Database.database().reference().child("users").child(toId)
//        ref.observeSingleEvent(of: .value, with: {
//            (snapshot) in
//            if let dictionary = snapshot.value as? [String: AnyObject]
//            {
//                if let profileImageUrl = dictionary["profileImage"] as? String {
//
//                    let url = URL(string: profileImageUrl)
//                    let data = try? Data(contentsOf: url!)
//
//                    cell.profileImageView.image = UIImage(data: data!)
//                }
//            }
//        }, withCancel: nil)
        
        
        cell.detailTextLabel?.text = message.text
        
//        cell.timeStamp.text = message.timestamp as! String
        
        if let myInteger = Int(message.timestamp!) {
            let myDate = NSNumber(value:myInteger)
            let seconds = myDate.doubleValue
            let timestampDate = NSDate(timeIntervalSince1970: seconds)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm:ss a"
            cell.timeStamp.text = dateFormatter.string(from: timestampDate as Date)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    @IBOutlet var btnJump: UIButton!
    @IBOutlet var myTableView: UITableView!
    
    let cellId = "cellId"
    
    var url: String = ""
    var userName: String = ""
    var userMessages: [String] = []
    var messageToId: [String] = []
    var messageFromId: [String] = []
    var messageTimeStamps: [String] = []
    var messages =  [MessageModel]()
    @IBOutlet var findContactButton: UIButton!
    
    var array = [Dictionary<String, AnyObject>]()
    var dict: [String: AnyObject] = [:]
    var messageDict = [String: MessageModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CheckUserStatus()
        print("CheckUser Status")
        getMessagesOnMain()
        
        myTableView.register(UserCell.self, forCellReuseIdentifier: cellId)
    }
    
    // This method will bring the users and mesages whom YOU sent messages
    // or vice-versa
    
    func getMessagesOnMain() {
        let ref = Database.database().reference().child("messages")
        ref.observe(.childAdded, with: {
            (snapshot) in
            
            if let dictionary = snapshot.value as? [String: Any] {
                let message = MessageModel()
                message.fromId = dictionary["fromId"] as! String
                message.toId = dictionary["toId"] as! String
                message.text = dictionary["text"] as! String
                message.timestamp = dictionary["timestamp"] as! String
                
//                self.messages.append(message)
                
                if let toId = message.toId {
                    self.messageDict[toId] = message
                    self.messages = Array(self.messageDict.values)
                    
                    // The method below would sort the messages by timestamp but the
                    // timestamp needs to be in number
//                    self.messages.sort(by: { (message1, message2) -> Bool in
//
//                    })
                }
                
                DispatchQueue.main.async {
                    self.myTableView.reloadData()
                }
                
            }
            
            
            if let dictionary = snapshot.value as? Dictionary<String, AnyObject>{
                self.dict = dictionary
                self.userMessages.append(dictionary["text"] as! String)
                self.messageToId.append(dictionary["toId"] as! String)
                self.messageTimeStamps.append(dictionary["timestamp"] as! String)
                print(self.dict["text"])
                
                self.array.append(self.dict)
                
                
//                print(self.array[0]["text"] as Any)
            
//                print(self.messages[0].text)
            }
            

        }, withCancel: nil)
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
                    self.userName = data["name"] as! String
                    self.url = data["profileImage"] as! String
                    print(":: \(data["name"])")
                    self.setNavbar()
                }
            })
        }
    }
    
    func setNavbar() {
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleToFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.layer.masksToBounds = true
        let url = URL(string: self.url)
        let data = try? Data(contentsOf: url!)
        profileImageView.image = UIImage(data: data!)
        
        containerView.addSubview(profileImageView)
        
        profileImageView.leftAnchor.constraint(equalTo: titleView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel = UILabel()
        containerView.addSubview(nameLabel)
        nameLabel.text = self.userName
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: titleView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
        
    }
    
    
    @IBAction func showChatMessagesView(sender: UIButton!) {
        performSegue(withIdentifier: "mainChatSegue", sender: self)
    }
    
    //The method is not being used yet
    @IBAction func showChatMessagesController() {
        let chatMessagesController = ChatMessagesController();
        navigationController?.pushViewController(chatMessagesController, animated: true)
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
