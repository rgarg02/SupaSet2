//
//  ExerciseListView.swift
//  SupaSetGRDB
//
//  Created by Rishi Garg on 4/13/25.
//



import SwiftUI
import SwiftData

//
//  ExerciseListView.swift
//  SupaSet
// ... (imports) ...


struct ExercisesListView: View {
    @StateObject private var viewModel = ExerciseListViewModel()
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.alertController) private var alertController
    // State to control picker visibility (optional, good for complex layouts)
    @State private var showFilters = false
    @State private var isShowingDetail = false
    @State private var selectedExercise : ExerciseRecord?
    @State private var selectedExercises: Set<String> = []
    enum Mode {
        case add(workout: Workout)
        case replace(workoutExercise: WorkoutExercise)
        case addToTemplate(template: Template)
        case replaceTemplateExercise(templateExercise: TemplateExercise)
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
    let mode: Mode
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
    var body: some View {
//        NavigationView {
            VStack(spacing: 0) { // Use spacing 0 to avoid gaps
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        CustomFilterPicker(
                            title: "Categories",
                            selection: $viewModel.selectedCategory,
                            options: viewModel.allCategories // Use precomputed array
                        )
                        CustomFilterPicker(
                            title: "Muscles",
                            selection: $viewModel.selectedMuscleGroup,
                            options: viewModel.allMuscleGroups // Use precomputed array
                        )
                        CustomFilterPicker(
                            title: "Equipments",
                            selection: $viewModel.selectedEquipment,
                            options: viewModel.allEquipment // Use precomputed array
                        )
                        CustomFilterPicker(
                            title: "Levels",
                            selection: $viewModel.selectedLevel,
                            options: viewModel.allLevels // Use precomputed array
                        )
                    }
                    .padding(.horizontal) // Add horizontal padding only
                    .padding(.vertical, 8) // Add some vertical padding
                }
                .background(Color(.systemGroupedBackground)) // Use a slightly different background
                .overlay(Divider(), alignment: .bottom)
                
                // MARK: - List Section
                if let errorMessage = viewModel.errorMessage, !viewModel.isLoading { // Show error only when not loading
                    VStack { // Wrap in VStack for better layout control
                        Spacer()
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(viewModel.exercises, id: \.id) { exercise in
                            ExerciseRowView(exercise: exercise, selectedExercise: $selectedExercise, isShowingDetail: $isShowingDetail)
                                .task {
                                    viewModel.loadMoreExercisesIfNeeded(currentItem: exercise)
                                }
                                .onTapGesture {
                                    handleTap(exercise.id)
                                }
                                .background(selectedExercises.contains(exercise.id) ? Color("PrimaryThemeColor") : Color.background)
                                .foregroundColor(selectedExercises.contains(exercise.id) ? .black : .text)
                        }
                        listFooterView()
                    }
                    .searchable(text: $viewModel.searchText)
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
                    .environmentObject(viewModel)
                    .listStyle(.plain)
                    // Overlay for empty state (when not loading and no error)
                    .overlay {
                        if !viewModel.isLoading && viewModel.exercises.isEmpty && viewModel.errorMessage == nil {
                            Text("No exercises match the selected filters.")
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                                .multilineTextAlignment(.center)
                            
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $isShowingDetail
                                   , destination: {
                if let selectedExercise {
                    ExerciseDetailView(exerciseId: selectedExercise.id)
                }
            })
            .navigationTitle("Exercises")
            // React to filter changes
            .onChange(of: viewModel.selectedCategory) { _, _ in handleFilterChange() }
            .onChange(of: viewModel.selectedMuscleGroup) { _, _ in handleFilterChange() }
            .onChange(of: viewModel.selectedLevel) { _, _ in handleFilterChange() }
            .onChange(of: viewModel.selectedEquipment) { _, _ in handleFilterChange() }
//        }
//        .navigationViewStyle(.stack) // Recommended for consistent behavior
    }
    /// Extracted Footer View builder for clarity
    @ViewBuilder
    private func listFooterView() -> some View {
        // Loading Indicator at the bottom
        if viewModel.isLoading {
            HStack {
                Spacer()
                ProgressView() // Smaller indicator is often enough
                Spacer()
            }
            .padding(.vertical)
            .listRowSeparator(.hidden)
        }
        // Optional: Message when all exercises are loaded AND the list isn't empty
        else if !viewModel.canLoadMorePages && !viewModel.exercises.isEmpty {
            HStack {
                Spacer()
                Text("End of Results")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.vertical)
            .listRowSeparator(.hidden)
        }
        // Implicit else: No footer needed if more pages might exist and not currently loading
    }
    /// Triggers view model update when a filter selection changes.
    private func handleFilterChange() {
        // Perform the async task
        Task {
            await viewModel.filtersDidChange()
        }
    }
    private func handleTap(_ exerciseID: String) {
        if isReplacing {
            selectedExercises = [exerciseID]
        } else {
            if selectedExercises.contains(exerciseID) {
                selectedExercises.remove(exerciseID)
            } else {
                selectedExercises.insert(exerciseID)
            }
        }
    }
    private func handleAction() {
            switch mode {
            case .add(let workout):
                DispatchQueue.global().async {
                    
                }
                for exercise in selectedExercises {
                    let targetExerciseID = exercise
                    // Create a predicate to filter WorkoutExercise entities
                    // 1. Match the exerciseID
                    // 2. Ensure the related Workout is finished (workout.isFinished == true)
                    let predicate = #Predicate<WorkoutExercise> { workoutExercise in
                        workoutExercise.exerciseID == targetExerciseID &&
                        workoutExercise.workout?.isFinished == true
                    }
                    
                    // Create sort descriptors to order the results
                    // Sort by the related Workout's date in descending order to get the latest first
                    let sortByDate = SortDescriptor(\WorkoutExercise.workout?.date, order: .reverse)
                    
                    // Create the FetchDescriptor
                    // Apply the predicate and sorting
                    // Limit the fetch to 1 result to get only the latest WorkoutExercise
                    var descriptor = FetchDescriptor<WorkoutExercise>(predicate: predicate, sortBy: [sortByDate])
                    descriptor.fetchLimit = 1
                    if let lastExercise = try? modelContext.fetch(descriptor).first {
                        let exercise = WorkoutExercise(exerciseID: exercise)
                        exercise.sets.removeAll()
                        for lastSet in lastExercise.sets {
                            let set = ExerciseSet(reps: lastSet.reps, weight: lastSet.weight, type: lastSet.type, rpe: lastSet.rpe, notes: lastSet.notes, order: lastSet.order, isDone: false)
                            exercise.sets.append(set)
                        }
                        workout.exercises.append(exercise)
                    } else {
                        workout.insertExercise(exercise)
                    }
                }
            case .replace(let workoutExercise):
                if let exercise = selectedExercises.first {
                    workoutExercise.exerciseID = exercise
                    workoutExercise.sets.removeAll()
                    workoutExercise.notes = ""
                }
            case .addToTemplate(template: let template):
                for exercise in selectedExercises {
                    template.insertExercise(exercise)
                }
            case .replaceTemplateExercise(templateExercise: let templateExercise):
                if let exercise = selectedExercises.first {
                    templateExercise.exerciseID = exercise
                    templateExercise.sets.removeAll()
                    templateExercise.notes = ""
                }
            }
            loadExerciseDetails()
            selectedExercises = []
        }
    private func loadExerciseDetails() {
            // check if any of the selected exercises already exist in the database
            for exercise in selectedExercises {
                let predicate = #Predicate<ExerciseDetail> { $0.exerciseID == exercise }
                var fetchDescriptor = FetchDescriptor<ExerciseDetail>(predicate: predicate)
                fetchDescriptor.fetchLimit = 1
                // check if atleast one exist
                do {
                    let details = try modelContext.fetch(fetchDescriptor)
                    if details.isEmpty {
                        let newDetail = ExerciseDetail(exerciseID: exercise)
                        modelContext.insert(newDetail)
                    }
                } catch {
                    alertController.present(title: "Failed to load exercise detail", error: error)
                }
            }
        }
}
//
//// Keep ExerciseDetailView and Previews as they were (or adapt previews if needed)
//// ... (ExerciseDetailView and Previews) ...
//
//#if DEBUG
//struct ExerciseListView_Previews: PreviewProvider {
//    static var previews: some View {
//        ExercisesListView(mode: .add)
//    }
//}
//#endif


