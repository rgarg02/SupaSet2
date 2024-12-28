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
    @Environment(\.dismiss) private var dismiss
    
    enum Mode {
        case add(workout: Workout)
        case replace(workoutExercise: WorkoutExercise)
    }
    
    let mode: Mode
    @State private var searchText = ""
    @State private var selectedCategory: Category?
    @State private var selectedMuscleGroup: MuscleGroup?
    @State private var selectedEquipment: Equipment?
    @State private var selectedLevel: Level?
    @State private var selectedExercises: [Exercise] = []
    
    // Initialize for adding exercises
    init(workout: Workout) {
        self.mode = .add(workout: workout)
    }
    
    // Initialize for replacing an exercise
    init(workoutExercise: WorkoutExercise) {
        self.mode = .replace(workoutExercise: workoutExercise)
    }
    
    private var isReplacing: Bool {
        switch mode {
        case .add:
            return false
        case .replace:
            return true
        }
    }
    
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
        VStack(spacing: 0) {
            NavigationView {
                VStack {
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
                                .background(selectedExercises.contains(exercise) ? Color.theme.secondary : Color.theme.background)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    handleExerciseSelection(exercise)
                                }
                        }
                    }
                    .listStyle(.plain)
                }
                .searchable(text: $searchText, prompt: "Search exercises")
            }
        }
        .navigationTitle(isReplacing ? "Replace Exercise" : "Add Exercises")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !selectedExercises.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isReplacing ? "Replace" : "Add (\(selectedExercises.count))") {
                        handleAction()
                        dismiss()
                    }
                    .foregroundColor(.theme.accent)
                }
            }
        }
        .task {
            viewModel.loadExercises()
        }
    }
    
    private func handleExerciseSelection(_ exercise: Exercise) {
        withAnimation(.easeIn(duration: 0.2)) {
            if isReplacing {
                // In replace mode, only allow one selection
                selectedExercises = [exercise]
            } else {
                // In add mode, allow multiple selections
                if let existingExerciseIndex = selectedExercises.firstIndex(where: { $0.id == exercise.id }) {
                    selectedExercises.remove(at: existingExerciseIndex)
                } else {
                    selectedExercises.append(exercise)
                }
            }
        }
    }
    
    private func handleAction() {
        switch mode {
        case .add(let workout):
            for exercise in selectedExercises {
                workout.insertExercise(exercise.id)
            }
        case .replace(let workoutExercise):
            if let exercise = selectedExercises.first {
                workoutExercise.exerciseID = exercise.id
                workoutExercise.sets.removeAll()
                workoutExercise.notes = ""
            }
        }
        selectedExercises = []
    }
}

#Preview("Exercise List Picker") {
    let preview = PreviewContainer.preview
    ExerciseListPickerView(workout: preview.workout)
        .environment(preview.viewModel)
        .modelContainer(preview.container)
}
#Preview("Exercise List Picker - Replace Mode") {
    let preview = PreviewContainer.preview
    ExerciseListPickerView(workoutExercise: preview.workout.sortedExercises[0])
        .environment(preview.viewModel)
        .modelContainer(preview.container)
}
