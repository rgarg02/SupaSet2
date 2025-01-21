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
    @Query var workouts: [Workout]
    @State private var sceneView = SCNView()
    @State private var nodeName: String = ""
    @State private var showDetails: Bool = false
    @State private var isTapGestureEnabled: Bool = true
    @State private var movetoMuscle: String? = nil
    @State private var locationOfNode: Float? = nil
    
    var body: some View {
        if let workout = workouts.first {
            VStack {
                SceneKitContainer(
                    sceneView: $sceneView,
                    nodeName: $nodeName,
                    showDetails: $showDetails,
                    isTapGestureEnabled: isTapGestureEnabled,
                    movetoMuscle: $movetoMuscle,
                    locationOfNode: $locationOfNode
                )
                .frame(height: 500) // Set height for the 3D view
                Text("Muscle Intensity")
                    .font(.title)
                
                List(calculateMuscleIntensity(from: workouts).sorted(by: { $0.value > $1.value }), id: \.key) { muscle, intensity in
                    HStack {
                        Text(muscle.rawValue.capitalized)
                        Spacer()
                        Text("\(intensity, specifier: "%.2f")%")
                    }
                }
            }
            .onAppear {
                // Highlight muscles on first load
                DispatchQueue.main.async {
                    sceneView.scene?.highlightMuscleIntensity(muscleIntensity: calculateMuscleIntensity(from: workouts))
                }
            }
        } else {
            Text("No workouts available.")
        }
    }
    
    /// Calculate the total intensity for each muscle group across all workouts.
    func calculateMuscleIntensity(from workouts: [Workout]) -> [MuscleGroup: Double] {
        var muscleGroupVolume: [MuscleGroup: Double] = [:]
        var totalVolume: Double = 0.0
        
        // Iterate through all workouts
        for workout in workouts {
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
    MuscleIntensityView()
        .environment(preview.viewModel)
        .modelContainer(preview.container)
}
