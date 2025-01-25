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
    // MARK: - Drag and Drop States
    @State var dragging: Bool = false
    @State internal var selectedExercise: TemplateExercise?
    @State internal var selectedExerciseScale: CGFloat = 1.0
    @State internal var selectedExerciseFrame: CGRect = .zero
    @State internal var offset: CGSize = .zero
    @State internal var hapticsTrigger: Bool = false
    @State internal var initialScrollOffset: CGRect = .zero
    @State internal var scrolledExercise: TemplateExercise.ID?
    @State internal var currentScrollId: UUID?
    @State internal var scrollTimer: Timer?
    @State internal var topRegion: CGRect = .zero
    @State internal var bottomRegion: CGRect = .zero
    @State internal var lastActiveScrollId: UUID?
    @State internal var parentFrame: CGRect = .zero
    @State internal var exerciseFrames: [UUID: CGRect] = [:]
    @State private var show: Bool = true
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
                    .sensoryFeedback(.impact, trigger: hapticsTrigger)
            }
        }
        .onAppear {
            if firstAppear{
                if let template = originalTemplate {
                    editableTemplate = template.copy()
                } else {
                    let newTemplate = Template(order: editableTemplate.order)
                    newTemplate.createdAt = Date()
                    newTemplate.name = ""
                    newTemplate.notes = ""
                    newTemplate.exercises = []
                    editableTemplate = newTemplate
                }
                firstAppear.toggle()
            }
        }
        .onChange(of: show, { oldValue, newValue in
            checkForChanges(newValue: newValue)
        })
        .onChange(of: discardChanges, { oldValue, newValue in
            if newValue == true {
                dismiss()
                show.toggle()
                discardChanges.toggle()
                firstAppear.toggle()
            }
        })
        .interactiveDismissDisabled(true)
        .cornerRadius(8)
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .dismissKeyboardOnTap()
    }
    func checkForChanges(newValue: Bool) {
        if newValue == false {
            if hasChanges {
                let buttons = [
                    AlertButton(title: "Discard Changes",role: .destructive, action: {
                        discardChanges = true
                    }),
                    AlertButton(title: "Go Back", role: .cancel, action: {
                        show.toggle()
                    })
                ]
                alertController.present(.alert, title: "Discard Changes?", message: "Discard changes make to \(editableTemplate.name)", buttons: buttons)
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
            content: VStack(spacing: 0) {
                LazyVStack {
                    NameSection(item: editableTemplate)
                    NotesSection(item: editableTemplate)
                    
                    ForEach(sortedExercises) { exercise in
                        TemplateExerciseCard(
                            templateExericse: exercise,
                            selectedExercise: $selectedExercise,
                            selectedExerciseScale: $selectedExerciseScale,
                            selectedExerciseFrame: $selectedExerciseFrame,
                            offset: $offset,
                            hapticsTrigger: $hapticsTrigger,
                            initialScrollOffset: $initialScrollOffset,
                            lastActiveScrollId: $lastActiveScrollId,
                            dragging: $dragging,
                            parentBounds: $parentFrame,
                            exerciseFrames: $exerciseFrames,
                            onScroll: checkAndScroll,
                            onSwap: checkAndSwapItems
                        )
                        .id(exercise.id)
                        .opacity(selectedExercise?.id == exercise.id ? 0 : 1)
                        .onGeometryChange(for: CGRect.self) {
                            $0.frame(in: .global)
                        } action: { newValue in
                            if selectedExercise?.id == exercise.id {
                                selectedExerciseFrame = newValue
                            }
                            exerciseFrames[exercise.id] = newValue
                        }
                    }
                    
                    CancelFinishAddView(
                        item: editableTemplate,
                        originalItem: originalTemplate,
                        show: .constant(true),
                        isNew: isNew,
                        onSave: saveChanges
                    )
                    .opacity(dragging ? 0 : 1)
                }
                .scrollTargetLayout()
            },
            items: sortedExercises,
            selectedItem: $selectedExercise,
            selectedItemScale: $selectedExerciseScale,
            selectedItemFrame: $selectedExerciseFrame,
            offset: $offset,
            hapticsTrigger: $hapticsTrigger,
            initialScrollOffset: $initialScrollOffset,
            scrolledItem: $scrolledExercise,
            lastActiveScrollId: $lastActiveScrollId,
            dragging: $dragging,
            parentFrame: $parentFrame,
            itemFrames: $exerciseFrames,
            topRegion: $topRegion,
            bottomRegion: $bottomRegion,
            onScroll: checkAndScroll,
            onSwap: checkAndSwapItems
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
    func checkAndScroll(_ location: CGPoint) {
        let centeredLocation = CGPoint(
            x: parentFrame.midX,
            y: location.y
        )
        
        let topStatus = topRegion.contains(centeredLocation)
        let bottomStatus = bottomRegion.contains(centeredLocation)
        
        if !topStatus && !bottomStatus {
            scrollTimer?.invalidate()
            scrollTimer = nil
            return
        }
        
        guard scrollTimer == nil else { return }
        
        scrollTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            guard let currentIndex = sortedExercises.firstIndex(where: { $0.id == selectedExercise?.id }) else { return }
            
            var nextIndex = currentIndex
            
            if topStatus {
                nextIndex = max(currentIndex - 1, 0)
            } else {
                nextIndex = min(currentIndex + 1, sortedExercises.count - 1)
            }
            
            guard nextIndex != currentIndex else {
                scrollTimer?.invalidate()
                scrollTimer = nil
                return
            }
            
            lastActiveScrollId = sortedExercises[nextIndex].id
            withAnimation(.smooth(duration: 0.1)) {
                scrolledExercise = lastActiveScrollId
            }
        }
    }
    
    func checkAndSwapItems(_ location: CGPoint) {
        guard let currentExercise = editableTemplate.exercises.first(where: { $0.id == selectedExercise?.id }) else { return }
        
        let centeredLocation = CGPoint(
            x: parentFrame.midX,
            y: location.y
        )
        
        let fallingExercise = editableTemplate.exercises.first { exercise in
            guard exercise.id != currentExercise.id else { return false }
            let frame = exerciseFrames[exercise.id] ?? .zero
            return centeredLocation.y >= frame.minY && centeredLocation.y <= frame.maxY
        }
        
        guard let fallingExercise = fallingExercise else { return }
        
        let currentIndex = currentExercise.order
        let fallingIndex = fallingExercise.order
        
        guard currentIndex != fallingIndex else { return }
        hapticsTrigger.toggle()
        withAnimation(.snappy(duration: 0.25, extraBounce: 0)) {
            currentExercise.order = fallingIndex
            fallingExercise.order = currentIndex
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
