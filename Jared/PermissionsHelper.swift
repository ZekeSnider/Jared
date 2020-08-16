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
    func getContactsStatus() -> CNAuthorizationStatus {
        return CNContactStore.authorizationStatus(for: CNEntityType.contacts)
    }
    
    func requestContactsAccess() {
        // If this is the first run of the application, request access
        // to contacts to pull sender info
        if(CNContactStore.authorizationStatus(for: CNEntityType.contacts) == .notDetermined) {
            CNContactStore().requestAccess(for: CNEntityType.contacts, completionHandler: {_,_ in })
        }
    }
}
