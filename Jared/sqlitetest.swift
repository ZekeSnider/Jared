//
//  sqlitetest.swift
//  JaredUI
//
//  Created by Zeke Snider on 11/9/18.
//  Copyright © 2018 Zeke Snider. All rights reserved.
//

internal let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
internal let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

import Foundation
import SQLite3
import SQLite3
class SqliteTest {
    var db: OpaquePointer?
    var querySinceDate: String?
    
    init() {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("chat.db")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH-mm-ss"
        querySinceDate = formatter.string(from: Date())
    }
    
    deinit {
        if sqlite3_close(db) != SQLITE_OK {
            print("error closing database")
        }
        
        db = nil
    }
    
    func queryNewRecords() -> Double {
        let start = Date()
        
        let query = """
            SELECT handle.id, message.text, datetime('now')
                FROM message INNER JOIN handle
                ON message.handle_id = handle.ROWID
                WHERE is_from_me=0 AND
                datetime(message.date/1000000000 + strftime("%s", "2001-01-01") ,"unixepoch","localtime") >= datetime(?);
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
        }
        
        if sqlite3_bind_text(statement, 1, querySinceDate ?? "2017-11-27 05:05:16", -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding foo: \(errmsg)")
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            guard let idcString = sqlite3_column_text(statement, 0) else {
                break
            }
            let id = String(cString: idcString)
            
            guard let namecString = sqlite3_column_text(statement, 1) else {
                break
            }
            let name = String(cString: namecString)
            
            guard let currentTimeCString = sqlite3_column_text(statement, 2) else {
                break
            }
            
            querySinceDate = String(cString: currentTimeCString)
            
            print("id = \(id)")
            print("name = \(name)")
            print("currentTime = \(String(describing: querySinceDate))")
        }
        
        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }
        
        statement = nil
        
        return NSDate().timeIntervalSince(start)
    }
}
