//
//  WorkoutTimeSection.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/21/24.
//
import SwiftUI

// MARK: - WorkoutTimeSection
struct WorkoutTimeSection: View {
    let workout: Workout
    
    private var formattedDate: String {
        Date().formatted(date: .abbreviated, time: .shortened)
    }
    
    var body: some View {
        HStack {
            DateLabel(date: formattedDate)
            Spacer()
            WorkoutTimer(workout: workout)
        }
    }
}
