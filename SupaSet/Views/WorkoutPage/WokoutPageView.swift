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
    @State private var show = false
    @Namespace private var namespace
    @Query(filter: #Predicate<Workout> { !$0.isFinished }) private var ongoingWorkouts: [Workout]
    @Environment(\.modelContext) private var modelContext
    @State private var activityID: String?
    private var hasOngoingWorkout: Bool {
        !ongoingWorkouts.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack{
                    // Create new tempalte button
                    TemplateCarouselView()
                }
                if hasOngoingWorkout {
                    NavigationStack {
                        WorkoutContentView(workout: ongoingWorkouts[0], show: $show)
                    }
                }
                if !hasOngoingWorkout {
                    FloatingActionButton(
                        namespace: namespace,
                        hasOngoingWorkout: hasOngoingWorkout,
                        action: {
                            withAnimation(.spring(duration: 0.5)) {
                                show = true
                                startNewWorkout()
                            }
                        }
                    )
                    .ignoresSafeArea()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                }
            }
            .navigationTitle("Workouts")
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarBackground(.ultraThickMaterial, for: .tabBar)
        }
    }
    
    private func startNewWorkout() {
        let workout = Workout(name: "New Workout")
        modelContext.insert(workout)
        WorkoutActivityManager.shared.startWorkoutActivity(workout: workout)
    }
}

#Preview {
    let container = PreviewContainer.preview
    TabView {
        WorkoutPageView()
            .environment(container.viewModel)
            .modelContainer(container.container)
    }
}

