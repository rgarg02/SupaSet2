//
//  ProgressDotsWorkout.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/12/24.
//

import SwiftUI

struct ProgressDot: View {
    let isActive: Bool
    
    var body: some View {
        Circle()
            .fill(isActive ? Color.theme.accent : Color.gray.opacity(0.3))
            .frame(width: 8, height: 8)
    }
}

struct WorkoutProgressDots: View {
    let totalExercises: Int
    let currentExerciseIndex: Int
    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<totalExercises, id: \.self) { index in
                ProgressDot(isActive: index == currentExerciseIndex )
            }
        }
        .padding(.vertical, 20)
    }
}

#Preview {
    WorkoutProgressDots(totalExercises: 10, currentExerciseIndex: 2)
}
