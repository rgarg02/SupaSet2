//
//  AddTemplateCard.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/25/25.
//

import SwiftUI
// Add Template Card View
struct AddTemplateButton: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "plus")
                .foregroundStyle(Color.text)
                .font(.caption.bold())
            Text("New Template")
                .font(.caption.bold())
                .foregroundStyle(Color.text)
        }
        .padding(5)
        .background(
            ZStack{
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.text.opacity(0.3), lineWidth: 1)
            }
        )
    }
}

#Preview {
    HStack{
        Text("Templates")
            .font(.title.bold())
        Spacer()
        AddTemplateButton()
    }
    .padding()
}

