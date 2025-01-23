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
        case addToTemplate(template: Template)
        case replaceTemplateExercise(templateExercise: TemplateExercise)
    }
    
    let mode: Mode
    @State private var searchText = ""
    @State private var selectedCategory: Category?
    @State private var selectedMuscleGroup: MuscleGroup?
    @State private var selectedEquipment: Equipment?
    @State private var selectedLevel: Level?
    @State private var selectedExercises: [Exercise] = []
    @State private var selectedExercise: Exercise?
    @State private var isShowingDetail = false
    // Initialize for adding exercises
    init(workout: Workout) {
        self.mode = .add(workout: workout)
    }
    
    // Initialize for replacing an exercise
    init(workoutExercise: WorkoutExercise) {
        self.mode = .replace(workoutExercise: workoutExercise)
    }
    
    // Initialize for adding a template
    init(template: Template) {
        self.mode = .addToTemplate(template: template)
    }
    
    // Initialize for replacing a template exercise
    init(templateExercise: TemplateExercise) {
        self.mode = .replaceTemplateExercise(templateExercise: templateExercise)
    }
    
    private var isReplacing: Bool {
        switch mode {
        case .add:
            return false
        case .replace:
            return true
        case .addToTemplate:
            return false
        case .replaceTemplateExercise:
            return true
        }
    }
    
    var filteredExercises: [Exercise] {
        let searchTokens = searchText.lowercased().split(separator: " ").map(String.init)
        
        return viewModel.exercises
            .lazy
            .filter { exercise in
                // Tokenized search: All search tokens must be present in the exercise name
                searchText.isEmpty || searchTokens.allSatisfy { token in
                    exercise.name.lowercased().contains(token)
                }
            }
            .filter { exercise in
                // Category filter
                selectedCategory == nil || exercise.category == selectedCategory
            }
            .filter { exercise in
                // Muscle group filter
                selectedMuscleGroup == nil ||
                exercise.primaryMuscles.contains(selectedMuscleGroup!) ||
                exercise.secondaryMuscles.contains(selectedMuscleGroup!)
            }
            .filter { exercise in
                // Equipment filter
                selectedEquipment == nil || exercise.equipment == selectedEquipment
            }
            .filter { exercise in
                // Level filter
                selectedLevel == nil || exercise.level == selectedLevel
            }
            .sorted { $0.name < $1.name } // Optional: Sort alphabetically
            .prefix(50) // Optional: Limit to top 50 results for performance
            .map { $0 } // Convert lazy sequence back to array
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
                            ExerciseRowView(exercise: exercise, selectedExercise: $selectedExercise, isShowingDetail: $isShowingDetail)
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
                    .navigationDestination(
                                isPresented: $isShowingDetail,
                                destination: {
                                    if let exercise = selectedExercise {
                                        ExerciseDetailView(exercise: exercise)
                                    }
                                }
                            )
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
        case .addToTemplate(template: let template):
            for exercise in selectedExercises {
                template.insertExercise(exercise.id)
            }
        case .replaceTemplateExercise(templateExercise: let templateExercise):
            if let exercise = selectedExercises.first {
                templateExercise.exerciseID = exercise.id
                templateExercise.sets.removeAll()
                templateExercise.notes = ""
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
