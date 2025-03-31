//
//  Expandable.swift
//  SupaSet
//
//  Created by Rishi Garg on 3/12/25.
//
import SwiftUI
import SwiftData
import UniformTypeIdentifiers

// MARK: - Main Expandable Workout View
struct ExpandableWorkout: View {
    // MARK: - Properties
    @Binding var show: Bool
    @Bindable var workout: Workout
    @State private var expandWorkout = false
    @State private var offsetY: CGFloat = 0
    @State private var isTimerVisible: Bool = true
    @Namespace private var animation
    @State var collapsed: Bool = false
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            let safeArea = geometry.safeAreaInsets
            
            ZStack(alignment: .top) {
                // Background
                backgroundView(safeArea)
                
                // Content
                miniWorkoutView()
                    .opacity(expandWorkout ? 0 : 1)
                expandedWorkoutView(safeArea)
                    .opacity(expandWorkout ? 1 : 0)
            }
            .frame(height: expandWorkout ? nil : 55, alignment: .top)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, expandWorkout ? 0 : safeArea.bottom + 55)
            .padding(.horizontal, expandWorkout ? 0 : 15)
            .offset(y: offsetY)
            .gesture(createDragGesture())
            .ignoresSafeArea()
        }
        .onChange(of: show) { _, newValue in
            if !newValue {
                withAnimation(.smooth(duration: 0.3)) {
                    expandWorkout = false
                }
            }
        }
    }
    
    // MARK: - Background View
    @ViewBuilder
    private func backgroundView(_ safeArea: EdgeInsets) -> some View {
        Rectangle()
            .fill(Color.primaryTheme)
            .clipShape(.rect(cornerRadius: expandWorkout ? (safeArea.bottom == 0 ? 0 : 45) : 15))
            .frame(height: expandWorkout ? nil : 55)
            .shadow(color: .primary.opacity(0.06), radius: 5, x: 5, y: 5)
            .shadow(color: .primary.opacity(0.05), radius: 5, x: -5, y: -5)
    }
    
    // MARK: - Drag Gesture
    private func createDragGesture() -> some Gesture {
        DragGesture()
            .onChanged { value in
                guard expandWorkout else { return }
                offsetY = max(value.translation.height, 0)
            }
            .onEnded { value in
                guard expandWorkout else { return }
                
                let translation = max(value.translation.height, 0)
                let velocity = value.velocity.height / 5
                
                withAnimation(.smooth(duration: 0.35)) {
                    if (translation + velocity) > (UIScreen.main.bounds.height * 0.3) {
                        expandWorkout = false
                    }
                    offsetY = 0
                }
            }
    }
    
    // MARK: - Mini Workout View
    @ViewBuilder
    private func miniWorkoutView() -> some View {
        HStack(spacing: 12) {
            HStack(spacing: 12) {
                // Progress indicator
                if !expandWorkout {
                    SetProgressView(progress: workout.progress, isExpanded: false)
                        .frame(width: 32, height: 32)
                        .matchedGeometryEffect(id: "Progress", in: animation)
                }
                
                // Workout name and exercise count
                VStack(alignment: .leading, spacing: 2) {
                    if !expandWorkout {
                        Text(workout.name)
                            .multilineTextAlignment(.leading)
                            .font(.headline)
                            .lineLimit(1)
                            .matchedGeometryEffect(id: "Name", in: animation)
                    }
                    
                    Text("\(workout.sortedExercises.count) exercises")
                        .font(.caption)
                        .matchedGeometryEffect(id: "ExerciseCount", in: animation)
                }
            }
            
            Spacer()
            
            // Timer
            if !expandWorkout {
                WorkoutTimer(workout: workout)
                    .matchedGeometryEffect(id: "Timer", in: animation)
            }
        }
        .background(Color.clear)
        .foregroundStyle(Color.primaryTheme.bestTextColor())
        .padding(.horizontal, 10)
        .frame(height: 55)
        .contentShape(.rect)
        .onTapGesture {
            withAnimation(.smooth(duration: 0.35)) {
                expandWorkout = true
            }
        }
    }
    
    // MARK: - Expanded Workout View
    @ViewBuilder
    private func expandedWorkoutView(_ safeArea: EdgeInsets) -> some View {
        VStack(spacing: 0) {
            // Header with drag indicator
            expandedHeaderView()
                .frame(height: 50)
            
            // Scrollable content
            WorkoutView(show: $show, workout: workout)
                
        }
        .padding(.top, safeArea.top + 5)
    }
    
    // MARK: - Expanded Header View
    @ViewBuilder
    private func expandedHeaderView() -> some View {
        VStack(spacing: 0) {
            // Drag indicator
            Capsule()
                .fill(.white.secondary)
                .frame(width: 35, height: 5)
                .padding(.top, 5)
                .padding(.bottom, 10)
            
            // Header content
            HStack {
                if expandWorkout {
                    NameSection(item: workout)
                        .foregroundStyle(Color.primaryTheme.bestTextColor())
                        .matchedGeometryEffect(id: "Name", in: animation)
                    
                    Spacer()
                    
                    // Only show timer in header when not visible in scroll
                    if !isTimerVisible {
                        WorkoutTimer(workout: workout)
                            .matchedGeometryEffect(id: "Timer", in: animation, isSource: false)
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Progress bar
            if expandWorkout {
                SetProgressView(progress: workout.progress, isExpanded: true)
                    .frame(height: 3)
                    .matchedGeometryEffect(id: "Progress", in: animation)
            }
        }
    }
    
    // MARK: - Workout Info Section
    @ViewBuilder
    private func workoutInfoSection() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                DateLabel(date: workout.date.formatted(date: .abbreviated, time: .shortened))
                
                Spacer()
                
                if expandWorkout && isTimerVisible {
                    WorkoutTimer(workout: workout)
                        .matchedGeometryEffect(id: "Timer", in: animation, isSource: true)
                }
            }
            
            NotesSection(item: workout)
        }
    }
}

