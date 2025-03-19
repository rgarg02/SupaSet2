//
//  ExerciseListPickerView.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/6/24.
//
import SwiftUI
import SwiftData
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
    @Binding var show: Bool

    // Initialize for adding exercises
    init(workout: Workout, show: Binding<Bool>) {
        self.mode = .add(workout: workout)
        self._show = show
    }
    
    // Initialize for replacing an exercise
    init(workoutExercise: WorkoutExercise, show: Binding<Bool>) {
        self.mode = .replace(workoutExercise: workoutExercise)
        self._show = show
    }
    
    // Initialize for adding a template
    init(template: Template, show: Binding<Bool>) {
        self.mode = .addToTemplate(template: template)
        self._show = show
    }
    
    // Initialize for replacing a template exercise
    init(templateExercise: TemplateExercise, show: Binding<Bool>) {
        self.mode = .replaceTemplateExercise(templateExercise: templateExercise)
        self._show = show
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
        GeometryReader { geometry in
            ZStack {
                // Blur background
                Rectangle()
                    .fill(.ultraThinMaterial.opacity(0.7))
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.smooth(duration: 0.25)) {
                            show = false
                        }
                    }
                
                VStack(spacing: 0) {
                    // Custom Navigation Bar
                    HStack {
                        Button(action: {
                            withAnimation(.smooth(duration: 0.25)) {
                                show = false
                            }
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.primary)
                                .padding()
                        }
                        
                        Spacer()
                    
                        
                        if !selectedExercises.isEmpty {
                            Button(action: {
                                handleAction()
                                show = false
                            }) {
                                Text(isReplacing ? "Replace" : "Add (\(selectedExercises.count))")
                                    .foregroundColor(.theme.accent)
                                    .padding()
                            }
                        }
                    }
                    .overlay(alignment: .center, content: {
                        Text(isReplacing ? "Replace Exercise" : "Add Exercises")
                            .font(.headline)
                    })
                    .background(Color.theme.background)
                    
                    // Filter Section
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
                    .background(Color.theme.background)
                    .overlay(
                        Divider(),
                        alignment: .bottom
                    )
                    
                    // Exercise List
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
                                .background(selectedExercises.contains(exercise) ? Color.themePrimarySecond : Color.theme.background)
                                .foregroundStyle(selectedExercises.contains(exercise) ? Color.themePrimarySecond.bestTextColor() : Color.theme.background.bestTextColor())
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    handleExerciseSelection(exercise)
                                }
                        }
                    }
                    .listStyle(.plain)
                    .searchable(text: $searchText, prompt: "Search exercises")
                }
                .frame(
                    width: geometry.size.width * 0.9,
                    height: geometry.size.height * 0.8
                )
                .background(Color.theme.background)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 10)
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
            WorkoutActivityManager.shared.updateWorkoutActivity(workout: workout)
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
    ExerciseListPickerView(workout: preview.workout, show: .constant(true))
        .environment(preview.viewModel)
        .modelContainer(preview.container)
}
#Preview("Exercise List Picker - Replace Mode") {
    let preview = PreviewContainer.preview
    ExerciseListPickerView(workoutExercise: preview.workout.sortedExercises[0], show: .constant(true))
        .environment(preview.viewModel)
        .modelContainer(preview.container)
}
