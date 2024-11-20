import SwiftUI
import SwiftData
import ActivityKit

struct WorkoutStartView: View {
    // MARK: - Properties
    
    // View State
    @Binding var isExpanded: Bool
    @State private var offsetY: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var showExercisePicker = false
    @State private var activityID: String?
    @State var scrolledExercise: Int?
    @FocusState var focused: Bool
    
    // Constants
    private let dismissThreshold: CGFloat = 100
    private let maxDragDistance: CGFloat = 300
    private let buttonSize: CGFloat = 60
    
    // Dependencies
    let namespace: Namespace.ID
    @Bindable var workout: Workout
    @Environment(ExerciseViewModel.self) var exerciseViewModel
    @Environment(\.modelContext) var modelContext
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            let transitionProgress = calculateTransitionProgress(geometry)
            let dimensions = calculateViewDimensions(geometry, progress: transitionProgress)
            let position = calculatePosition(geometry, progress: transitionProgress)
            
            NavigationView {
                mainContent(geometry: geometry, progress: transitionProgress)
                    .frame(width: dimensions.width, height: dimensions.height)
                    .cornerRadius(transitionProgress * 30)
                    .shadow(color: Color.theme.primary.opacity(0.5), radius: 10 * (1 - transitionProgress))
                    .position(x: position.x, y: position.y)
                    .gesture(createDragGesture())
            }
        }
    }
    
    // MARK: - View Components
    
    private func mainContent(geometry: GeometryProxy, progress: CGFloat) -> some View {
        ZStack(alignment: .bottom) {
            backgroundLayers(progress)
            if progress < 1 {
                VStack {
                    dragHandle(progress)
                    WorkoutTopControls(workout: workout, isExpanded: $isExpanded, scrollOffset: scrollOffset)
                    workoutScrollView
                    addExercisesButton(progress)
                }
            }
        }
        .matchedGeometryEffect(id: "icon", in: namespace)
        .ignoresSafeArea(.keyboard)
        .toolbar { keyboardToolbar }
        .overlay { exercisePickerOverlay(width: geometry.size.width, height: geometry.size.height) }
        .onAppear { setupWorkoutActivity() }
        .onDisappear { WorkoutActivityManager.shared.endWorkoutActivity() }
        .setupWorkoutActivityUpdates(workout: workout)
    }
    
    private func backgroundLayers(_ progress: CGFloat) -> some View {
        ZStack {
            Color.theme.background
                .matchedGeometryEffect(id: "background", in: namespace)
            if progress != 0 {
                Color.theme.primary
                    .matchedGeometryEffect(id: "background", in: namespace)
                    .opacity(progress)
            }
        }
    }
    
    private func dragHandle(_ progress: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 2.5)
            .fill(.gray)
            .frame(width: 40, height: 5)
            .opacity(1 - progress)
    }
    
    private var workoutScrollView: some View {
        ScrollView {
            VStack {
                WorkoutInfoView(workout: workout)
                exercisesList
            }
            .scrollTargetLayout()
            .padding(.horizontal, 10)
            .setupScrollOffsetTracking(scrollOffset: $scrollOffset)
        }
        .contentMargins(.vertical, 50)
        .overlay(alignment: .trailing) {
            WorkoutProgressDots(
                totalExercises: workout.exercises.count,
                currentExerciseIndex: scrolledExercise ?? 0
            )
        }
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $scrolledExercise)
    }
    
    private var exercisesList: some View {
        ForEach(workout.sortedExercises, id: \.self) { exercise in
            ExerciseCardView(
                workout: workout,
                workoutExercise: exercise,
                focused: $focused
            )
            .scrollTransition { content, phase in
                content
                    .opacity(phase.isIdentity ? 1.0 : 0.5)
                    .scaleEffect(x: phase.isIdentity ? 1.0 : 0.9, y: phase.isIdentity ? 1.0 : 0.9)
            }
            .onChange(of: exercise.sets.count) { _, _ in
                WorkoutActivityManager.shared.updateWorkoutActivity(workout: workout)
            }
            .containerRelativeFrame(.vertical, alignment: .center)
            .id(exercise.order)
        }
    }
    
    private func addExercisesButton(_ progress: CGFloat) -> some View {
        CustomButton(
            icon: "plus.circle",
            title: "Add Exercises",
            style: .filled(),
            action: { withAnimation { showExercisePicker = true } }
        )
        .opacity(1 - progress)
        .padding(.horizontal, 50.0)
        .padding(.vertical)
    }
    
    private var keyboardToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            if focused {
                Spacer()
                Button("Done") { focused = false }
            }
        }
    }
    
    private func exercisePickerOverlay(width: CGFloat, height: CGFloat) -> some View {
        Group {
            if showExercisePicker {
                Color.background.opacity(0.75)
                    .onTapGesture {
                        withAnimation { showExercisePicker = false }
                    }
                ExerciseListPickerView(
                    isPresented: $showExercisePicker,
                    workout: workout
                )
                .shadow(radius: 10)
                .ignoresSafeArea()
                .frame(width: width * 0.9, height: height * 0.6)
                .transition(.move(edge: .trailing))
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func calculateTransitionProgress(_ geometry: GeometryProxy) -> CGFloat {
        min(max(offsetY / maxDragDistance, 0), 1)
    }
    
    private func calculateViewDimensions(_ geometry: GeometryProxy, progress: CGFloat) -> (width: CGFloat, height: CGFloat) {
        let width = geometry.size.width * (1 - progress) + buttonSize * progress
        let height = geometry.size.height * (1 - progress) + buttonSize * progress
        return (width, height)
    }
    
    private func calculatePosition(_ geometry: GeometryProxy, progress: CGFloat) -> CGPoint {
        let startX = geometry.size.width / 2
        let startY = geometry.size.height / 2
        let endX = geometry.size.width - (buttonSize / 2) - 20
        let endY = geometry.size.height - (buttonSize / 2) - 100
        
        let currentX = startX + (endX - startX) * progress
        let currentY = startY + (endY - startY) * progress
        
        return CGPoint(x: currentX, y: currentY)
    }
    
    private func createDragGesture() -> some Gesture {
        DragGesture()
            .onChanged { value in
                handleDragChange(value)
            }
            .onEnded { value in
                handleDragEnd(value)
            }
    }
    
    private func handleDragChange(_ value: DragGesture.Value) {
        let startPoint = value.startLocation.y
        if startPoint < 100 && value.translation.height > 0 {
            offsetY = value.translation.height
        }
    }
    
    private func handleDragEnd(_ value: DragGesture.Value) {
        guard value.startLocation.y < 100 else { return }
        
        if value.translation.height > dismissThreshold {
            withAnimation(.easeOut(duration: 0.3)) {
                offsetY = maxDragDistance
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isExpanded = false
            }
        } else {
            withAnimation(.spring()) {
                offsetY = 0
            }
        }
    }
    
    private func setupWorkoutActivity() {
        WorkoutActivityManager.shared.startWorkoutActivity(workout: workout)
    }
}

// MARK: - View Modifiers

extension View {
    func setupScrollOffsetTracking(scrollOffset: Binding<CGFloat>) -> some View {
        self.overlay {
            GeometryReader { proxy in
                let minY = proxy.frame(in: .scrollView(axis: .vertical)).minY
                Color.clear
                    .preference(key: OffsetKey.self, value: minY)
            }
        }
        .onPreferenceChange(OffsetKey.self) { value in
            withAnimation(.easeInOut(duration: 0.2)) {
                scrollOffset.wrappedValue = -value
            }
        }
    }
    
    func setupWorkoutActivityUpdates(workout: Workout) -> some View {
        self
            .onChange(of: workout.name) { _, _ in
                WorkoutActivityManager.shared.updateWorkoutActivity(workout: workout)
            }
            .onChange(of: workout.exercises.count) { _, _ in
                WorkoutActivityManager.shared.updateWorkoutActivity(workout: workout)
            }
    }
}

// MARK: - Preview

#Preview {
    let previewContainer = PreviewContainer.preview
    let namespace = Namespace().wrappedValue
    
    WorkoutStartView(
        isExpanded: .constant(true), namespace: namespace,
        workout: previewContainer.workout
    )
    .modelContainer(previewContainer.container)
    .environment(previewContainer.viewModel)
}