// MARK: - Optimized Exercises List View
struct ExercisesListView: View {
    // MARK: - Properties
    @Environment(\.modelContext) private var modelContext
    @Binding var collapsed: Bool
    @Query private var exercises: [WorkoutExercise]
    @Environment(ExerciseViewModel.self) private var exerciseViewModel
    
    // MARK: - Init
    init(workoutID: UUID, collapsed: Binding<Bool>) {
        self.workoutID = workoutID
        _exercises = Query(
            filter: #Predicate<WorkoutExercise> { exercise in
                exercise.workout?.id == workoutID
            },
            sort: [SortDescriptor(\WorkoutExercise.order, order: .forward)]
        )
        _collapsed = collapsed
    }
    
    private let workoutID: UUID
    
    // MARK: - Body
    var body: some View {
        LazyVStack(spacing: 10) {
            ForEach(exercises) { exercise in
                ExerciseItemView(exercise: exercise, collapsed: $collapsed)
                    .padding(.vertical, 10)
                    .id(exercise.id) // Explicit ID for better diffing
            }
        }
        .animation(.easeInOut(duration: 0.25), value: collapsed)
        // Only animate order changes when necessary
        .animation(.easeInOut(duration: 0.25), value: exercises.map(\.order))
    }
}

// MARK: - Exercise Item View
struct ExerciseItemView: View {
    // MARK: - Properties
    @Bindable var exercise: WorkoutExercise
    @Binding var collapsed: Bool
    @Environment(\.modelContext) private var modelContext
    
    // Pre-sort sets for better performance
    var sortedSets: [ExerciseSet] {
        exercise.sets.sorted { $0.order < $1.order }
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 8) {
            // Exercise header
            ExerciseTopControls(exercise: exercise, dragging: collapsed)
                .contentShape(Rectangle())
            
            // Sets section - only render when expanded
            if !collapsed {
                VStack(spacing: 4) {
                    // Column headers
                    SetColumnNamesView(exerciseID: exercise.exerciseID, isTemplate: false)
                    
                    // Sets list
                    ForEach(sortedSets) { set in
                        SetRowItem(set: set, exercise: exercise)
                            .id(set.id)
                            .transition(.opacity)
                    }
                    
                    // Add set button
                    addSetButton()
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
    
    // MARK: - Add Set Button
    @ViewBuilder
    private func addSetButton() -> some View {
        PlaceholderSetRowView(templateSet: false) {
            withAnimation(.snappy(duration: 0.25)) {
                let lastSet = sortedSets.last
                exercise.insertSet(reps: lastSet?.reps ?? 0, weight: lastSet?.weight ?? 0)
            }
        }
    }
}

// MARK: - Set Row Item View
struct SetRowItem: View {
    // MARK: - Properties
    @Bindable var set: ExerciseSet
    let exercise: WorkoutExercise
    @Environment(\.modelContext) private var modelContext
    @FocusState private var isFocused: Bool
    
    // Calculate working set order efficiently
    private var workingSetOrder: Int {
        exercise.sets.lazy
            .filter { $0.type == .working && $0.order < set.order }
            .count
    }
    
    // MARK: - Body
    var body: some View {
        SwipeAction(cornerRadius: 8, direction: .trailing) {
            SetRowViewCombined(
                order: workingSetOrder,
                isTemplate: false,
                weight: $set.weight,
                reps: $set.reps,
                isDone: $set.isDone,
                type: $set.type,
                moveToNextRow: moveToNextRow
            )
        } actions: {
            Action(tint: .red, icon: "trash.fill") {
                deleteSet()
            }
        }
    }
    
    // MARK: - Actions
    private func moveToNextRow() {
        NotificationCenter.default.post(
            name: Notification.Name("FocusNextRow"),
            object: nil,
            userInfo: ["nextRowID": set.id]
        )
    }
    
    private func deleteSet() {
        withAnimation(.easeInOut) {
            // Update orders of following sets before deleting
            let setOrder = set.order
            let setsToUpdate = exercise.sets.filter { $0.order > setOrder }
            
            for setToUpdate in setsToUpdate {
                setToUpdate.order -= 1
            }
            
            modelContext.delete(set)
        }
    }
}

// MARK: - ScrollPosition Helper
extension View {
    func onScrollPositionChange(action: @escaping (CGFloat) -> Void) -> some View {
        self.onScrollGeometryChange(for: CGFloat.self, of: { geometry in
            geometry.contentOffset.y
        }, action: { _, newValue in
            action(newValue)
        })
    }
}
