//
//  ExerciseListPickerView.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/6/24.
//
import SwiftUI

struct ExerciseListPickerView: View {
    @Environment(ExerciseViewModel.self) var viewModel
    @Environment(\.modelContext) var modelContext
    @Binding var isPresented : Bool
    @Bindable var workout : Workout
    @State private var searchText = ""
    @State private var selectedCategory: Category?
    @State private var selectedMuscleGroup: MuscleGroup?
    @State private var selectedEquipment: Equipment?
    @State private var selectedLevel: Level?
    @Environment(\.dismiss) private var dismiss
    
    var filteredExercises: [Exercise] {
        var exercises = viewModel.exercises(matching: searchText)
        
        if let category = selectedCategory {
            exercises = exercises.filter { $0.category == category }
        }
        
        if let muscleGroup = selectedMuscleGroup {
            exercises = exercises.filter {
                $0.primaryMuscles.contains(muscleGroup) ||
                $0.secondaryMuscles.contains(muscleGroup)
            }
        }
        
        if let equipment = selectedEquipment {
            exercises = exercises.filter { $0.equipment == equipment }
        }
        if let level = selectedLevel {
            exercises = exercises.filter { $0.level == level }
        }
        
        return exercises
    }
    // Helper function to check if exercise exists in workout
    private func isExerciseInWorkout(_ exercise: Exercise) -> Bool {
        return workout.exercises.contains { workoutExercise in
            workoutExercise.exercise.id == exercise.id
        }
    }
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        CustomFilterPicker(
                            title: "Category",
                            selection: $selectedCategory,
                            options: Array(Category.allCases)
                        )
                        
                        CustomFilterPicker(
                            title: "Muscle",
                            selection: $selectedMuscleGroup,
                            options: Array(MuscleGroup.allCases)
                        )
                        
                        CustomFilterPicker(
                            title: "Equipment",
                            selection: $selectedEquipment,
                            options: Array(Equipment.allCases)
                        )
                        CustomFilterPicker(
                            title: "Level",
                            selection: $selectedLevel,
                            options: Array(Level.allCases)
                        )
                    }
                    .padding()
                }
                .background(Color(.systemBackground))
                .overlay(
                    Divider(),
                    alignment: .bottom
                )
                
                // Exercise List
                List {
                    ForEach(filteredExercises) { exercise in
                        ExerciseRowView(exercise: exercise)
                            .listRowInsets(EdgeInsets(
                                top: 4,
                                leading: 16,
                                bottom: 4,
                                trailing: 16
                            ))
                            .listRowSeparator(.hidden)
                            .background(isExerciseInWorkout(exercise) ? Color.theme.secondary : Color.theme.background)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation {
                                    if let existingExercise = workout.getWorkoutExercise(for: exercise) {
                                        // Remove exercise if it already exists
                                        workout.deleteExercise(exercise: exercise) // Changed to pass the exercise directly
                                        modelContext.delete(existingExercise)
                                        try? modelContext.save() // Fixed: Added parentheses for method call
                                    } else {
                                        // Add new exercise at the end
                                        workout.insertExercise(exercise) // Fixed: Added 'at' parameter label
                                    }
                                }
                            }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Add Exercises")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search exercises")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
        .task {
            viewModel.loadExercises()
        }
    }
}

// Preview
struct ExerciseListPickerView_Preview: PreviewProvider {
    static var previews: some View {
        let workout = Workout(name: "New Workout", isFinished: false)
        let viewModel = ExerciseViewModel()
        ExerciseListPickerView(isPresented: .constant(true), workout: workout)
            .modelContainer(previewContainer)
            .environment(viewModel)
            .onAppear {
                viewModel.loadExercises()
                previewContainer.mainContext.insert(workout)
            }
    }
}
