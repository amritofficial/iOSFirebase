//
//  ContactViewController.swift
//  FirebaseChatApp
//
//  Created by Xcode User on 2018-03-30.
//  Copyright © 2018 iOS Project. All rights reserved.
//

import UIKit
import Firebase

var clickedUsername: String = ""
var toId: String = ""

class ContactViewController: UITableViewController {
    
    let cellId = "cellId"
    var userIds: [String] = []
    var users: [String] = []
    
    var usersArray = [User]()
    
    var userEmails: [String] = []
    var profileImageUrls: [String] = []
    var array: [User] = []
    var dict: [String: AnyObject] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUsers()
        CheckUserStatus()
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
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
//        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let user = users[indexPath.row]
        let email = userEmails[indexPath.row]
        let profileImage = profileImageUrls[indexPath.row]
        cell.textLabel?.text = user
        cell.detailTextLabel?.text = email
//
//        cell.imageView?.image = UIImage(named: "default.png")
        print(profileImage)
        let url = URL(string: profileImage)
        let data = try? Data(contentsOf: url!)

        cell.profileImageView.image = UIImage(data: data!)
//        cell.profileImageView.image = UIImage(data: data!)
//        cell.profileImageView.image = UIImage(data: data!)

//        cell.imageView?.image = UIImage(data: data!)
    
    
        
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
                self.userIds.append(snapshot.key)
                print(self.dict["name"])
                self.users.append(self.dict["name"] as! String)
                self.userEmails.append(self.dict["email"] as! String)
                self.profileImageUrls.append(self.dict["profileImage"] as! String)
            }
            
            if let dictionary = snapshot.value as? [String: AnyObject]
            {
                let user = User()
                user.name = dictionary["name"] as? String
                user.email = dictionary["email"] as? String
                user.profileImage = dictionary["profileImage"] as? String
                
                self.usersArray.append(user)
                print("Name is printed below:::::--------->")
                print(user.name, user.email)
            }
            
//            if let test = snapshot.value as? User
//            {
//                self.array.append(test)
//                print("Array Test \(self.array)")
//            }
            
            
            
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
//            if let data = snapshot.value as? [String: AnyObject]
//            {
//                let name = data["name"] as? String
//                let email = data["email"] as? String
//                self.users.append(name!)
//                print(self.users)
//            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("Clicked Username::: \(self.usersArray[indexPath.row].name)")
        clickedUsername = usersArray[indexPath.row].name!
        
        //This profileImageUrl is a global variable that is to pass the profile image url to another class
        profileImageUrl = usersArray[indexPath.row].profileImage!
        toId = userIds[indexPath.row]
        clickedUserId = userIds[indexPath.row]
        performSegue(withIdentifier: "contactChatSegue", sender: self)
    }
}

//class UserCell: UITableViewCell {
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        textLabel?.frame = CGRect(x: 56, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
//        
//        detailTextLabel?.frame = CGRect(x: 56, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
//    }
//    
//    let profileImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.image = UIImage(named:"default.png")
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.layer.cornerRadius = 20
//        imageView.layer.masksToBounds = true
//        return imageView
//    }()
//    
//    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
//        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
//        addSubview(profileImageView)
//        
//        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
//        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
//        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
//        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
//        
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}

