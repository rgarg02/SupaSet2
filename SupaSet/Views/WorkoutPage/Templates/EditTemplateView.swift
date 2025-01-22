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
    @State var dragging: Bool = false
    @Bindable var template: Template
    let isNew: Bool
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
    var sortedExercises: [TemplateExercise] {
        template.exercises.sorted { $0.order < $1.order }
    }

    var body: some View {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    TopControls(template: template, isNew: isNew)
                    DraggableScrollContainer(
                        content: VStack(spacing: 0) {
                            LazyVStack{
                                NameSection(item: template)
                                NotesSection(item: template)
                                ForEach(sortedExercises) { exercise in
                                    TemplateExerciseCard(templateExericse: exercise, selectedExercise: $selectedExercise, selectedExerciseScale: $selectedExerciseScale, selectedExerciseFrame: $selectedExerciseFrame, offset: $offset, hapticsTrigger: $hapticsTrigger, initialScrollOffset: $initialScrollOffset, lastActiveScrollId: $lastActiveScrollId, dragging: $dragging, parentBounds: $parentFrame, exerciseFrames: $exerciseFrames, onScroll: checkAndScroll, onSwap: checkAndSwapItems)
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
                    .sensoryFeedback(.impact, trigger: hapticsTrigger)
                }
                NavigationLink {
                    ExerciseListPickerView(template: template)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .foregroundColor(.theme.text)
                            .font(.title3)
                        
                        Text("Add Exercises")
                            .foregroundColor(.theme.text)
                            .font(.title3)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color.theme.accent)
                    )
                }
                .padding(.horizontal, 50.0)
                .padding(.vertical)
            }
            .navigationBarBackButtonHidden(true)
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .dismissKeyboardOnTap()
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
        guard let currentExercise = template.exercises.first(where: { $0.id == selectedExercise?.id }) else { return }
        
        let centeredLocation = CGPoint(
            x: parentFrame.midX,
            y: location.y
        )
        
        let fallingExercise = template.exercises.first { exercise in
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
