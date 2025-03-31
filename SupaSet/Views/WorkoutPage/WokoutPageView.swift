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
        NavigationView {
            VStack{
//                CustomNavBarTitle(title: "Workouts")
                TemplateCarouselView()
            }
            .navigationTitle("Workouts")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $workoutIsFinished) {
                if let workout {
                    WorkoutFinishedView(workout: workout)
                }
            }
        }
    }
    
}

#Preview {
    let container = PreviewContainer.preview
    WorkoutPageView()
        .environment(container.viewModel)
        .modelContainer(container.container)
}
