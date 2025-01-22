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
    @State private var draggingViewDown : Bool = false
    // Add a constant for the minimum height when collapsed
    private let minHeight: CGFloat = 60 // Adjust this value based on your WorkoutTopControls height
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        DragIndicator()
                            .opacity(show ? 1 : 0)
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
                        .opacity(show ? 1 : 0)
                }
                .background(Color.theme.background)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .dismissKeyboardOnTap()
            .background(Color.theme.background)
            .cornerRadius(8)
            .offset(y: show ? max(min(offset, geometry.size.height - minHeight), 0) : geometry.size.height - minHeight)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isDragging = true
                        let dragAmount = value.translation.height
                        offset = min(dragAmount, geometry.size.height - minHeight)
                        draggingViewDown = true
                    }
                    .onEnded { value in
                        isDragging = false
                        let dragAmount = value.translation.height
                        withAnimation(.spring()) {
                            if dragAmount > geometry.size.height * 0.5 || value.velocity.height > 200 {
                                show = false
                            } else {
                                // Reset to original position
                                offset = 0
                                show = true
                            }
                        }
                        draggingViewDown = false
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
#Preview {
    @Previewable @State var show = true
    let preview = PreviewContainer.preview
    NavigationView{
        ZStack(alignment: .bottom){
            WorkoutContentView(
                workout: preview.workout,
                show: $show
            )
        }
    }
    .modelContainer(preview.container)
    .environment(preview.viewModel)
}
