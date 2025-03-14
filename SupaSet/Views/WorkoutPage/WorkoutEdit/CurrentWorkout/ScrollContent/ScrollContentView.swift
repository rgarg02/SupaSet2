//
//  ScrollContentView.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/24/24.
//

import SwiftUI
struct ScrollContentView: View {
    @Bindable var workout: Workout
    @Binding var exercises: [WorkoutExercise]
    @State var dragging: Bool = false
    @Binding var show: Bool
    // State properties
    @State internal var selectedExercise: WorkoutExercise?
    @State internal var selectedExerciseScale: CGFloat = 1.0
    @State internal var selectedExerciseFrame: CGRect = .zero
    @State internal var offset: CGSize = .zero
    @State internal var hapticsTrigger: Bool = false
    @State internal var initialScrollOffset: CGRect = .zero
    @State internal var topRegion: CGRect = .zero
    @State internal var bottomRegion: CGRect = .zero
    @State internal var lastActiveScrollId: UUID?
    @State internal var parentFrame: CGRect = .zero
    @State internal var exerciseFrames: [UUID: CGRect] = [:]
    @State internal var scrollPosition: ScrollPosition = .init()
    @State internal var currentScrollOffset: CGFloat = 0
    @State internal var lastActiveScrollOffset: CGFloat = 0
    @StateObject internal var dragState = DragState()
    var sortedExercises: [WorkoutExercise] {
        exercises.sorted { $0.order < $1.order }
    }
    var sortedExercisesBinding: Binding<[WorkoutExercise]> {
        Binding(
            get: {
                exercises.sorted { $0.order < $1.order }
            },
            set: { newSortedExercises in
                // You must decide how to update your original array.
                // For example, if the sorted order represents the new desired order:
                exercises = newSortedExercises
            }
        )
    }
}
//#Preview {
//    let preview = PreviewContainer.preview
//    let workout = preview.workout
//    ScrollContentView(workout: workout, exercises: .constant(workout.exercises))
//        .modelContainer(preview.container)
//}
