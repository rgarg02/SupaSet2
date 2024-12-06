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
        // Create a label for a date
        Label(date, systemImage: "calendar")
    }
}

// Make a preview for DateLabel
struct DateLabel_Previews: PreviewProvider {
    static var previews: some View {
        DateLabel(date: "Today")
    }
}
