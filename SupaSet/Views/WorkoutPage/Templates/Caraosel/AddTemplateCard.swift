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
                    .fill(Color.accent)
                    .frame(width: 64, height: 64)
                
                Image(systemName: "plus")
                    .font(.system(size: 40))
                    .foregroundColor(Color.accent.bestTextColor())
            }
            
            Text("Create Template")
                .font(.headline)
                .foregroundColor(Color.accent)
        }
        .frame(height: 165)
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(.ultraThickMaterial)
        .foregroundStyle(Color.text)
        .cornerRadius(12)
    }
}

#Preview {
    VStack{
        AddTemplateCard()
            .padding()
    }
}
