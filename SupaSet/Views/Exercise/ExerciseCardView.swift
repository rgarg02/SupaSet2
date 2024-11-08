//
//  ExerciseCardView.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/7/24.
//

import SwiftUI
import SwiftData

struct ExerciseCardView: View {
    let workoutExercise: WorkoutExercise
    @Environment(\.modelContext) private var modelContext
    @FocusState.Binding var focused : Bool
    @State private var offsets = [CGSize](repeating: CGSize.zero, count: 6)
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(workoutExercise.exercise.name)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.theme.text)
            HStack(spacing: 16) {
                Text("SET")
                    .font(.caption)
                    .foregroundColor(.theme.text)
                    .frame(width: 30)
                
                Text("WEIGHT")
                    .font(.caption)
                    .foregroundColor(.theme.text)
                    .frame(width: 80)
                
                Text("REPS")
                    .font(.caption)
                    .foregroundColor(.theme.text)
                    .frame(width: 80)
                
                Spacer()
                
                Text("DONE")
                    .font(.caption)
                    .foregroundColor(.theme.text)
                    .frame(width: 50)
            }
            .padding(.horizontal, 16)
            VStack(spacing: 8) {
                ScrollView{
                    ForEach(workoutExercise.sortedSets, id: \.self) { set in
                        SwipeAction(cornerRadius: 8, direction: .trailing){
                            SetRowView(
                                setNumber: set.order + 1,
                                set: set,
                                focused: $focused
                            )
                            .padding(.horizontal)
                        } actions:{
                            Action(tint: .red, icon: "trash.fill") {
                                withAnimation(.easeInOut){
                                    workoutExercise.deleteSet(set)
                                    modelContext.delete(set)
                                }
                            }                        }
                    }
                }
            }
            Spacer()
            CustomButton(icon: "plus", title: "Add Set", size: .small, style: .filled()) {
                workoutExercise.insertSet(reps: workoutExercise.sortedSets.last?.reps ?? 0, weight: workoutExercise.sortedSets.last?.weight ?? 0)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
        let workoutExercise = WorkoutExercise(
            exercise: Exercise(
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
        )
        
        NavigationStack {
            ExerciseCardView(
                workoutExercise: workoutExercise,
                focused: FocusState<Bool>().projectedValue
            )
            .frame(maxHeight: 400)
            .padding()
        }
        .modelContainer(previewContainer)
        .onAppear {
            // Add sample sets to the workout exercise
            let setsData: [(weight: Double, reps: Int)] = [
                (135, 12),
                (155, 10),
                (175, 8),
                (175, 8)
            ]
            
            for (index, setData) in setsData.enumerated() {
                let set = ExerciseSet(
                    reps: setData.reps,
                    weight: setData.weight,
                    order: index
                )
                workoutExercise.sets.append(set)
            }
            
            // Insert the workout exercise into the container
            previewContainer.mainContext.insert(workoutExercise)
        }
    }
}
