//
//  AddTemplateCard.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/25/25.
//

import SwiftUI
// Add Template Card View
struct AddTemplateCard: View {
    var body: some View {
        VStack {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 32))
            Text("Create Template")
                .font(.headline)
        }
        .frame(height: 165)
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(Color.theme.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .foregroundStyle(Color.theme.text)
    }
}
