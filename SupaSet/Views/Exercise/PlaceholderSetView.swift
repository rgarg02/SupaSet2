//
//  PlaceholderSetView.swift
//  SupaSet
//
//  Created by Rishi Garg on 12/5/24.
//
import SwiftUI

struct PlaceholderSetRowView: View {
    let templateSet: Bool
    private let columns = [
        GridItem(.fixed(40)), // Set number
        GridItem(.flexible()), // Weight
        GridItem(.flexible()), // Reps
        GridItem(.fixed(80))  // Checkbox
    ]

    
    var body: some View {
        LazyVGrid(columns: columns, alignment: .center) {
            // Set Number
            Text("+")
                .font(.headline)
            
            // Weight placeholder
            HStack(spacing: 4) {
                Text("-")
                    .frame(maxWidth: .infinity, alignment: .trailing)
                Text("lbs")
                    .font(.caption)
            }
            
            // Reps placeholder
            HStack(spacing: 4) {
                Text("-")
                    .frame(maxWidth: .infinity, alignment: .trailing)
                Text("reps")
                    .font(.caption)
            }
                // Checkbox placeholder
            Image(systemName: "circle")
                .resizable()
                .frame(width: 24, height: 24)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .opacity(templateSet ? 0 : 1)
        }
        .foregroundStyle(Color.theme.textOpposite)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.theme.accent)
        )
        .disabled(true)
        .opacity(0.8)
    }
}

#Preview("Placeholder Set") {
    VStack(spacing: 16) {
        PlaceholderSetRowView(templateSet: true)
        PlaceholderSetRowView(templateSet: false)
        PlaceholderSetRowView(templateSet: true)

    }
    .padding()
}

