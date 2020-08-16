//
//  PermissionsHelper.swift
//  Jared
//
//  Created by Zeke Snider on 8/16/20.
//  Copyright © 2020 Zeke Snider. All rights reserved.
//

import Foundation
import Contacts

class PermissionsHelper {
    static func getContactsStatus() -> CNAuthorizationStatus {
        let status = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        UserDefaults.standard.set(status.rawValue, forKey: JaredConstants.contactsAccess)
        return status
    }
    
    static func requestContactsAccess() {
        if(CNContactStore.authorizationStatus(for: CNEntityType.contacts) == .notDetermined) {
            CNContactStore().requestAccess(for: CNEntityType.contacts, completionHandler: {enabled, _ in
                getContactsStatus()
            })
        }
    }
}
