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
    
    var body: some View {
        VStack(spacing: 20) {
            WorkoutNameSection(workout: workout)
                .padding(.horizontal)
            
            WorkoutTimeSection(workout: workout)
                .padding(.horizontal)
        }
    }
}

// MARK: - Preview Provider
struct WorkoutInfoView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleWorkout = Workout(name: "Morning Workout")
        return WorkoutInfoView(workout: sampleWorkout)
            .padding()
    }
}
