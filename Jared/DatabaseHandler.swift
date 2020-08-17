//
//  DatabaseHandler.swift
//  JaredUI
//
//  Created by Zeke Snider on 11/9/18.
//  Copyright © 2018 Zeke Snider. All rights reserved.
//

internal let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
internal let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

import JaredFramework
import SQLite3

class DatabaseHandler {
    private static let groupQuery = """
		SELECT handle.id, display_name, chat.guid
			FROM chat_handle_join INNER JOIN handle ON chat_handle_join.handle_id = handle.ROWID
			INNER JOIN chat ON chat_handle_join.chat_id = chat.ROWID
			WHERE chat.chat_identifier = ?
	"""
    private static let attachmentQuery = """
	SELECT ROWID,
	filename,
	mime_type,
	transfer_name,
	is_sticker
	FROM attachment
	INNER JOIN message_attachment_join
	ON attachment.ROWID = message_attachment_join.attachment_id
	WHERE message_id = ?
	"""
    private static let newRecordquery = """
		SELECT handle.id, message.text, message.ROWID, message.cache_roomnames, message.is_from_me, message.destination_caller_id,
			message.date/1000000000 + strftime("%s", "2001-01-01"),
			message.cache_has_attachments,
			message.expressive_send_style_id,
			message.associated_message_type,
			message.associated_message_guid, message.guid, destination_caller_id
			FROM message LEFT JOIN handle
			ON message.handle_id = handle.ROWID
			WHERE message.ROWID > ? ORDER BY message.ROWID ASC
	"""
    private static let maxRecordIDQuery = "SELECT MAX(rowID) FROM message"
    
    var db: OpaquePointer?
    var querySinceID: String?
    var shouldExitThread = false
    var refreshSeconds = 5.0
    var statement: OpaquePointer? = nil
    var router: RouterDelegate?
    
    init(router: RouterDelegate, databaseLocation: URL, diskAccessDelegate: DiskAccessDelegate?) {
        self.router = router
        
        if sqlite3_open(databaseLocation.path, &db) != SQLITE_OK {
            NSLog("Error opening SQLite database. Likely Full disk access error.")
            UserDefaults.standard.set(false, forKey: JaredConstants.fullDiskAccess)
            diskAccessDelegate?.displayAccessError()
            return
        }
        UserDefaults.standard.set(true, forKey: JaredConstants.fullDiskAccess)
        
        querySinceID = getCurrentMaxRecordID()
        start()
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
        while shouldExitThread == false {
            let elapsed = queryNewRecords()
            Thread.sleep(forTimeInterval: max(0, refreshSeconds - elapsed))
        }
    }
    
    private func getCurrentMaxRecordID() -> String {
        var id: String?
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, DatabaseHandler.maxRecordIDQuery, -1, &statement, nil) != SQLITE_OK {
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
        
        return id ?? "0"
    }
    
    private func retrieveGroupInfo(chatID: String?) -> Group? {
        guard let chatHandle = chatID else {
            return nil
        }
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, DatabaseHandler.groupQuery, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }
        
        if sqlite3_bind_text(statement, 1, chatID, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding foo: \(errmsg)")
        }
        
        var People = [Person]()
        var groupName: String?
        var chatGUID: String?
        
        while sqlite3_step(statement) == SQLITE_ROW {
            guard let idcString = sqlite3_column_text(statement, 0) else {
                break
            }
            groupName = unwrapStringColumn(for: statement, at: 1)
            chatGUID = unwrapStringColumn(for: statement, at: 2)
            
            let handle = String(cString: idcString)
            let contact = ContactHelper.RetreiveContact(handle: handle)
            
            People.append(Person(givenName: contact?.givenName, handle: handle, isMe: false))
        }
        
