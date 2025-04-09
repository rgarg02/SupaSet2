//
//  TemplateView.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/21/25.
//

// CreateRoutineView.swift
import SwiftUI
import SwiftData

struct EditOrCreateTemplateView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.alertController) private var alertController
    // MARK: - Properties
    let originalTemplate: Template?  // Original template for editing
    let isNew: Bool
    @State private var editableTemplate: Template // Working copy
    @State private var discardChanges: Bool = false
    @State private var firstAppear: Bool = true
    @State private var show: Bool = true
    
    // MARK: - Drag and Drop States
    @StateObject private var dragState = DragState()
    
    // MARK: - Computed Properties
    var sortedExercises: [TemplateExercise] {
        editableTemplate.exercises.sorted { $0.order < $1.order }
    }
    
    // MARK: - Initializers
    // Init for editing existing template
    init(template: Template, isNew: Bool = false) {
        self.originalTemplate = template
        self._editableTemplate = State(initialValue: template.copy())
        self.isNew = isNew
    }
    
    // Init for creating new template
    init(isNew: Bool = true) {
        self.originalTemplate = nil
        let newTemplate = Template(order: -1)
        self._editableTemplate = State(initialValue: newTemplate)
        self.isNew = isNew
    }
    
    private var hasChanges: Bool {
        guard let originalTemplate = originalTemplate else {
            // If there's no original template (new template case)
            return !editableTemplate.name.isEmpty || !editableTemplate.exercises.isEmpty
        }
        
        return !originalTemplate.isContentEqual(to: editableTemplate)
    }
    
    // MARK: - Body
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                TopControls(template: editableTemplate, show: $show, isNew: isNew)
                    .frame(height: 55)
                    .background(.ultraThinMaterial)
                TemplateScrollView()
                    .sensoryFeedback(.impact, trigger: dragState.hapticFeedback)
            }
        }
        .onAppear {
            if firstAppear {
                if let template = originalTemplate {
                    editableTemplate = template.copy()
                } else {
                    let newTemplate = Template(order: editableTemplate.order)
                    editableTemplate = newTemplate
                }
                firstAppear.toggle()
            }
        }
        .onChange(of: show) { _, newValue in
            checkForChanges(newValue: newValue)
        }
        .onChange(of: discardChanges) { _, newValue in
            if newValue == true {
                dismiss()
                show.toggle()
                discardChanges.toggle()
                firstAppear.toggle()
            }
        }
        .interactiveDismissDisabled(true)
        .cornerRadius(8)
        .navigationBarBackButtonHidden(true)
        .dismissKeyboardOnTap()
        .environmentObject(dragState)
    }
    
    func checkForChanges(newValue: Bool) {
        if newValue == false {
            if hasChanges {
                let buttons = [
                    AlertButton(title: "Discard Changes", role: .destructive, action: {
                        discardChanges = true
                    }),
                    AlertButton(title: "Go Back", role: .cancel, action: {
                        show.toggle()
                    })
                ]
                alertController.present(.alert, title: "Discard Changes?", message: "Discard changes made to \(editableTemplate.name)", buttons: buttons)
            } else {
                dismiss()
                show.toggle()
                firstAppear.toggle()
            }
        }
    }
    
    @ViewBuilder
    func TemplateScrollView() -> some View {
        ScrollView {
            LazyVStack {
                NameSection(item: editableTemplate)
                NotesSection(item: editableTemplate)
                ForEach(sortedExercises) { exercise in
                    TemplateExerciseView(templateExercise: exercise)
                }
                CancelFinishAddView(item: editableTemplate, originalItem: originalTemplate, show: .constant(true), isNew: isNew, onSave: saveChanges)
            }
            .padding()
        }
        .background(.thickMaterial)
        .scrollIndicators(.hidden)
    }
    
    // MARK: - Methods
    private func saveChanges() {
        if isNew {
            modelContext.insert(editableTemplate)
        } else if let originalTemplate = originalTemplate {
            // Update existing template
            originalTemplate.name = editableTemplate.name
            originalTemplate.notes = editableTemplate.notes
            
            // Clear existing exercises
            originalTemplate.exercises.forEach { modelContext.delete($0) }
            
            // Add copied exercises
            originalTemplate.exercises = editableTemplate.exercises.map { exercise in
                let newExercise = exercise.copy()
                return newExercise
            }
        }
        
        try? modelContext.save()
        dismiss()
    }
}

// Exercise view component
struct TemplateExerciseView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var templateExercise: TemplateExercise
    @Environment(ExerciseViewModel.self) private var viewModel
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Exercise header
            ExerciseTopControls(exercise: templateExercise, dragging: false)
            // Set header
            VStack(spacing: 4) {
                // Column headers
                SetColumnNamesView(exerciseID: templateExercise.exerciseID, isTemplate: true)
                
                // Sets list
                ForEach(sortedSets) { set in
                    @Bindable var set = set
                    let order = templateExercise.sets.lazy
                        .filter { $0.type == .working && $0.order < set.order }
                        .count
                    SwipeAction(cornerRadius: 8, direction: .trailing) {
                        SetRowViewCombined(order: order, isTemplate: true, weight: $set.weight, reps: $set.reps, isDone: .constant(false), type: $set.type, exerciseID: templateExercise.exerciseID)
                    } actions: {
                        Action(tint: .red, icon: "trash.fill") {
                            withAnimation(.easeInOut) {
                                // Update orders of following sets before deleting
                                let setOrder = set.order
                                let setsToUpdate = templateExercise.sets.filter { $0.order > setOrder }
                                
                                for setToUpdate in setsToUpdate {
                                    setToUpdate.order -= 1
                                }
                                templateExercise.deleteSet(set)
                                modelContext.delete(set)
                            }
                        }
                    }
                }
                // Add set button
                PlaceholderSetRowView(templateSet: false) {
                    withAnimation(.snappy(duration: 0.25)) {
                        let lastSet = sortedSets.last
                        templateExercise.insertSet(reps: lastSet?.reps ?? 0)
                    }
                }
            }
            .padding(.vertical)
        }
    }
    private var sortedSets: [TemplateExerciseSet] {
        templateExercise.sets.sorted(by: { $0.order < $1.order })
    }
}
#Preview{
    let preview = PreviewContainer.preview
    NavigationStack {
        EditOrCreateTemplateView(template: preview.template, isNew: true)
            .modelContainer(preview.container)
            .environment(preview.viewModel)
    }
}
