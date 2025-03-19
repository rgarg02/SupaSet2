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
//                    PageTitle(title: "Workouts")
                    TemplateCarouselView()
                }
                .customNavBarTitle("Workouts")
            }
            .background(Color.background)
            .sheet(isPresented: $workoutIsFinished) {
                if let workout {
                    WorkoutFinishedView(workout: workout)
                }
            }
        }
        .background()
    }
    
}

#Preview {
    let container = PreviewContainer.preview
    WorkoutPageView()
        .environment(container.viewModel)
        .modelContainer(container.container)
}
