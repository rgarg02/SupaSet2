//
//  AddExerciseButton.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/22/25.
//

import SwiftUI

struct AddExerciseButton: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "plus")
                .foregroundColor(.theme.text)
                .font(.title3)
            
            Text("Add Exercises")
                .foregroundColor(.theme.text)
                .font(.title3)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.theme.accent)
        )
    }
}
