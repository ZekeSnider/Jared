//
//  sqlitetest.swift
//  JaredUI
//
//  Created by Zeke Snider on 11/9/18.
//  Copyright © 2018 Zeke Snider. All rights reserved.
//

internal let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
internal let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

import Cocoa
import JaredFramework
import Foundation
import SQLite3
import Contacts
class DatabaseHandler {
    var db: OpaquePointer?
    var querySinceID: String?
    var shouldExitThread = false
    var refreshSeconds = 5.0
    var authorizationError = false
    
    init() {
        let databaseLocation = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0].appendingPathComponent("Messages").appendingPathComponent("chat.db")
        
        if sqlite3_open(databaseLocation.path, &db) != SQLITE_OK {
            NSLog("Error opening SQLite database. Likely Full disk access error.")
            let viewController = NSApplication.shared.keyWindow!.contentViewController as! ViewController
            viewController.displayAccessError()
            authorizationError = true
            return
        }
        
        querySinceID = getCurrentMaxRecordID()
    }
    
    
    deinit {
        shouldExitThread = true
        if sqlite3_close(db) != SQLITE_OK {
            print("error closing database")
        }
        
        db = nil
    }
    
    func start() {
        let dispatchQueue = DispatchQueue(label: "Jared Background Thread", qos: .background)
        dispatchQueue.async(execute: self.backgroundAction)
    }
    
    private func backgroundAction() {
        let elapsed = queryNewRecords()
        
        guard (!shouldExitThread) else { return }
        
        if (elapsed < refreshSeconds) {
            Thread.sleep(forTimeInterval: refreshSeconds - elapsed)
        }
        
        backgroundAction()
    }
    
    private func getCurrentMaxRecordID() -> String {
        let query = "SELECT MAX(rowID) FROM message"
        var id: String?
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            guard let idcString = sqlite3_column_text(statement, 0) else {
                break
            }
            
            id = String(cString: idcString)
        }
        
        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }
        
        return id ?? "10000000000000"
    }
    
    private func queryNewRecords() -> Double {
        let start = Date()
        
        let query = """
            SELECT handle.id, message.text, message.ROWID, cache_roomnames, is_from_me, destination_caller_id
                FROM message INNER JOIN handle
                ON message.handle_id = handle.ROWID
                WHERE = message.ROWID > ?
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }
        
        if sqlite3_bind_text(statement, 1, querySinceID ?? "1000000000", -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding foo: \(errmsg)")
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            guard let idcString = sqlite3_column_text(statement, 0) else {
                break
            }
            let id = String(cString: idcString)
            
            guard let textcString = sqlite3_column_text(statement, 1) else {
                break
            }
            let text = String(cString: textcString)
            
            guard let rowIDcString = sqlite3_column_text(statement, 2) else {
                break
            }
            let rowID = String(cString: rowIDcString)
            
            var roomName: String? = nil
            if let roomNamecString = sqlite3_column_text(statement, 3) {
                roomName = String(cString: roomNamecString)
            }
            
            let isFromMe = sqlite3_column_int(statement, 4) == 1

            guard let destinationCString = sqlite3_column_text(statement, 5) else {
                break
            }
            let destination = String(cString: destinationCString)
            
            querySinceID = rowID;
            
            print("id = \(id)")
            print("text = \(text)")
            print("roomName = \(roomName ?? "none")")
            
            var buddyName: String?
            if (CNContactStore.authorizationStatus(for: CNEntityType.contacts) == .authorized) {
                let store = CNContactStore()
                
                let searchPredicate: NSPredicate
                
                if (!id.contains("@")) {
                    searchPredicate = CNContact.predicateForContacts(matching: CNPhoneNumber(stringValue: id))
                } else {
                    searchPredicate = CNContact.predicateForContacts(matchingEmailAddress: id)
                }
                
                let contacts = try! store.unifiedContacts(matching: searchPredicate, keysToFetch:[CNContactFamilyNameKey as CNKeyDescriptor, CNContactGivenNameKey as CNKeyDescriptor])
                print(contacts.count)
                
                if (contacts.count == 1) {
                    buddyName = contacts[0].givenName
                }
            }
            
            if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
                
                let sender: Person
                let recipient: RecipientEntity
                
                if (isFromMe) {
                    sender = Person(givenName: buddyName, handle: id, isMe: true, inGroup: nil)
                    recipient = Person(givenName: "me", handle: destination, isMe: false, inGroup: nil)
                } else {
                    sender = Person(givenName: buddyName, handle: id, isMe: false, inGroup: nil)
                    recipient = Person(givenName: "me", handle: destination, isMe: true, inGroup: nil)
                }
                
                let message = Message(body: TextBody(text), date: Date(), sender: sender, recipient: recipient)
                
                appDelegate.Router.route(message: message)
            }
        }
        
        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }
        
        statement = nil
        
        return NSDate().timeIntervalSince(start)
    }
}
