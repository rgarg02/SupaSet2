//
//  WorkoutStartView.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/5/24.
//

import SwiftUI
import SwiftData

/// A view that displays the workout start interface with smooth transition animations and drag-to-dismiss functionality.
///
/// This view implements a custom transition between an expanded workout view and a compact button state,
/// using matched geometry effects and drag gestures for interactive dismissal.
///
/// ## Usage Example:
/// ```swift
/// @Namespace var namespace
/// @State var isExpanded = true
/// let workout = Workout(name: "New Workout", isFinished: false)
///
/// WorkoutStartView(
///     namespace: namespace,
///     isExpanded: $isExpanded,
///     workout: workout
/// )
/// ```
struct WorkoutStartView: View {
    /// The namespace used for matched geometry effects during view transitions.
    let namespace: Namespace.ID
    
    /// Controls whether the view is in its expanded state.
    @Binding var isExpanded: Bool
    
    /// Tracks the vertical offset during drag gestures.
    @State var offsetY: CGFloat = 0
    
    /// The workout model object being displayed and modified.
    @Bindable var workout: Workout
    
    /// View model providing exercise-related functionality.
    @Environment(ExerciseViewModel.self) var exerciseViewModel
    
    // MARK: - Private Properties
    
    /// The threshold distance for dismissing the view when dragged.
    private let dismissThreshold: CGFloat = 100
    
    /// The maximum distance the view can be dragged.
    private let maxDragDistance: CGFloat = 300
    
    /// Controls the visibility of the exercise picker overlay
    @State private var showExercisePicker = false
    
    /// The size of the compact button state.
    private let buttonSize: CGFloat = 60
    
    @FocusState var focused: Bool
    /// The main view body implementing the interactive workout interface.
    ///
    /// This view uses GeometryReader to create smooth transitions between states and
    /// implements custom animations for the view's position, size, and appearance.
    var body: some View {
        GeometryReader { geometry in
            let progress = min(max(offsetY / maxDragDistance, 0), 1)
            let width = geometry.size.width * (1 - progress) + buttonSize * progress
            let height = geometry.size.height * (1 - progress) + buttonSize * progress
            
            // Position calculations for view transitions
            let startX = geometry.size.width / 2
            let startY = geometry.size.height / 2
            let endX = geometry.size.width - (buttonSize / 2) - 20
            let endY = geometry.size.height - (buttonSize / 2) - 100
            
            let currentX = startX + (endX - startX) * progress
            let currentY = startY + (endY - startY) * progress
            NavigationView{
                ZStack {
                    Color.theme.background
                        .matchedGeometryEffect(id: "background", in: namespace)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        VStack {
                            RoundedRectangle(cornerRadius: 2.5)
                                .fill(.gray)
                                .frame(width: 40, height: 5)
                                .opacity(1 - progress)
                            
                            Text("Current Workout")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.theme.text)
                            Spacer()
                            ScrollView{
                                ForEach(workout.exercises, id: \.self) { exercise in
                                    ExerciseCardView(workoutExercise: exercise
                                                     , focused: $focused)
                                        .frame(height: 500)
                                }
                            }
                            CustomButton(
                                icon: "plus.circle",
                                title: "Add Exercises",
                                style: .filled(),
                                action: {
                                    withAnimation{
                                        showExercisePicker = true
                                    }
                                }
                            )
                        }
                        .padding()
                    }
                    .opacity(1 - progress)
                }
                .matchedGeometryEffect(id: "icon", in: namespace)
                .frame(width: width, height: height)
                .cornerRadius(progress * 30)
                .position(x: currentX, y: currentY)
                .gesture(
                    DragGesture()
                        .onChanged(dragChanged)
                        .onEnded(dragEnded)
                )
                .opacity(showExercisePicker ? 0.5 : 1)
                .overlay {
                    if showExercisePicker {
                        ExerciseListPickerView(
                            isPresented: $showExercisePicker,
                            workout: workout
                        )
                        .frame(width: geometry.size.width*0.9, height: geometry.size.height*0.9)
                        .transition(.move(edge: .trailing))
                    }
                }
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            focused = false
                        }
                    }
                }
                .animation(.easeInOut, value: showExercisePicker)
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Handles the drag gesture while it's in progress.
    ///
    /// - Parameter value: The current drag gesture value containing translation information.
    private func dragChanged(_ value: DragGesture.Value) {
        if value.translation.height > 0 {
            offsetY = value.translation.height
        }
    }
    
    /// Handles the completion of the drag gesture.
    ///
    /// If the drag distance exceeds the dismissal threshold, the view will animate to its
    /// compact state and trigger the dismissal. Otherwise, it will spring back to its
    /// original position.
    ///
    /// - Parameter value: The final drag gesture value containing translation information.
    private func dragEnded(_ value: DragGesture.Value) {
        if value.translation.height > dismissThreshold {
            withAnimation(.easeOut(duration: 0.3)) {
                offsetY = maxDragDistance
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isExpanded = false
            }
        } else {
            withAnimation(.spring()) {
                offsetY = 0
            }
        }
    }
}

// MARK: - Preview Provider

/// Provides preview configurations for WorkoutStartView.
///
/// This preview creates a sample workout with exercises and necessary dependencies
/// for testing the view in Xcode's preview canvas.
struct WorkoutStartView_Previews: PreviewProvider {
    static var previews: some View {
        @Namespace var namespace
        
        let workout = Workout(name: "New Workout", isFinished: false)
        let viewModel = ExerciseViewModel()
        
        WorkoutStartView(
            namespace: namespace,
            isExpanded: .constant(true),
            workout: workout
        )
        .modelContainer(previewContainer)
        .environment(viewModel)
        .onAppear {
            viewModel.loadExercises()
            previewContainer.mainContext.insert(workout)
            workout.exercises.append(
                WorkoutExercise(
                    exercise: Exercise(
                        id: "bench-press",
                        name: "Bench Press",
                        level: .intermediate,
                        primaryMuscles: [.chest],
                        secondaryMuscles: [.shoulders, .triceps],
                        instructions: ["Bench press instructions"],
                        category: .strength,
                        images: []
                    )
                )
            )
            workout.exercises.append(
                WorkoutExercise(
                    exercise: Exercise(
                        id: "shoulder-press",
                        name: "Shoulder Press",
                        level: .intermediate,
                        primaryMuscles: [.shoulders],
                        secondaryMuscles: [.triceps],
                        instructions: ["Shoulder press instructions"],
                        category: .strength,
                        images: []
                    )
                )
            )
        }
    }
}

/// Creates a ModelContainer for preview purposes.
let previewContainer: ModelContainer = {
    let container = try! ModelContainer(for: Workout.self)
    return container
}()
