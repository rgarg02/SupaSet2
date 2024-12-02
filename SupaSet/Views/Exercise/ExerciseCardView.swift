//
//  ExerciseCardView.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/7/24.
//

import SwiftUI
import SwiftData

struct ExerciseCardView: View {
    let workout: Workout
    let workoutExercise: WorkoutExercise
    @Environment(\.modelContext) private var modelContext
    @FocusState.Binding var focused : Bool
    @State private var offsets = [CGSize](repeating: CGSize.zero, count: 6)
    let moving: Bool
    
    // New bindings for gesture handling
    @Binding var selectedExercise: WorkoutExercise?
    @Binding var selectedExerciseScale: CGFloat
    @Binding var selectedExerciseFrame: CGRect
    @Binding var offset: CGSize
    @Binding var hapticsTrigger: Bool
    @Binding var initialScrollOffset: CGRect
    @Binding var lastActiveScrollId: UUID?
    @Binding var dragging: Bool
    @Binding var parentBounds: CGRect
    let minimizing: Bool
    let onScroll: (CGPoint) -> Void
    let onSwap: (CGPoint) -> Void
    
    private let columns = [
            GridItem(.fixed(40)), // Smaller column for set number
            GridItem(.flexible()), // Flexible for weight
            GridItem(.flexible()), // Flexible for reps
            GridItem(.fixed(80))  // Smaller column for checkbox
    ]
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack{
                Text(workoutExercise.exercise.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.theme.text)
            }
            .gesture(customCombinedGesture)
            .frame(maxWidth: .infinity)
            if !moving{
                VStack(spacing: 8) {
                    ScrollView(.vertical){
                        LazyVGrid(columns: columns) {
                            Text("SET")
                                .font(.caption)
                                .foregroundColor(.theme.text)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            //                    .frame(width: 20)
                            
                            Text("WEIGHT")
                                .font(.caption)
                                .foregroundColor(.theme.text)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            //                    .frame(width: 100)
                            
                            Text("REPS")
                                .font(.caption)
                                .foregroundColor(.theme.text)
                                .frame(maxWidth: .infinity, alignment: .center)
                            //                    .frame(width: 100)
                            
                            Text("DONE")
                                .font(.caption)
                                .foregroundColor(.theme.text)
                                .frame(maxWidth: .infinity, alignment: .center)
                            //                    .frame(width: 40)
                        }
                        ForEach(workoutExercise.sortedSets, id: \.self) { set in
                            SwipeAction(cornerRadius: 8, direction: .trailing){
                                SetRowView(
                                    setNumber: set.order + 1,
                                    set: set,
                                    focused: $focused
                                )
                            } actions:{
                                Action(tint: .red, icon: "trash.fill") {
                                    withAnimation(.easeInOut){
                                        workoutExercise.deleteSet(set)
                                        modelContext.delete(set)
                                        WorkoutActivityManager.shared.updateWorkoutActivity(workout: workout)
                                    }
                                }
                            }
                        }
                        CustomButton(icon: "plus", title: "Add Set", size: .small, style: .filled(background: .theme.accent, foreground: .theme.text)) {
                            workoutExercise.insertSet(reps: workoutExercise.sortedSets.last?.reps ?? 0, weight: workoutExercise.sortedSets.last?.weight ?? 0)
                            WorkoutActivityManager.shared.updateWorkoutActivity(workout: workout)
                        }
                    }
                }
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.theme.background)
                .shadow(
                    color: Color.theme.primary.opacity(0.5),
                    radius: 5,
                    x: 0,
                    y: 2
                )
                .padding(8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.theme.accent, lineWidth: 1)
                .padding(8)
            
        )
    }
    private var customCombinedGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.25)
            .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .global))
            .onChanged { value in
                switch value {
                case .second(let status, let value):
                    if status {
                        if selectedExercise == nil {
                            selectedExercise = workoutExercise
                            selectedExerciseFrame = workoutExercise.frame.asCGRect()
                            initialScrollOffset = selectedExerciseFrame
                            initialScrollOffset = selectedExerciseFrame
                            lastActiveScrollId = workoutExercise.id
                            hapticsTrigger.toggle()
                            
                            withAnimation(.smooth(duration: 0.2, extraBounce: 0)) {
                                selectedExerciseScale = 1.1
                                dragging = true
                            }
                        }
                        
                        if let value {
                            // Calculate the new Y position
                            let newY = initialScrollOffset.minY + value.translation.height
                            
                            // Get the available vertical space
                            let minY = parentBounds.minY + 50 // Add some padding from top
                            let maxY = parentBounds.maxY - selectedExerciseFrame.height - 50 // Subtract height and padding
                            
                            // Clamp the Y position
                            let clampedY = min(max(newY, minY), maxY)
                            
                            // Calculate the clamped offset
                            let clampedOffset = CGSize(
                                width: 0,
                                height: clampedY - initialScrollOffset.minY
                            )
                            
                            offset = clampedOffset
                            let location = value.location
                            onScroll(location)
                            onSwap(location)
                        }
                    }
                default: ()
                }
            }
            .onEnded { _ in
                withAnimation(.snappy(duration: 0.25, extraBounce: 0),
                             completionCriteria: .logicallyComplete) {
                    selectedExercise?.frame = Frame(selectedExerciseFrame)
                    initialScrollOffset = selectedExerciseFrame
                    selectedExerciseScale = 1.0
                    offset = .zero
                } completion: {
                    selectedExercise = nil
                    initialScrollOffset = .zero
                    selectedExerciseFrame = .zero
                    lastActiveScrollId = nil
                    withAnimation(.snappy) {
                        dragging = false
                    }
                }
            }
    }}


//struct ExerciseCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        let workout = Workout(name: "Workout")
//        let exercise = Exercise(
//            id: "bench-press",
//            name: "Bench Press",
//            force: .push,
//            level: .intermediate,
//            mechanic: .compound,
//            equipment: .barbell,
//            primaryMuscles: [.chest],
//            secondaryMuscles: [.shoulders, .triceps],
//            instructions: ["Bench press instructions"],
//            category: .strength,
//            images: []
//        )
//        let workoutExercise = WorkoutExercise(exercise: exercise)
//        let preview = PreviewContainer.preview
//        NavigationStack {
//            ExerciseCardView(
//                workout: workout,
//                workoutExercise: workoutExercise,
//                focused: FocusState<Bool>().projectedValue,
//                moving: true
//            )
//            .frame(maxHeight: 400)
//            .padding()
//        }
//        .modelContainer(preview.container)
//        .onAppear {
//            preview.container.mainContext.insert(workoutExercise)
//        }
//    }
//}
