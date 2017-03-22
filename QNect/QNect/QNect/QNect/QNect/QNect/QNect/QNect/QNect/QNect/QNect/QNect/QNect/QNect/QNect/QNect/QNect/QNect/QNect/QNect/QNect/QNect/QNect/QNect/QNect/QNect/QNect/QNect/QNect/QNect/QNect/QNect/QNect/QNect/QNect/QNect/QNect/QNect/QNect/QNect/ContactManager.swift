//
//  ContactManager.swift
//  QNect
//
//  Created by Julian on 11/11/2016
//  Copyright (c) 2016 QNect. All rights reserved.
//

import UIKit
import Foundation
import AddressBook
import Contacts


class ContactManager
{
    var store = CNContactStore()
    
    init()
    {
        if contactStoreStatus() == .denied {
            requestAccessToContacts()
        } else {
        }
    }
    
    func requestAccessToContacts()
    {
        switch CNContactStore.authorizationStatus(for: .contacts){
        case .authorized: break
            
        case .notDetermined:
            store.requestAccess(for: .contacts){succeeded, errror in
                
            }
        default:
            print("Not handled")
        }
    }
    
    func openSettings() {
        let url = URL(string: UIApplicationOpenSettingsURLString)
        UIApplication.shared.openURL(url!)
    }
    
    func addContact(_ connection: User, image: UIImage?, completion:(Bool) -> Void)
    {
        let contact = CNMutableContact()
        contact.givenName = connection.firstName
        contact.familyName = connection.lastName
        
        
        //Phone numbers
        if let phoneNumber = connection.socialPhone {
            let homePhone = CNLabeledValue(label: CNLabelHome,value: CNPhoneNumber(stringValue: phoneNumber))
            contact.phoneNumbers = [homePhone]
        }
        
        
        //Email
        if let email = connection.socialEmail {
            let homeEmail = CNLabeledValue(label: CNLabelHome, value: email as NSString)
            contact.emailAddresses = [homeEmail]
        }
        
        //Social Accounts
        if let twitterScreenName = connection.twitterScreenName {
            let twitterProfile = CNLabeledValue(label: "Twitter", value:
                CNSocialProfile(urlString: nil, username: twitterScreenName,
                                userIdentifier: nil, service: CNSocialProfileServiceTwitter))
            contact.socialProfiles = [twitterProfile]
        }
        
        //Image
        if let image = image {
            let data = UIImagePNGRepresentation(image)
            contact.imageData = data
        }
        
        
        //birthday
//        let birthday = NSDateComponents()
//        birthday.year = 1980
//        birthday.month = 9
//        birthday.day = 27
//        fooBar.birthday = birthday
        
        //Save Contact
        let request = CNSaveRequest()
        request.add(contact, toContainerWithIdentifier: nil)
        do{
            try store.execute(request)
            completion(true)
        } catch {
            completion(false)
        }

    }
 
    
    func contactStoreStatus() -> CNAuthorizationStatus
    {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        
        switch status {
        case .denied, .restricted:
            return .denied
        case .authorized:
            return .authorized
        case .notDetermined:
            return .notDetermined
        }
    }
    
}