//
//  QnUtility.swift
//  QNect
//
//  Created by Julian Panucci on 11/6/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import Foundation

import SwiftyJSON
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import Fabric
import TwitterKit
import OAuthSwift

class QnUtility {
    
    static func setUserInfo(userInfo: UserInfo) {
        let ref = FIRDatabase.database().reference()
        let user = FIRAuth.auth()!.currentUser!
        let users = ref.child("users")
        let currentUser = users.child(user.uid)
        
        currentUser.setValue(["username": userInfo.userName, "firstName": userInfo.firstName, "lastName": userInfo.lastName, "email": userInfo.email, "uid":user.uid])
        
        
        let username = ref.child("usernames")
        username.updateChildValues([userInfo.userName!: userInfo.email!])
    }
    
    
    static func setUserInfoFor(user:FIRUser,username:String, firstName:String, lastName:String, socialEmail:String?, socialPhone:String?, twitter:String?)
    {
        
        let ref = FIRDatabase.database().reference()
        let users = ref.child("users")
        let currentUser = users.child(user.uid)
        
        currentUser.setValue(["username":username, "firstName":firstName, "lastName":lastName, "socialEmail":socialEmail,"socialPhone":socialPhone, "email":user.email, "twitterScreenName":twitter, "uid":user.uid])
    }
    
    static func updateUserInfo(firstName:String, lastName:String, socialEmail:String?, socialPhone:String?)
    {
        let user = FIRAuth.auth()!.currentUser!
        let ref = FIRDatabase.database().reference()
        let users = ref.child("users")
        let currentUser = users.child(user.uid)
        
        currentUser.updateChildValues(["firstName":firstName, "lastName":lastName, "socialEmail":socialEmail ?? "","socialPhone":socialPhone ?? ""])
    }
    
    static func updateUserInfo(socialEmail:String?, socialPhone:String?)
    {
        let user = FIRAuth.auth()!.currentUser!
        let ref = FIRDatabase.database().reference()
        let users = ref.child("users")
        let currentUser = users.child(user.uid)
        
        currentUser.updateChildValues(["socialEmail":socialEmail ?? "","socialPhone":socialPhone ?? ""])
    }
    
    
    static func setProfileImage(image:UIImage)
    {
        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsURL.appendingPathComponent("profileImage")
            if let pngImageData = UIImagePNGRepresentation(image) {
                try pngImageData.write(to: fileURL, options: .atomic)
            }
            
            
            
            // Get a reference to the storage service using the default Firebase App
            let storageRef = FIRStorage.storage().reference()
            
            // Create a storage reference from our storage service
            let userStorageRef = storageRef.child("users")
            let userRef = userStorageRef.child((FIRAuth.auth()?.currentUser?.email)!)
            let profileImageRef = userRef.child("profileImage")
            
            
            // Create a reference to the file you want to uplo
            
            // Upload the file to the path "images/rivers.jpg"
            _ = profileImageRef.putFile(fileURL, metadata: nil) { metadata, error in
                if let error = error {
                    print(error)
                } else {
                    // Metadata contains file metadata such as size, content-type, and download URL.
                    _ = metadata!.downloadURL()
                }
            }
        } catch { }
    }
    
    
    static func getProfileImageForUser(user:User, completion:@escaping (UIImage?, Error?) ->Void)
    {
        let storageRef = FIRStorage.storage().reference()
        
        
        let userStorageRef = storageRef.child("users")
        let userRef = userStorageRef.child(user.email).child("profileImage")
        
        
        userRef.data(withMaxSize: 1 * 1024 * 1024) { (data, error) in
            
            if error != nil {
                completion(nil, error)
            }else {
                let image = UIImage(data: data!)
                completion(image, nil)
            }
        }
    }
    
    
    
    static func getProfileImageForCurrentUser() -> UIImage?
    {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let filePath = documentsURL.appendingPathComponent("profileImage").path
        if FileManager.default.fileExists(atPath: filePath) {
            return UIImage(contentsOfFile: filePath)!
        }else {
            return nil
        }
    }
    
    
    static func followUser(user:User)
    { 
        
        
    
    }
    
    static func unfollowUser(connection:User)
    {
        
    }
    
    static func signOut()
    {
        try! FIRAuth.auth()?.signOut()
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent("profileImage")

//        try! FileManager().removeItem(at: fileURL)
        
        
    }
    
    static func doesTwitterUserExistsWith(session:TWTRSession, completion:@escaping (Bool) -> Void)
    {
        
        let ref = FIRDatabase.database().reference()
        

        
        let usersRef = ref.child("users")
        let uidRef = usersRef.child((FIRAuth.auth()?.currentUser?.uid)!)
        let userInfoRef = uidRef.child("userInfo")
        
        userInfoRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if !snapshot.exists() {
                completion(false)
            }else {
            
                let snapshotValue = snapshot.value as! [String: AnyObject]
                let twitterUsername = snapshotValue["twitter"] as? String
                
                if twitterUsername == session.userName {
                    completion(true)
                }else {
                    completion(false)
                }
            }
        })
        
        
    }
    
   
}



