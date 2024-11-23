//
//  EditButton.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/21/24.
//

import SwiftUI

// MARK: - EditButton
struct EditButton: View {
    var isEditing: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: isEditing ? "checkmark.circle.fill" : "pencil.circle")
        }
    }
}
