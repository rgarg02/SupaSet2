//
//  TESTVIEW.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/23/25.
//

import SwiftUI
import SwiftData

struct TESTVIEW: View {
    // query every swiftdata model
    @Query var workouts: [Workout]
    @Query var workoutExercise: [WorkoutExercise]
    @Query var exerciseSet: [ExerciseSet]
    @Query var template: [Template]
    @Query var templateExercise: [TemplateExercise]
    @Query var templateExerciseSet: [TemplateExerciseSet]
    @Query var exerciseDetail: [ExerciseDetail]
    var body: some View {
        // Preview all the data, with foreach and VStack
        // Divide everything in sections so it's easier to read
        // Expand info for each
        // Use list with sections
        List{
            Section(header: Text("Workouts")) {
                ForEach(workouts) { workout in
                    Text(workout.name)
                }
            }
            Section(header: Text("Workout Exercises")) {
                ForEach(workoutExercise) { workoutExercise in
                    Text(workoutExercise.exerciseID)
                }
            }
            Section(header: Text("Exercise Sets")) {
                ForEach(exerciseSet) { exerciseSet in
                    Text(exerciseSet.isDone ? "Done" : "Not Done")
                }
            }
            Section(header: Text("Templates")) {
                ForEach(template) { template in
                    Text(template.name)
                }
            }
            Section(header: Text("Template Exercises")) {
                ForEach(templateExercise) { templateExercise in
                    Text(templateExercise.exerciseID)
                }
            }
            Section(header: Text("Template Exercise Sets")) {
                ForEach(templateExerciseSet) { templateExerciseSet in
                    Text(templateExerciseSet.id.uuidString)
                }
            }
            Section(header: Text("Exercise Details")) {
                ForEach(exerciseDetail) { exerciseDetail in
                    Text(exerciseDetail.exerciseID)
                }
            }
        }
    }
}
