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
    var body: some View {
        CustomButton(
                    icon: hasOngoingWorkout ? "clock" : "plus",
                    size: .large,
                    matchGeometry: true,
                    namespace: namespace,
                    action: action
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(.trailing, 20)
                .padding(.bottom, 100)
    }
}

