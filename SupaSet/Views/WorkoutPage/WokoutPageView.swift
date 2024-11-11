//
//  WokoutPageView.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/5/24.
//

import SwiftUI
import SwiftData
import ActivityKit
struct WorkoutPageView: View {
    @State private var isExpanded = false
    @Namespace private var namespace
    @Query(filter: #Predicate<Workout> { !$0.isFinished }) private var ongoingWorkouts: [Workout]
    @Environment(\.modelContext) private var modelContext
    @State private var activityID: String?
    private var hasOngoingWorkout: Bool {
        !ongoingWorkouts.isEmpty
    }
    
    var body: some View {
        ZStack {
            if isExpanded && hasOngoingWorkout {
                WorkoutStartView(
                    namespace: namespace,
                    isExpanded: $isExpanded,
                    workout: ongoingWorkouts[0]
                )
                .ignoresSafeArea()
            }
            
            if !isExpanded {
                FloatingActionButton(
                    namespace: namespace,
                    hasOngoingWorkout: hasOngoingWorkout,
                    action: {
                        withAnimation(.spring(duration: 0.5)) {
                            if hasOngoingWorkout {
                                isExpanded = true
                            } else {
                                startNewWorkout()
                            }
                        }
                    }
                )
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }
        }
    }
    
    private func startNewWorkout() {
        let workout = Workout(name: "New Workout")
        modelContext.insert(workout)
        isExpanded = true
    }
}

#Preview {
    let container = PreviewContainer.preview
    WorkoutPageView()
        .environment(container.viewModel)
        .modelContainer(container.container)
}

