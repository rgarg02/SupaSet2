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
                    .frame(height: 60)
                    .background(Color.theme.primarySecond)
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
        .ignoresSafeArea(.keyboard, edges: .bottom)
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
        DraggableScrollContainer(
            content: {
                LazyVStack {
                    NameSection(item: editableTemplate)
                    NotesSection(item: editableTemplate)
                    
                    ForEach(sortedExercises) { exercise in
                        TemplateExerciseCard(templateExercise: exercise)
                            .id(exercise.id)
                            .opacity(dragState.selectedExercise?.id == exercise.id ? 0 : 1)
                            .measureFrame { newFrame in
                                dragState.itemFrames[exercise.id] = newFrame
                                if dragState.selectedExercise?.id == exercise.id {
                                    dragState.selectedItemFrame = newFrame
                                }
                            }
                    }
                    
                    if !dragState.isDragging {
                        CancelFinishAddView(
                            item: editableTemplate,
                            originalItem: originalTemplate,
                            show: .constant(true),
                            isNew: isNew,
                            onSave: saveChanges
                        )
                    }
                }
                .scrollTargetLayout()
            },
            items: sortedExercises
        )
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
    
    func checkAndSwapItems(_ location: CGPoint) {
        guard let selectedExercise = dragState.selectedExercise as? TemplateExercise else { return }
        
        let centeredLocation = CGPoint(
            x: dragState.parentFrame.midX,
            y: location.y
        )
        
        let targetExercise = editableTemplate.exercises.first { exercise in
            guard exercise.id != selectedExercise.id else { return false }
            let frame = dragState.itemFrames[exercise.id] ?? .zero
            return centeredLocation.y >= frame.minY && centeredLocation.y <= frame.maxY
        }
        
        guard let targetExercise = targetExercise else { return }
        
        let currentIndex = selectedExercise.order
        let targetIndex = targetExercise.order
        
        guard currentIndex != targetIndex else { return }
        
        dragState.hapticFeedback.toggle()
        
        withAnimation(.snappy(duration: 0.25, extraBounce: 0)) {
            selectedExercise.order = targetIndex
            targetExercise.order = currentIndex
        }
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
