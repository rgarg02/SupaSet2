//
//  MuscleIntensityView.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/14/25.
//

import SwiftUI
import SwiftData
import SceneKit

struct MuscleIntensityView: View {
    @Environment(ExerciseViewModel.self) var exerciseViewModel
    let workout: Workout
    @State private var nodeName: String = ""
    @State private var showDetails: Bool = false
    @State private var isTapGestureEnabled: Bool = false
    @State private var movetoMuscle: String? = nil
    @State private var locationOfNode: Float? = nil
    @State private var sceneManager = SceneManager.shared
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.theme.primary,
                    Color.theme.background.opacity(0.8)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            SceneKitContainer(
                isTapGestureEnabled: isTapGestureEnabled
            )
        }
        .frame(height: 350) // Set height for the 3D view
        .cornerRadius(8)
        .onAppear {
//             Highlight muscles on first load
            DispatchQueue.main.async {
                sceneManager.sceneView.scene?.highlightMuscleIntensity(muscleIntensity: calculateMuscleIntensity(from: workout))
            }
        }
    }
    
    /// Calculate the total intensity for each muscle group across all workouts.
    func calculateMuscleIntensity(from workout: Workout) -> [MuscleGroup: Double] {
        var muscleGroupVolume: [MuscleGroup: Double] = [:]
        var totalVolume: Double = 0.0
        
        // Iterate through the workout exercises
        for exercise in workout.exercises {
            let exerciseVolume = exercise.totalVolume
            totalVolume += exerciseVolume
            
            // Get the muscles targeted by this exercise
            if let mappedExercise = exerciseViewModel.exercises.first(where: { $0.id == exercise.exerciseID }) {
                let primaryMuscleGroups = mappedExercise.primaryMuscles
                let secondaryMuscleGroups = mappedExercise.secondaryMuscles
                
                // Allocate volume to primary and secondary muscle groups
                for muscle in primaryMuscleGroups {
                    muscleGroupVolume[muscle, default: 0.0] += exerciseVolume * 0.7
                }
                for muscle in secondaryMuscleGroups {
                    muscleGroupVolume[muscle, default: 0.0] += exerciseVolume * 0.3
                }
            }
        }
        
        // Convert to intensity (percentage of total volume)
        guard totalVolume > 0 else { return [:] }
        for (muscle, volume) in muscleGroupVolume {
            muscleGroupVolume[muscle] = (volume / totalVolume) * 100
        }
        
        return muscleGroupVolume
    }
}

#Preview {
    let preview = PreviewContainer.preview
    MuscleIntensityView(workout: preview.workout)
        .modelContainer(preview.container)
        .environment(preview.viewModel)
}
