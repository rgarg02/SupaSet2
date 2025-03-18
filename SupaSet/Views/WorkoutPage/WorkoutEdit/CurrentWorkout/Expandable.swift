//
//  Expandable.swift
//  SupaSet
//
//  Created by Rishi Garg on 3/12/25.
//
import SwiftUI
struct ExpandableWorkout: View {
    @Binding var show: Bool
    @Bindable var workout: Workout
    @State private var dragState = DragState()
    @State private var expandWorkout = false
    @State private var offsetY: CGFloat = 0
    @State private var windowProgress: CGFloat = 0
    @Namespace private var animation
    var body: some View {
        GeometryReader {
            let size = $0.size
            let safeArea = $0.safeAreaInsets
            ZStack(alignment: .top) {
                ZStack{
                    Rectangle()
                        .fill(.primaryThemeColorTwo)
                    Rectangle()
                        .fill(.primaryThemeColorTwo)
                        .opacity(expandWorkout ? 1 : 0)
                }
                .clipShape(.rect(cornerRadius: expandWorkout ? (safeArea.bottom == 0 ? 0 : 45) : 15))
                .frame(height: expandWorkout ? nil : 55)
                .shadow(color: .primary.opacity(0.06), radius: 5, x: 5, y: 5)
                .shadow(color: .primary.opacity(0.05), radius: 5, x: -5, y: -5)
                miniWorkout()
                    .opacity(expandWorkout ? 0 : 1)
                ExpandedWorkout(size, safeArea)
                    .opacity(expandWorkout ? 1 : 0)
            }
            .frame(height: expandWorkout ? nil : 55, alignment: .top)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, expandWorkout ? 0 : safeArea.bottom + 55)
            .padding(.horizontal, expandWorkout ? 0 : 15)
            .offset(y: offsetY)
            .gesture(
                PanGesture { value in
                    guard expandWorkout else { return }
                    
                    let translation = max(value.translation.height, 0)
                    offsetY = translation
                    let progress = min(translation / (UIScreen.main.bounds.height * 0.5), 1)
                    windowProgress = progress * 0.1
                    
//                    withAnimation(.interactiveSpring(duration: 0.01)) {
//                        windowScale = 1 - (0.1 - windowProgress)
//                        windowCorner = windowProgress * 300
//                    }
                } onEnd: { value in
                    guard expandWorkout else { return }
                    
                    let translation = max(value.translation.height, 0)
                    let velocity = value.velocity.height / 5
                    
                    withAnimation(.smooth(duration: 0.2)) {
                        if (translation + velocity) > (UIScreen.main.bounds.height * 0.3) {
                            /// Closing View
                            expandWorkout = false
                            windowProgress = 0
                            /// Resetting Window To Identity With Animation
//                            resetWindowWithAnimation()
                        } else {
                            windowProgress = 0.1
//                            resizeWindow(0.1)
                        }
                        
                        offsetY = 0
                    }
                }
            )
            .ignoresSafeArea()
        }
        .onChange(of: show) { oldValue, newValue in
            if !newValue {
                // When workout is finished or cancelled
                withAnimation(.smooth(duration: 0.3)) {
                    expandWorkout = false
                    windowProgress = 0
                }
//                resetWindowWithAnimation()
            }
        }
    }
    @ViewBuilder
    func miniWorkout() -> some View {
        HStack(spacing: 12) {
            if !expandWorkout {
                HStack(spacing: 12) {
                    // Workout progress indicator
                    CircularProgressView(progress: workout.progress)
                        .frame(width: 32, height: 32)
                        .matchedGeometryEffect(id: "Progress", in: animation)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(workout.name)
                            .multilineTextAlignment(.leading)
                            .font(.headline)
                            .lineLimit(1)
                            .matchedGeometryEffect(id: "Name", in: animation)
                        
                        Text("\(workout.sortedExercises.count) exercises")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .matchedGeometryEffect(id: "ExerciseCount", in: animation)
                    }
                }
            }
            Spacer()
            WorkoutTimer(workout: workout)
        }
        .padding(.horizontal, 10)
        .frame(height: 55)
        .contentShape(.rect)
        .onTapGesture {
            withAnimation(.smooth(duration: 0.3)) {
                expandWorkout = true
            }
//            UIView.animate(withDuration: 0.3) {
//                resizeWindow(0.1)
//            }
        }
    }
    
    @ViewBuilder
    func ExpandedWorkout(_ size: CGSize, _ safeArea: EdgeInsets) -> some View {
        VStack {
            VStack{
                Capsule()
                    .fill(.white.secondary)
                    .frame(width: 35, height: 5)
                    .offset(y: -10)
                ZStack {
                    if expandWorkout{
                        NameSection(item: workout)
                            .matchedGeometryEffect(id: "Name", in: animation)
                    }
                }
            }
            .frame(height: 50)
            DraggableScrollContainer(content: {
                VStack(spacing: 10) {
                    VStack(spacing: 20) {
                        WorkoutTimeSection(workout: workout)
                        NotesSection(item: workout)
                    }
                    ForEach(workout.sortedExercises) { exercise in
                        ExerciseCardView(exercise: exercise)
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
                            item: workout,
                            originalItem: workout,
                            show: $show,
                            isNew: !workout.isFinished
                        )
                    }
                }
                .scrollTargetLayout()
            }, items: workout.sortedExercises)
            .background(Color.theme.background)
        }
        .environmentObject(dragState)
        .padding(.top, safeArea.top + 5)
    }
//    func resizeWindow(_ progress: CGFloat) {
//        let easedProgress = max(0, min(1, progress))
//        let interpolatedScale = 1.0 - (easedProgress * 0.1)
//        let interpolatedCorner = easedProgress * 30
//
//        withAnimation(.interactiveSpring(duration: 0.01)) {
//            windowScale = interpolatedScale
//            windowCorner = interpolatedCorner
//        }
//    }
//
//    func resetWindowWithAnimation() {
//        withAnimation(.interactiveSpring(response: 0.8, dampingFraction: 0.8)) {
//            windowScale = 1.0
//            windowCorner = 0
//        }
//    }
}
#Preview{
    let preview = PreviewContainer.preview
    ExpandableWorkout(show: .constant(true), workout: preview.workout)
        .modelContainer(preview.container)
        .environment(preview.viewModel)
}
