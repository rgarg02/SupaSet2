//
//  Expandable.swift
//  SupaSet
//
//  Created by Rishi Garg on 3/12/25.
//
import SwiftUI
import SwiftData
import UniformTypeIdentifiers

// MARK: - Main Expandable Workout View
struct ExpandableWorkout: View {
    // MARK: - Properties
    @Binding var show: Bool
    @Bindable var workout: Workout
    @State private var expandWorkout = false
    @State private var offsetY: CGFloat = 0
    @State private var isTimerVisible: Bool = true
    @Namespace private var animation
    @State var collapsed: Bool = false
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            let safeArea = geometry.safeAreaInsets
            
            ZStack(alignment: .top) {
                // Background
                backgroundView(safeArea)
                
                // Content
                miniWorkoutView()
                    .opacity(expandWorkout ? 0 : 1)
                expandedWorkoutView(safeArea)
                    .opacity(expandWorkout ? 1 : 0)
            }
            .frame(height: expandWorkout ? nil : 55, alignment: .top)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, expandWorkout ? 0 : safeArea.bottom + 55)
            .padding(.horizontal, expandWorkout ? 0 : 15)
            .offset(y: offsetY)
            .gesture(createDragGesture())
            .ignoresSafeArea(.container)
        }
        .onChange(of: show) { _, newValue in
            if !newValue {
                withAnimation(.smooth(duration: 0.3)) {
                    expandWorkout = false
                }
            }
        }
    }
    
    // MARK: - Background View
    @ViewBuilder
    private func backgroundView(_ safeArea: EdgeInsets) -> some View {
        Rectangle()
            .fill(.ultraThinMaterial)
            .background(ZStack{
                RoundedRectangle(cornerRadius: expandWorkout ? (safeArea.bottom == 0 ? 0 : 45) : 15, style: .continuous)
                    .fill(Color.text.opacity(0.3))
            })
            .clipShape(.rect(cornerRadius: expandWorkout ? (safeArea.bottom == 0 ? 0 : 45) : 15))
            .frame(height: expandWorkout ? nil : 55)
            .shadow(color: .primary.opacity(0.06), radius: 5, x: 5, y: 5)
            .shadow(color: .primary.opacity(0.05), radius: 5, x: -5, y: -5)
    }
    
    // MARK: - Drag Gesture
    private func createDragGesture() -> some Gesture {
        DragGesture()
            .onChanged { value in
                guard expandWorkout else { return }
                offsetY = max(value.translation.height, 0)
            }
            .onEnded { value in
                guard expandWorkout else { return }
                
                let translation = max(value.translation.height, 0)
                let velocity = value.velocity.height / 5
                
                withAnimation(.smooth(duration: 0.35)) {
                    if (translation + velocity) > (UIScreen.main.bounds.height * 0.3) {
                        expandWorkout = false
                    }
                    offsetY = 0
                }
            }
    }
    
    // MARK: - Mini Workout View
    @ViewBuilder
    private func miniWorkoutView() -> some View {
        HStack(spacing: 12) {
            HStack(spacing: 12) {
                // Progress indicator
                if !expandWorkout {
                    SetProgressView(progress: workout.progress, isExpanded: false)
                        .frame(width: 32, height: 32)
                        .matchedGeometryEffect(id: "Progress", in: animation)
                }
                
                // Workout name and exercise count
                VStack(alignment: .leading, spacing: 2) {
                    if !expandWorkout {
                        Text(workout.name)
                            .multilineTextAlignment(.leading)
                            .font(.headline)
                            .lineLimit(1)
                            .matchedGeometryEffect(id: "Name", in: animation)
                    }
                    
                    Text("\(workout.sortedExercises.count) exercises")
                        .font(.caption)
                        .matchedGeometryEffect(id: "ExerciseCount", in: animation)
                }
            }
            
            Spacer()
            
            // Timer
            if !expandWorkout {
                WorkoutTimer(workout: workout)
                    .matchedGeometryEffect(id: "Timer", in: animation)
            }
        }
        .background(Color.clear)
        .foregroundStyle(Color.text)
        .padding(.horizontal, 10)
        .frame(height: 55)
        .contentShape(.rect)
        .onTapGesture {
            withAnimation(.smooth(duration: 0.35)) {
                expandWorkout = true
            }
        }
    }
    
    // MARK: - Expanded Workout View
    @ViewBuilder
    private func expandedWorkoutView(_ safeArea: EdgeInsets) -> some View {
        VStack(spacing: 0) {
            // Header with drag indicator
            expandedHeaderView()
            // Scrollable content
            WorkoutView(show: $show, workout: workout)
                
        }
        .padding(.top, safeArea.top + 5)
    }
    
    // MARK: - Expanded Header View
    @ViewBuilder
    private func expandedHeaderView() -> some View {
        VStack(spacing: 0) {
            // Drag indicator
            Capsule()
                .fill(.white.secondary)
                .frame(width: 35, height: 5)
                .padding(.top, 5)
                .padding(.bottom, 10)
            
            // Header content
            HStack {
                if expandWorkout {
                    NameSection(item: workout)
                        .foregroundStyle(Color.text)
                        .matchedGeometryEffect(id: "Name", in: animation)
                    
                    Spacer()
                    
                    // Only show timer in header when not visible in scroll
                    if !isTimerVisible {
                        WorkoutTimer(workout: workout)
                            .matchedGeometryEffect(id: "Timer", in: animation, isSource: false)
                    }
                    AutoRestTimerView()
                }
            }
            .padding(.horizontal)
        
            // Progress bar
            if expandWorkout {
                SetProgressView(progress: workout.progress, isExpanded: true)
                    .frame(height: 3)
                    .matchedGeometryEffect(id: "Progress", in: animation)
            }
        }
    }
    
}
#Preview {
    Rectangle()
        .fill(.thinMaterial)
        .background(ZStack{
            RoundedRectangle(cornerRadius: 45, style: .continuous)
                .fill(Color.text.opacity(0.2))
        })
        .clipShape(.rect(cornerRadius: 45))
        .frame(height: nil)
        .shadow(color: .primary.opacity(0.06), radius: 5, x: 5, y: 5)
        .shadow(color: .primary.opacity(0.05), radius: 5, x: -5, y: -5)
}
