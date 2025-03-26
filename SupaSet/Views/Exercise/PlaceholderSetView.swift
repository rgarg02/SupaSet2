//
//  PlaceholderSetView.swift
//  SupaSet
//
//  Created by Rishi Garg on 12/5/24.
//
import SwiftUI

struct PlaceholderSetRowView: View {
    let templateSet: Bool
    let action: () -> Void
    private let columns = [
        GridItem(.fixed(40)), // Set number
        GridItem(.flexible()), // Weight
        GridItem(.flexible()), // Reps
        GridItem(.fixed(80))  // Checkbox
    ]

    
    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 16, weight: .medium))
                
                Text("Add Set")
                    .font(.system(size: 16, weight: .semibold))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                .ultraThinMaterial
            )
            .cornerRadius(8)
            .foregroundColor(Color.text)
        }
    }
}

#Preview("Placeholder Set") {
    VStack(spacing: 16) {
        PlaceholderSetRowView(templateSet: true, action: action)
        PlaceholderSetRowView(templateSet: false, action: action)
        VStack {
            PlaceholderSetRowView(templateSet: true, action: action)
            PlaceholderSetRowView(templateSet: false, action: action)
        }
        .colorScheme(.dark)
    }
    .padding()
}

func action() {
    
}
