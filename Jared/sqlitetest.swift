//
//  sqlitetest.swift
//  JaredUI
//
//  Created by Zeke Snider on 11/9/18.
//  Copyright © 2018 Zeke Snider. All rights reserved.
//

import Foundation
import SQLite3
import SQLite3
class SqliteTest {
    static func test() {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("test.sqlite")
        
        var db: OpaquePointer?
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        if sqlite3_exec(db, "create table if not exists test (id integer primary key autoincrement, name text)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
    }
}
