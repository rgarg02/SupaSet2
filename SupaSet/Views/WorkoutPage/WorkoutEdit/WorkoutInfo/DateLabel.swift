//
//  DateLabel.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/21/24.
//

import SwiftUI


// MARK: - DateLabel
struct DateLabel: View {
    let date: String
    
    var body: some View {
        Label(date, systemImage: "calendar")
    }
}
