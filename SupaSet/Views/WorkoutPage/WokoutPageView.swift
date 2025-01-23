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
    @Environment(\.alertController) private var alertController
    @State private var activityID: String?
    private var hasOngoingWorkout: Bool {
        !ongoingWorkouts.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(alignment: .leading){
                    Text("Workouts")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
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
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarBackground(.ultraThickMaterial, for: .tabBar)
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

