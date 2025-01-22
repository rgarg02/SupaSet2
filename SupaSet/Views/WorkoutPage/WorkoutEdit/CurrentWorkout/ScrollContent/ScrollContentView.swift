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
    @State internal var scrolledExercise: WorkoutExercise.ID?
    @State internal var currentScrollId: UUID?
    @State internal var scrollTimer: Timer?
    @State internal var topRegion: CGRect = .zero
    @State internal var bottomRegion: CGRect = .zero
    @State internal var lastActiveScrollId: UUID?
    @State internal var parentFrame: CGRect = .zero
    @State internal var exerciseFrames: [UUID: CGRect] = [:]
    
    var sortedExercises: [WorkoutExercise] {
        exercises.sorted { $0.order < $1.order }
    }
}
//#Preview {
//    let preview = PreviewContainer.preview
//    let workout = preview.workout
//    ScrollContentView(workout: workout, exercises: .constant(workout.exercises))
//        .modelContainer(preview.container)
//}
