//
//  FloatingActionButton.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/5/24.
//
import SwiftUI
import SwiftData

struct FloatingActionButton: View {
    let namespace: Namespace.ID
    let hasOngoingWorkout: Bool
    let action: () -> Void
    @Query(filter: #Predicate<Workout> { !$0.isFinished }) private var ongoingWorkouts: [Workout]
    private let buttonSize: CGFloat = 60  // Match the size used in WorkoutStartView
    var body: some View {
        Button(action: action) {
            ZStack {
                Color.blue
                    .matchedGeometryEffect(id: "background", in: namespace)
                
                Image(systemName: hasOngoingWorkout ? "clock" : "plus")
                    .font(.title2)
                    .foregroundColor(.white)
                    .matchedGeometryEffect(id: "icon", in: namespace)
            }
        }
        .frame(width: buttonSize, height: buttonSize)
        .cornerRadius(buttonSize / 2)
    }
}

