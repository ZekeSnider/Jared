//
//  DatabaseTestHelper.swift
//  JaredTests
//
//  Created by Zeke Snider on 8/3/20.
//  Copyright © 2020 Zeke Snider. All rights reserved.
//

import Foundation
import SQLite3

class DatabaseTestHelper {
    let insertHandleQuery = """
        INSERT INTO "handle" ("id", "country", "service", "uncanonicalized_id", "person_centric_id") VALUES (?, 'US', ?, '', '')
"""
    let insertChatQuery = """
INSERT INTO "main"."chat" ("guid", "style", "state", "account_id", "properties", "chat_identifier", "service_name", "room_name", "account_login", "is_archived", "last_addressed_handle", "display_name", "group_id", "is_filtered", "successful_query", "engram_id", "server_change_token", "ck_sync_state", "last_read_message_timestamp", "ck_record_system_property_blob", "original_group_id", "sr_server_change_token", "sr_ck_sync_state", "cloudkit_record_id", "sr_cloudkit_record_id", "last_addressed_sim_id", "is_blackholed") VALUES (?, '45', '3', ?, '696', ?, ?, '', 'E:email@domain.com', '0', 'email@domain.com', '', '3E', '0', '1', '', '23', '1', '539378313766385344', '', '3E', '', '0', 'fa', '', '', '0');
"""
    let insertChatHandleJoin = """
    INSERT INTO "main"."chat_handle_join" ("chat_id", "handle_id") VALUES (?, ?);
"""
    let insertMessageQuery = """
INSERT INTO message ("guid", "text", "handle_id", "service", "account", "account_guid", "date", "date_read", "date_delivered", "is_from_me", "cache_has_attachments", "cache_roomnames", "associated_message_guid", "associated_message_type", "expressive_send_style_id", "destination_caller_id") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
"""
    
    let insertChatMessageJoin = """
INSERT INTO "main"."chat_message_join" ("chat_id", "message_id", "message_date") VALUES (?, ?, ?);
"""


    
    let insertMessageAttachmentJoin = """
    INSERT INTO message_attachment_join ("message_id", "attachment_id") VALUES (?, ?);
"""
    
    var db: OpaquePointer?
    
    init(databaseLocation: URL) {
        if sqlite3_open(databaseLocation.path, &db) != SQLITE_OK {
            print("Error opening test database")
        }
    }
    
    deinit {
        if sqlite3_close(db) != SQLITE_OK {
            print("error closing database")
        }
        
        db = nil
    }
    
    func insertHandle(id: String, service: String) -> Int {
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertHandleQuery, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }
        
        if sqlite3_bind_text(statement, 1, id, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding foo: \(errmsg)")
        }
        if sqlite3_bind_text(statement, 2, service, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding foo: \(errmsg)")
        }
        
        if sqlite3_step(statement) == SQLITE_DONE {
            print("Successfully inserted row.")
            
        }
        
