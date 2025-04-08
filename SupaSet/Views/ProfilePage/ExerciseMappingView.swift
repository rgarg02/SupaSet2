//
//  ExerciseMappingView.swift
//  SupaSet
//
//  Created by Rishi Garg on 3/9/25.
//

import SwiftUI

struct ExerciseMappingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ExerciseViewModel.self) private var exerciseViewModel
    @State private var searchQueries: [String: String] = [:]
    @State private var selectedExerciseIds: [String: String] = [:]
    
    var onComplete: () -> Void
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("The following exercises were not found in your database. You can either map them to existing exercises or keep them as new exercises.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                
                ForEach(exerciseViewModel.newExercises) { newExercise in
                    VStack(alignment: .leading) {
                        Text(newExercise.name)
                            .font(.headline)
                        
                        Picker("Map to", selection: Binding(
                            get: { selectedExerciseIds[newExercise.id] ?? newExercise.id },
                            set: { selectedExerciseIds[newExercise.id] = $0 }
                        )) {
                            Text("Keep as new exercise")
                                .tag(newExercise.id)
                            
                            Divider()
                            
                            // Search field for filtering exercises
                            TextField("Search exercises", text: Binding(
                                get: { searchQueries[newExercise.id] ?? "" },
                                set: { searchQueries[newExercise.id] = $0 }
                            ))
                            .textFieldStyle(.roundedBorder)
                            .padding(.vertical, 4)
                            
                            Divider()
                            
                            // Show matching existing exercises
                            let filteredExercises = exerciseViewModel.exercises(matching: searchQueries[newExercise.id] ?? "")
                                .filter { $0.id != newExercise.id } // Exclude the new exercise itself
                            
                            ForEach(filteredExercises) { existingExercise in
                                Text(existingExercise.name)
                                    .tag(existingExercise.id)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Map Exercises")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveExerciseMappings()
                        dismiss()
                        onComplete()
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        exerciseViewModel.clearNewExercises()
                        dismiss()
                        onComplete()
                    }
                }
            }
        }
    }
    
    private func saveExerciseMappings() {
        // Process each new exercise
        for newExercise in exerciseViewModel.newExercises {
            if let mappedId = selectedExerciseIds[newExercise.id], 
               mappedId != newExercise.id,
               exerciseViewModel.exercises.contains(where: { $0.id == mappedId }) {
                // Map this exercise to an existing one by updating workouts
                exerciseViewModel.mapExerciseToExisting(fromId: newExercise.id, toId: mappedId)
            } else {
                // Keep as a new exercise
                exerciseViewModel.confirmNewExercise(newExercise.id)
            }
        }
        
        // Add confirmed new exercises to store
        exerciseViewModel.addConfirmedExercisesToStore()
    }
}
