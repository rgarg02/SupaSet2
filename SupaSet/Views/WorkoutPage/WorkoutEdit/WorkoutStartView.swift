//
//  WorkoutStartView.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/5/24.
//

import SwiftUI
import SwiftData
import ActivityKit
// MARK: - WorkoutStartView
struct WorkoutStartView: View {
    let namespace: Namespace.ID
    @Binding var isExpanded: Bool
    @State var offsetY: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0
    @Bindable var workout: Workout
    @Environment(ExerciseViewModel.self) var exerciseViewModel
    @Environment(\.modelContext) var modelContext
    @State private var showExercisePicker = false
    @FocusState var focused: Bool
    @State var scrolledExercise: Int?
    
    // Constants
    private let dismissThreshold: CGFloat = 100
    private let maxDragDistance: CGFloat = 300
    private let buttonSize: CGFloat = 60
    
    var body: some View {
        GeometryReader { geometry in
            let progress = min(max(offsetY / maxDragDistance, 0), 1)
            let metrics = calculateViewMetrics(geometry: geometry, progress: progress)
            
            NavigationView {
                ZStack(alignment: .bottom) {
                    backgroundLayer(progress: progress)
                    
                    WorkoutContentView(
                        workout: workout,
                        isExpanded: $isExpanded,
                        scrollOffset: scrollOffset,
                        scrolledExercise: $scrolledExercise,
                        focused: $focused,
                        progress: progress,
                        showExercisePicker: $showExercisePicker
                    )
                }
                .matchedGeometryEffect(id: "icon", in: namespace)
                .ignoresSafeArea(.keyboard)
                .toolbar {
                    if focused {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") {
                                focused = false
                            }
                        }
                    }
                }
            }
            .overlay {
                if showExercisePicker {
                    ExercisePickerOverlay(
                        isPresented: $showExercisePicker,
                        workout: workout,
                        width: metrics.width,
                        height: metrics.height
                    )
                    .transition(.move(edge: .trailing))
                }
            }
            .workoutActivityHandling(workout: workout)
            .frame(width: metrics.width, height: metrics.height)
            .cornerRadius(progress * 30)
            .position(x: metrics.currentX, y: metrics.currentY)
            .gesture(createDragGesture())
        }
    }
    
    private func calculateViewMetrics(geometry: GeometryProxy, progress: CGFloat) -> ViewMetrics {
        let width = geometry.size.width * (1 - progress) + buttonSize * progress
        let height = geometry.size.height * (1 - progress) + buttonSize * progress
        
        let startX = geometry.size.width / 2
        let startY = geometry.size.height / 2
        let endX = geometry.size.width - (buttonSize / 2) - 20
        let endY = geometry.size.height - (buttonSize / 2) - 100
        
        let currentX = startX + (endX - startX) * progress
        let currentY = startY + (endY - startY) * progress
        
        return ViewMetrics(width: width, height: height, currentX: currentX, currentY: currentY)
    }
    
    private func backgroundLayer(progress: CGFloat) -> some View {
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
    
    private func createDragGesture() -> some Gesture {
        DragGesture()
            .onChanged { value in
                let startPoint = value.startLocation.y
                if startPoint < 100 && value.translation.height > 0 {
                    offsetY = value.translation.height
                }
            }
            .onEnded { value in
                let startPoint = value.startLocation.y
                if startPoint < 100 {
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
            }
    }
}

// MARK: - WorkoutContentView


// MARK: - Supporting Views
struct DragIndicator: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 2.5)
            .fill(.gray)
            .frame(width: 40, height: 5)
    }
}

// MARK: - Supporting Structs and Extensions
struct ViewMetrics {
    let width: CGFloat
    let height: CGFloat
    let currentX: CGFloat
    let currentY: CGFloat
}

extension View {
    
    func workoutActivityHandling(workout: Workout) -> some View {
        self
            .onChange(of: workout.name) { _, _ in
                WorkoutActivityManager.shared.updateWorkoutActivity(workout: workout)
            }
            .onChange(of: workout.exercises.count) { _, _ in
                WorkoutActivityManager.shared.updateWorkoutActivity(workout: workout)
            }
            .onAppear {
                WorkoutActivityManager.shared.startWorkoutActivity(workout: workout)
            }
            .onDisappear {
                WorkoutActivityManager.shared.endWorkoutActivity()
            }
    }
    
    func scrollOffsetTracking(scrollOffset: CGFloat) -> some View {
        self.overlay {
            GeometryReader { proxy in
                let minY = proxy.frame(in: .scrollView(axis: .vertical)).minY
                Color.clear
                    .preference(key: OffsetKey.self, value: minY)
            }
        }
        .onPreferenceChange(OffsetKey.self) { value in
            withAnimation(.easeInOut(duration: 0.2)) {
                _ = -value // Use scrollOffset here if needed
            }
        }
    }
}
#Preview {
    let previewContainer = PreviewContainer.preview
    let namespace = Namespace().wrappedValue
    
    return WorkoutStartView(
        namespace: namespace,
        isExpanded: .constant(true),
        workout: previewContainer.workout
    )
    .modelContainer(previewContainer.container)
    .environment(previewContainer.viewModel)
}
