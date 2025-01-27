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
    @State private var scale: CGFloat = 1.0
    @Namespace private var namespace
    @Query(filter: #Predicate<Workout> { !$0.isFinished }) private var ongoingWorkouts: [Workout]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.alertController) private var alertController
    @State private var activityID: String?
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
                        show: $show,
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
                }else {
                    FloatingActionButton(
                        namespace: namespace,
                        hasOngoingWorkout: hasOngoingWorkout,
                        action: {
                            withAnimation(.spring(duration: 0.5)) {
                                show = true
                                scale = 0.9
                                startNewWorkout()
                            }
                        }
                    )
                    .ignoresSafeArea()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                }
            }
            .animation(.easeInOut, value: show)
        }
    }
    
    private func startNewWorkout() {
        do {
            let workout = Workout(name: "New Workout")
            modelContext.insert(workout)
            try WorkoutActivityManager.shared.startWorkoutActivity(workout: workout)
        } catch {
            alertController.present(title: "Could not start workout", error: error)
        }
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

