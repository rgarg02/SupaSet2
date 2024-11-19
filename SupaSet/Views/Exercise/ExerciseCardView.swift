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
    private let columns = [
            GridItem(.fixed(40)), // Smaller column for set number
            GridItem(.flexible()), // Flexible for weight
            GridItem(.flexible()), // Flexible for reps
            GridItem(.fixed(80))  // Smaller column for checkbox
        ]
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(workoutExercise.exercise.name)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.theme.text)
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
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.theme.background)
                .shadow(
                    color: Color.black.opacity(0.1),
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
}


struct ExerciseCardView_Previews: PreviewProvider {
    static var previews: some View {
        let workout = Workout(name: "Workout")
        let exercise = Exercise(
            id: "bench-press",
            name: "Bench Press",
            force: .push,
            level: .intermediate,
            mechanic: .compound,
            equipment: .barbell,
            primaryMuscles: [.chest],
            secondaryMuscles: [.shoulders, .triceps],
            instructions: ["Bench press instructions"],
            category: .strength,
            images: []
        )
        let workoutExercise = WorkoutExercise(exercise: exercise)
        let preview = PreviewContainer.preview
        NavigationStack {
            ExerciseCardView(
                workout: workout,
                workoutExercise: workoutExercise,
                focused: FocusState<Bool>().projectedValue
            )
            .frame(maxHeight: 400)
            .padding()
        }
        .modelContainer(preview.container)
        .onAppear {
            preview.container.mainContext.insert(workoutExercise)
        }
    }
}
