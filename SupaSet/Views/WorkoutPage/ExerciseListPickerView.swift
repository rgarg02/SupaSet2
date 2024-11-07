//
//  ExerciseListPickerView.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/6/24.
//
import SwiftUI

struct ExerciseListPickerView: View {
    @Environment(ExerciseViewModel.self) var viewModel
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
                            .contentShape(Rectangle())
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
                        dismiss()
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
#Preview {
    ExerciseListPickerView()
        .environment(ExerciseViewModel())
}