        return Group(name: groupName, handle: chatGUID ?? chatHandle, participants: People)
    }
    
    private func unwrapStringColumn(for sqlStatement: OpaquePointer?, at column: Int32) -> String? {
        if let cString = sqlite3_column_text(sqlStatement, column) {
            return String(cString: cString)
        } else {
            return nil
        }
    }
    
    private func retrieveAttachments(forMessage messageID: String) -> [Attachment] {
        var attachmentStatement: OpaquePointer? = nil
        
        defer { attachmentStatement = nil }
        
        if sqlite3_prepare_v2(db, DatabaseHandler.attachmentQuery, -1, &attachmentStatement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }
        
        if sqlite3_bind_text(attachmentStatement, 1, messageID, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding: \(errmsg)")
        }
        
        var attachments = [Attachment]()
        
        while sqlite3_step(attachmentStatement) == SQLITE_ROW {
            guard let rowID = unwrapStringColumn(for: attachmentStatement, at: 0) else { continue }
            guard let fileName = unwrapStringColumn(for: attachmentStatement, at: 1) else { continue }
            guard let mimeType = unwrapStringColumn(for: attachmentStatement, at: 2) else { continue }
            guard let transferName = unwrapStringColumn(for: attachmentStatement, at: 3) else { continue }
            let isSticker = sqlite3_column_int(attachmentStatement, 4) == 1
            
            attachments.append(Attachment(id: Int(rowID)!, filePath: fileName, mimeType: mimeType, fileName: transferName, isSticker: isSticker))
        }
        
        if sqlite3_finalize(attachmentStatement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }
        
        return attachments
    }
    
    private func queryNewRecords() -> Double {
        let start = Date()
        defer { statement = nil }
        
        if sqlite3_prepare_v2(db, DatabaseHandler.newRecordquery, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }
        
        if sqlite3_bind_text(statement, 1, querySinceID ?? "1000000000", -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding: \(errmsg)")
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            var senderHandleOptional = unwrapStringColumn(for: statement, at: 0)
            let textOptional = unwrapStringColumn(for: statement, at: 1)
            let rowID = unwrapStringColumn(for: statement, at: 2)
            let roomName = unwrapStringColumn(for: statement, at: 3)
            let isFromMe = sqlite3_column_int(statement, 4) == 1
            let destinationOptional = unwrapStringColumn(for: statement, at: 5)
            let epochDate = TimeInterval(sqlite3_column_int64(statement, 6))
            let hasAttachment = sqlite3_column_int(statement, 7) == 1
            let sendStyle = unwrapStringColumn(for: statement, at: 8)
            let associatedMessageType = sqlite3_column_int(statement, 9)
            let associatedMessageGUID = unwrapStringColumn(for: statement, at: 10)
            let guid = unwrapStringColumn(for: statement, at: 11)
            let destinationCallerId = unwrapStringColumn(for: statement, at: 12)
            NSLog("Processing \(rowID ?? "unknown")")
            
            querySinceID = rowID;
            
            if (senderHandleOptional == nil && isFromMe == true && roomName != nil) {
                senderHandleOptional = destinationCallerId
            }
            
            guard let senderHandle = senderHandleOptional, let text = textOptional, let destination = destinationOptional else {
                break
            }
            
            let buddyName = ContactHelper.RetreiveContact(handle: senderHandle)?.givenName
            let myName = ContactHelper.RetreiveContact(handle: destination)?.givenName
            let sender: Person
            let recipient: RecipientEntity
            let group = retrieveGroupInfo(chatID: roomName)
            
            if (isFromMe) {
                sender = Person(givenName: myName, handle: destination, isMe: true)
                recipient = group ?? Person(givenName: buddyName, handle: senderHandle, isMe: false)
            } else {
                sender = Person(givenName: buddyName, handle: senderHandle, isMe: false)
                recipient = group ?? Person(givenName: myName, handle: destination, isMe: true)
            }
            
            let message = Message(body: TextBody(text), date: Date(timeIntervalSince1970: epochDate), sender: sender, recipient: recipient, guid: guid, attachments: hasAttachment ? retrieveAttachments(forMessage: rowID ?? "") : [],
                sendStyle: sendStyle, associatedMessageType: Int(associatedMessageType), associatedMessageGUID: associatedMessageGUID)
            
            router?.route(message: message)
        }
        
        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }
        
        return NSDate().timeIntervalSince(start)
    }
}
