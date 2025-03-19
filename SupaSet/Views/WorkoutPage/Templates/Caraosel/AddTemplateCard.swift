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
        VStack(spacing: 16) {
            // Larger plus icon with a subtle gradient
            ZStack {
                Circle()
                    .fill(Color.secondaryTheme)
                    .frame(width: 64, height: 64)
                
                Image(systemName: "plus")
                    .font(.system(size: 40))
                    .foregroundColor(Color.secondaryTheme.bestTextColor())
            }
            
            Text("Create Template")
                .font(.headline)
                .foregroundColor(Color.accent.adjusted(by: 37.5).bestTextColor())
        }
        .frame(height: 165)
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(Color.accent.adjusted(by: 37.5))
        .cornerRadius(12)
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.accent, lineWidth: 2)
        }
    }
}

#Preview {
    VStack{
        AddTemplateCard()
            .padding()
    }
}
