//
//  Expandable.swift
//  SupaSet
//
//  Created by Rishi Garg on 3/12/25.
//
import SwiftUI
import UniformTypeIdentifiers

struct ExpandableWorkout: View {
    @Binding var show: Bool
    @Bindable var workout: Workout
    @State private var expandWorkout = false
    @State private var offsetY: CGFloat = 0
    @State private var isTimerVisible: Bool = true
    @Namespace private var animation
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            let safeArea = $0.safeAreaInsets
            ZStack(alignment: .top) {
                ZStack{
                    Rectangle()
                        .fill(Color.primaryTheme)
                }
                .clipShape(.rect(cornerRadius: expandWorkout ? (safeArea.bottom == 0 ? 0 : 45) : 15))
                .frame(height: expandWorkout ? nil : 55)
                .shadow(color: .primary.opacity(0.06), radius: 5, x: 5, y: 5)
                .shadow(color: .primary.opacity(0.05), radius: 5, x: -5, y: -5)
                
                miniWorkout()
                    .opacity(expandWorkout ? 0 : 1)
                ExpandedWorkout(size, safeArea)
                    .opacity(expandWorkout ? 1 : 0)
                
            }
            .frame(height: expandWorkout ? nil : 55, alignment: .top)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, expandWorkout ? 0 : safeArea.bottom + 55)
            .padding(.horizontal, expandWorkout ? 0 : 15)
            .offset(y: offsetY)
            .gesture(
                PanGesture { value in
                    guard expandWorkout else { return }
                    let translation = max(value.translation.height, 0)
                    offsetY = translation
                    let progress = min(translation / (UIScreen.main.bounds.height * 0.5), 1)
                } onEnd: { value in
                    guard expandWorkout else { return }
                    
                    let translation = max(value.translation.height, 0)
                    let velocity = value.velocity.height / 5
                    
                    withAnimation(.smooth(duration: 0.35)) {
                        if (translation + velocity) > (UIScreen.main.bounds.height * 0.3) {
                            /// Closing View
                            expandWorkout = false
                        }
                        
                        offsetY = 0
                    }
                }
            )
            .ignoresSafeArea()
        }
        .onChange(of: show) { oldValue, newValue in
            if !newValue {
                // When workout is finished or cancelled
                withAnimation(.smooth(duration: 0.3)){
                    expandWorkout = false
                }
            }
        }
        .animation(.easeInOut, value: isTimerVisible)
    }
    
    @ViewBuilder
    func miniWorkout() -> some View {
        HStack(spacing: 12) {
            HStack(spacing: 12) {
                // Workout progress indicator
                if !expandWorkout {
                    ZStack{
                        SetProgressView(progress: workout.progress, isExpanded: false)
                            .frame(width: 32, height: 32)
                            .matchedGeometryEffect(id: "Progress", in: animation)
                    }
                }
                VStack(alignment: .leading, spacing: 2){
                    if !expandWorkout {
                        ZStack {
                            Text(workout.name)
                                .multilineTextAlignment(.leading)
                                .font(.headline)
                                .lineLimit(1)
                                .matchedGeometryEffect(id: "Name", in: animation)
                        }
                    }
                    Text("\(workout.sortedExercises.count) exercises")
                        .font(.caption)
                        .matchedGeometryEffect(id: "ExerciseCount", in: animation)
                }
            }
            Spacer()
            if !expandWorkout {
                ZStack{
                    WorkoutTimer(workout: workout)
                        .matchedGeometryEffect(id: "Timer", in: animation)
                }
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
    
    @ViewBuilder
    func ExpandedWorkout(_ size: CGSize, _ safeArea: EdgeInsets) -> some View {
        VStack {
            VStack{
                Capsule()
                    .fill(.white.secondary)
                    .frame(width: 35, height: 5)
                    .offset(y: -10)
                VStack{
                    if expandWorkout {
                        ZStack{
                            HStack{
                                NameSection(item: workout)
                                    .foregroundStyle(Color.primaryTheme.bestTextColor())
                                    .matchedGeometryEffect(id: "Name", in: animation)
                                // Only show timer in header if it's not visible in scroll
                                if expandWorkout && !isTimerVisible {
                                    ZStack{
                                        WorkoutTimer(workout: workout)
                                            .frame(alignment: .trailing)
                                            .matchedGeometryEffect(id: "Timer", in: animation, isSource: false)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    if expandWorkout{
                        ZStack{
                            SetProgressView(progress: workout.progress, isExpanded: true)
                                .frame(height: 3, alignment: .bottom)
                                .matchedGeometryEffect(id: "Progress", in: animation)
                        }
                    }
                }
            }
            .frame(height: 50)
            
            // Use LazyVStack for better performance with many items
            ScrollView {
                LazyVStack{
                    VStack(spacing: 20) {
                        HStack{
                            DateLabel(date: workout.date.formatted(date: .abbreviated, time: .shortened))
                            Spacer()
                            if expandWorkout && isTimerVisible {
                                ZStack{
                                    WorkoutTimer(workout: workout)
                                        .matchedGeometryEffect(id: "Timer", in: animation, isSource: true)
                                }
                            }
                        }
                        NotesSection(item: workout)
                    }
                    // Use optimized version of ExercisesScroll
                    ExercisesScroll(workout: workout)
                    CancelFinishAddView(
                        item: workout,
                        originalItem: workout,
                        show: $show,
                        isNew: !workout.isFinished
                    )
                    .padding(.vertical, 20)
                }
            }
            .onScrollGeometryChange(for: CGFloat.self, of: { geometry in
                geometry.contentOffset.y
            }, action: { oldValue, newValue in
                isTimerVisible = newValue < 30
            })
            .scrollIndicators(.hidden)
            .padding()
            .background(.thickMaterial)
        }
        .padding(.top, safeArea.top + 5)
    }
}

// Rest of the code remains the same
// Optimized version of ExercisesScroll
struct ExercisesScroll: View {
    let workout: Workout
    @Environment(ExerciseViewModel.self) private var exerciseViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var dragging = false
    @State private var draggedItem: WorkoutExercise?
    
    var body: some View {
        // LazyVStack will only render what's visible
        LazyVStack {
            ForEach(workout.sortedExercises) { exercise in
                ExerciseItemView(exercise: exercise, dragging: $dragging)
            }
        }
    }
}

// Extracted view for better rendering performance
struct ExerciseItemView: View {
    let exercise: WorkoutExercise
    @Binding var dragging: Bool
    @Environment(\.modelContext) private var modelContext
    var body: some View {
        VStack {
            HStack {
                ExerciseTopControls(exercise: exercise, dragging: dragging)
                    .contentShape(Rectangle())
            }
            
            if !dragging {
                SetColumnNamesView(exerciseID: exercise.exerciseID, isTemplate: false)
                
                ForEach(exercise.sortedSets, id: \.self) { set in
                    SetRowItem(set: set, exercise: exercise)
                }
                
                PlaceholderSetRowView(templateSet: false, action: {
                    withAnimation(.snappy(duration: 0.25)) {
                        exercise.insertSet(
                            reps: exercise.sortedSets.last?.reps ?? 0,
                            weight: exercise.sortedSets.last?.weight ?? 0
                        )
                    }
                })
            }
        }
    }
}

// Extracted for better performance
struct SetRowItem: View {
    @Bindable var set: ExerciseSet
    let exercise: WorkoutExercise
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        let workingSetOrder = exercise.sortedSets
            .prefix(while: { $0.order < set.order })
            .filter { $0.type == .working }
            .count
        
        return SwipeAction(cornerRadius: 8, direction: .trailing) {
            SetRowViewCombined(
                order: workingSetOrder,
                isTemplate: false,
                weight: $set.weight,
                reps: $set.reps,
                isDone: $set.isDone, type: $set.type
            )
        } actions: {
            Action(tint: .red, icon: "trash.fill") {
                withAnimation(.easeInOut) {
                    exercise.deleteSet(set)
                    modelContext.delete(set)
                }
            }
        }
    }
}
