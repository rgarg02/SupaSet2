//
//  ModelContext.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/7/24.
//

import SwiftData

extension ModelContext {
    var sqliteCommand: String {
        if let url = container.configurations.first?.url.path(percentEncoded: false) {
            "sqlite3 \"\(url)\""
        } else {
            "No SQLite database found."
        }
    }
}
