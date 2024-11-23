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
            if #available(iOS 18, *) {
                Image(systemName: "arrow.up.arrow.down")
                    .font(.title3)
                    .foregroundStyle(Color.theme.accent)
                    .symbolEffect(.breathe, isActive: reorderExercises)
                    .padding(10)
            }else{
                Image(systemName: "arrow.up.arrow.down")
                    .foregroundStyle(Color.theme.accent)
                    .symbolEffect(.pulse, isActive: reorderExercises)
                    .padding(10)
            }
        }
    }
}

#Preview {
    WorkoutEditOptions(reorderExercises: .constant(false))
}
