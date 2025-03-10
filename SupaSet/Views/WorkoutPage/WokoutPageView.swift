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
    @State private var scale: CGFloat = 1.0
    @Namespace private var namespace
    @Query(filter: #Predicate<Workout> { !$0.isFinished }) private var ongoingWorkouts: [Workout]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.alertController) private var alertController
    @State private var activityID: String?
    @State private var workoutIsFinished: Bool = false
    @State private var workout: Workout?
    private var hasOngoingWorkout: Bool {
        !ongoingWorkouts.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(alignment: .leading){
                    PageTitle(title: "Workouts")
                    TemplateCarouselView()
                }
                .scaleEffect(hasOngoingWorkout ? scale : 1.0)  // Only scale when there's an ongoing workout
                .animation(.spring(), value: scale)
                if hasOngoingWorkout {
                    WorkoutContentView(
                        workout: ongoingWorkouts[0],
                        workoutIsFinished: $workoutIsFinished,
                        onDragProgress: { progress in
                            // Start at 0.9 when at top (progress = 0)
                            // Scale up to 1.0 when dragged down (progress = 1)
                            scale = 0.9 + (progress * 0.1)
                        },
                        onDragEnded: { dismissed in
                            withAnimation(.spring()) {
                                // Reset scale based on whether view is dismissed
                                scale = dismissed ? 1.0 : 0.9
                            }
                        }
                    )
                    .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)))
                    .onAppear{
                        workout = ongoingWorkouts[0]
                    }
                } else {
                    FloatingActionButton(
                        namespace: namespace,
                        hasOngoingWorkout: hasOngoingWorkout,
                        action: {
                            withAnimation(.spring(duration: 0.5)) {
                                scale = 0.9
                                startNewWorkout()
                            }
                        }
                    )
                    .ignoresSafeArea()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                }
            }
            .sheet(isPresented: $workoutIsFinished) {
                if let workout {
                    WorkoutFinishedView(workout: workout)
                }
            }
        }
        .onChange(of: ongoingWorkouts, { oldValue, newValue in
            if let workout = ongoingWorkouts.first {
                do {
                    try WorkoutActivityManager.shared.startWorkoutActivity(workout: workout)
                } catch {
                    alertController.present(error: error)
                }
            }
        })
        .onAppear {
            if let workout = ongoingWorkouts.first {
                do {
                    try WorkoutActivityManager.shared.startWorkoutActivity(workout: workout)
                } catch {
                    alertController.present(error: error)
                }
            }
        }
    }
    
    private func startNewWorkout() {
        let workout = Workout(name: "New Workout")
        modelContext.insert(workout)
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

