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
    @State private var containerScale: CGFloat = 1.0
    @State private var containerCornerRadius: CGFloat = 0
    @Binding var mainWindow: UIWindow?
    @State private var windowProgress: CGFloat = 0
    var body: some View {
        GeometryReader {
            let size = $0.size
            let safeArea = $0.safeAreaInsets
            ZStack(alignment: .top) {
                ZStack{
                    Rectangle()
                        .fill(Color.theme.primary)
                    Rectangle()
                        .fill(Color.theme.background)
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
                    windowProgress = max(min(translation / size.height, 1), 0) * 0.1
                    
                    resizeWindow(0.1 - windowProgress)
                } onEnd: { value in
                    guard expandWorkout else { return }
                    
                    let translation = max(value.translation.height, 0)
                    let velocity = value.velocity.height / 5
                    
                    withAnimation(.smooth(duration: 0.3, extraBounce: 0)) {
                        if (translation + velocity) > (size.height * 0.5) {
                            /// Closing View
                            expandWorkout = false
                            windowProgress = 0
                            /// Resetting Window To Identity With Animation
                            resetWindowWithAnimation()
                        } else {
                            /// Reset Window To 0.1 With Animation
                            UIView.animate(withDuration: 0.3) {
                                resizeWindow(0.1)
                            }
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
                resetWindowWithAnimation()
            }
        }
    }
    @ViewBuilder
    func miniWorkout() -> some View {
        HStack(spacing: 12) {
            Image(systemName: "plus")
                .foregroundColor(.theme.text)
                .font(.title3)
            
            Text("Workout")
                .foregroundColor(.theme.text)
                .font(.title3)
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .frame(height: 55)
        .contentShape(.rect)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.theme.accent)
        )
        .onTapGesture {
            withAnimation(.smooth(duration: 0.3)) {
                expandWorkout = true
            }
            UIView.animate(withDuration: 0.3) {
                resizeWindow(0.1)
            }
        }
    }
    
    @ViewBuilder
    func ExpandedWorkout(_ size: CGSize, _ safeArea: EdgeInsets) -> some View {
        VStack {
            Capsule()
                .fill(.white.secondary)
                .frame(width: 35, height: 5)
                .offset(y: -10)
            DraggableScrollContainer(content: {
                VStack(spacing: 10) {
                    WorkoutInfoView(workout: workout)
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
        }
        .environmentObject(dragState)
        .padding(.top, safeArea.top + 5)
    }
    func resizeWindow(_ progress: CGFloat) {
        if let mainWindow = mainWindow?.subviews.first {
            let offsetY = (mainWindow.frame.height * progress) / 2
            
            /// Your Custom Corner Radius
            mainWindow.layer.cornerRadius = (progress / 0.1) * 30
            mainWindow.layer.masksToBounds = true
            
            mainWindow.transform = .identity.scaledBy(x: 1 - progress, y: 1 - progress).translatedBy(x: 0, y: offsetY)
        }
    }
    
    func resetWindowWithAnimation() {
        if let mainWindow = mainWindow?.subviews.first {
            UIView.animate(withDuration: 0.3) {
                mainWindow.layer.cornerRadius = 0
                mainWindow.transform = .identity
            }
        }
    }
}
//#Preview{
//    let preview = PreviewContainer.preview
//    ExpandableWorkout(show: .constant(true), workout: preview.workout)
//        .modelContainer(preview.container)
//        .environment(preview.viewModel)
//}
