//
//  WorkoutInfoView 2.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/21/24.
//

import SwiftUI
// MARK: - WorkoutInfoView
struct WorkoutInfoView: View {
    @Bindable var workout: Workout
    var focused: FocusState<Bool>.Binding
    @Binding var moving: Bool
    var body: some View {
        VStack(spacing: 20) {
            WorkoutNameSection(workout: workout)
                .padding(.horizontal)
            
            WorkoutTimeSection(workout: workout)
                .padding(.horizontal)
            WorkoutNotesSection(workout: workout, moving: moving, focused: focused)
                .padding(.horizontal)
//            HStack{
//                Spacer()
//                WorkoutEditOptions(reorderExercises: $reorderExercises)
//                    .padding(.horizontal)
//            }
        }
        .background(Color.theme.background)
    }
}

// MARK: - Preview Provider
struct WorkoutInfoView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleWorkout = Workout(name: "Morning Workout")
        return WorkoutInfoView(workout: sampleWorkout, focused: FocusState<Bool>().projectedValue, moving: .constant(false))
            .padding()
    }
}
