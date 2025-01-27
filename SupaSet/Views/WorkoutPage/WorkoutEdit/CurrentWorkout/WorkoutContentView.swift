//
//  WorkoutContentView.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/21/24.
//

import SwiftUI


struct WorkoutContentView: View {
    @Bindable var workout: Workout
    @Binding var show: Bool
    
    // Add state variables to track the drag
    @State private var offset: CGFloat = 0
    @State private var isDragging = false
    // Add a constant for the minimum height when collapsed
    private let minHeight: CGFloat = 60 // Adjust this value based on WorkoutTopControls height
    var onDragProgress: (CGFloat) -> Void
    var onDragEnded: (Bool) -> Void
    var body: some View {
        GeometryReader { geometry in
            let maxOffset = geometry.size.height - minHeight
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        DragIndicator()
//                            .opacity(show ? 1 : 0)
                        TopControls(
                            workout: workout,
                            show: $show,
                            offset: $offset
                        )
                        Spacer()
                        Divider()
                    }
                    .foregroundStyle(Color.theme.text)
                    .background(Color.theme.primarySecond)
                    .frame(maxHeight: minHeight)
                    .frame(height: minHeight)
                    ScrollContentView(workout: workout, exercises: $workout.exercises, show: $show)
//                        .opacity(show ? 1 : 0)
                }
                .background(Color.theme.background)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .dismissKeyboardOnTap()
            .background(Color.theme.background)
            .cornerRadius(8)
            .offset(y: offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isDragging = true
                        let dragAmount = value.translation.height
                        
                        // If at bottom (maxOffset), calculate offset from bottom up
                        if offset == maxOffset {
                            // When starting from bottom, subtract drag amount from maxOffset
                            offset = min(max(maxOffset + dragAmount, 0), maxOffset)
                        } else {
                            // Normal dragging from top
                            offset = min(max(dragAmount, 0), maxOffset)
                        }
                        
                        // Calculate progress based on position
                        let progress = offset / maxOffset
                        onDragProgress(progress)
                    }
                    .onEnded { value in
                        isDragging = false
                        let dragAmount = value.translation.height
                        let velocity = value.predictedEndLocation.y - value.location.y
                        
                        withAnimation(.spring(duration: 0.3, bounce: 0.3)) {
                            if offset == maxOffset {
                                // Currently at bottom, check if should move up
                                if -dragAmount > geometry.size.height * 0.3 || velocity < -200 {
                                    offset = 0
                                }
                            } else {
                                // Currently at top or middle, check if should dismiss
                                if dragAmount > geometry.size.height * 0.3 || velocity > 200 {
                                    offset = maxOffset
                                } else {
                                    offset = 0
                                }
                            }
                        }
                        
                        onDragEnded(offset == maxOffset)
                    }
            )
            .animation(.spring(), value: isDragging)
        }
    }
}
// MARK: - Supporting Views
struct DragIndicator: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 2.5)
            .fill(.gray)
            .frame(width: 40, height: 5)
            .padding(.top, 5)
    }
}