        return Int(sqlite3_last_insert_rowid(db))
    }
    
    func insertChat(accountId: String, service: String, roomName: String = "") -> Int {
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertChatQuery, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }
        
        let guid = "\(service);-;\(UUID().uuidString)"
        if sqlite3_bind_text(statement, 1, guid, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding foo: \(errmsg)")
        }
        if sqlite3_bind_text(statement, 2, accountId, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding foo: \(errmsg)")
        }
        if sqlite3_bind_text(statement, 3, service, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding foo: \(errmsg)")
        }
        if sqlite3_bind_text(statement, 4, roomName, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding foo: \(errmsg)")
        }
        
        if sqlite3_step(statement) == SQLITE_DONE {
            print("Successfully inserted row.")
        }
        
        return Int(sqlite3_last_insert_rowid(db))
    }
    
    func linkChatAndHandle(chatID: Int, handleID: Int) -> Void {
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertChatHandleJoin, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }
        
        if sqlite3_bind_int(statement, 1, Int32(chatID)) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding foo: \(errmsg)")
        }
        if sqlite3_bind_int(statement, 2, Int32(handleID)) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding foo: \(errmsg)")
        }
        
        if sqlite3_step(statement) == SQLITE_DONE {
            print("Successfully inserted row.")
        }
    }
    
    func insertMessage(guid: String, messageText: String, handleID: Int, service: String, account: String, accountGuid: String, date: Int?, dateRead: Int?, dateDelivered: Int?, isFromMe: Bool, hasAttachments: Bool, destinationCallerID: String, roomNames: String? = nil, associatedMessageGUID: String? = nil, sendStyleId: String? = nil, associatedMessageType: Int? = nil) -> Int {
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertMessageQuery, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }
        
        if sqlite3_bind_text(statement, 1, guid, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding foo: \(errmsg)")
        }
        if sqlite3_bind_text(statement, 2, messageText, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding foo: \(errmsg)")
        }
        if sqlite3_bind_int(statement, 3, Int32(handleID)) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding foo: \(errmsg)")
        }
        if sqlite3_bind_text(statement, 4, service, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding foo: \(errmsg)")
        }
        if sqlite3_bind_text(statement, 5, account, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding foo: \(errmsg)")
        }
        if sqlite3_bind_text(statement, 6, accountGuid, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding foo: \(errmsg)")
        }
        if sqlite3_bind_int64(statement, 7, Int64(date ?? 0)) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding foo: \(errmsg)")
        }
        if sqlite3_bind_int64(statement, 8, Int64(dateRead ?? 0)) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding foo: \(errmsg)")
        }
        if sqlite3_bind_int64(statement, 9, Int64(dateDelivered ?? 0)) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding foo: \(errmsg)")
        }
        if sqlite3_bind_int(statement, 10, Int32(isFromMe ? 1 : 0)) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding foo: \(errmsg)")
        }
        if sqlite3_bind_int(statement, 11, Int32(hasAttachments ? 1 : 0)) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding foo: \(errmsg)")
        }
        if sqlite3_bind_text(statement, 12, roomNames ?? "", -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding foo: \(errmsg)")
        }
        if sqlite3_bind_text(statement, 13, associatedMessageGUID, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding foo: \(errmsg)")
        }
        if sqlite3_bind_int(statement, 14, Int32(associatedMessageType ?? 0)) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding foo: \(errmsg)")
        }
        if sqlite3_bind_text(statement, 15, sendStyleId, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding foo: \(errmsg)")
        }
        if sqlite3_bind_text(statement, 16, destinationCallerID, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding foo: \(errmsg)")
        }
        
        let result = sqlite3_step(statement)
        print(String(cString: sqlite3_errmsg(db)!))
        if result == SQLITE_DONE {
            print("Successfully inserted row.")
        }
        
        return Int(sqlite3_last_insert_rowid(db))
    }
    
    func linkChatAndMessage(chatID: Int, messageID: Int, date: Int) {
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertChatMessageJoin, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }
        
        if sqlite3_bind_int(statement, 1, Int32(chatID)) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding foo: \(errmsg)")
        }
        if sqlite3_bind_int(statement, 2, Int32(messageID)) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding foo: \(errmsg)")
        }
        if sqlite3_bind_int64(statement, 3, Int64(date)) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding foo: \(errmsg)")
        }
        
        if sqlite3_step(statement) == SQLITE_DONE {
            print("Successfully inserted row.")
        }
    }
    
    let insertAttachmentQuery = """
        INSERT INTO "attachment" ("guid", "created_date", "filename", "mime_type", "is_outgoing", "transfer_name", "is_sticker") VALUES (?, ?, ?, ?, ?, ?, ?);
    """
    func insertAttachment(guid: String, createdAt: Int, filePath: String, mimeType: String, isOutgoing: Bool, transferName: String, isSticker: Bool) -> Int {
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertAttachmentQuery, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }
        
        if sqlite3_bind_text(statement, 1, guid, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding foo: \(errmsg)")
        }
        if sqlite3_bind_int64(statement, 2, Int64(createdAt)) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding foo: \(errmsg)")
        }
        if sqlite3_bind_text(statement, 3, filePath, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding foo: \(errmsg)")
        }
        if sqlite3_bind_text(statement, 4, mimeType, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding foo: \(errmsg)")
        }
        if sqlite3_bind_int(statement, 5, isOutgoing ? 1 : 0) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding foo: \(errmsg)")
        }
        if sqlite3_bind_text(statement, 6, transferName, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding foo: \(errmsg)")
        }
        if sqlite3_bind_int(statement, 7, isSticker ? 1 : 0) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding foo: \(errmsg)")
        }
        
        if sqlite3_step(statement) == SQLITE_DONE {
            print("Successfully inserted row.")
        }
        
        return Int(sqlite3_last_insert_rowid(db))
    }
    
    func linkAttachmentAndMessage(messageID: Int, attachmentID: Int) {
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertMessageAttachmentJoin, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }
        
        if sqlite3_bind_int(statement, 1, Int32(messageID)) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding foo: \(errmsg)")
        }
        if sqlite3_bind_int(statement, 2, Int32(attachmentID)) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding foo: \(errmsg)")
        }
        
        let result = sqlite3_step(statement)
        print(String(cString: sqlite3_errmsg(db)!))
        if result == SQLITE_DONE {
            print("Successfully inserted row.")
        }
    }
}
