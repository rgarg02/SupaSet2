//
//  WorkoutEditoptions.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/21/24.
//

import SwiftUI

struct WorkoutEditOptions: View {
    @Binding var reorderExercises: Bool
    // create a view for workout edit options like reorder exercises
    var body: some View {
        // Button for reordering exercises that sets reorderExercises to true
        Button {
            withAnimation(.smooth(duration: 0.5)) {
                reorderExercises.toggle()
            }
        } label: {
            HStack {
                Image(systemName: "arrow.up.arrow.down")
            }
            .padding(10)
            .background(Color.theme.accent)
            .foregroundColor(.theme.background)
            .cornerRadius(10)
        }
    }
}

#Preview {
    WorkoutEditOptions(reorderExercises: .constant(false))
}
