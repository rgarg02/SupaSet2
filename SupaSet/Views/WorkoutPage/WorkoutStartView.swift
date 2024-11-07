//
//  WorkoutStartView.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/5/24.
//
import SwiftUI

struct WorkoutStartView: View {
    let namespace: Namespace.ID
    @Binding var isExpanded: Bool
    @State private var offsetY: CGFloat = 0
    @Bindable var workout : Workout
    @Environment(ExerciseViewModel.self) var exerciseViewModel
     
    private let dismissThreshold: CGFloat = 100
    private let maxDragDistance: CGFloat = 300
    private let buttonSize: CGFloat = 60
    var body: some View {
        GeometryReader { geometry in
            let progress = min(max(offsetY / maxDragDistance, 0), 1)
            let width = geometry.size.width * (1 - progress) + buttonSize * progress
            let height = geometry.size.height * (1 - progress) + buttonSize * progress
            
            // Adjusted position calculations for precise button alignment
            let startX = geometry.size.width / 2
            let startY = geometry.size.height / 2
            let endX = geometry.size.width - (buttonSize / 2) - 20  // Align with trailing padding
            let endY = geometry.size.height - (buttonSize / 2) - 100 // Align with bottom padding + tab bar
            
            let currentX = startX + (endX - startX) * progress
            let currentY = startY + (endY - startY) * progress
            
            ZStack {
                Color.blue
                    .matchedGeometryEffect(id: "background", in: namespace)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Top bar with drag indicator
                    VStack {
                        RoundedRectangle(cornerRadius: 2.5)
                            .fill(.gray)
                            .frame(width: 40, height: 5)
                            .padding(.top, 10)
                            .opacity(1 - progress)
                        
                        Text("Current Workout")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                    }
                    .padding()
                    
                    // Workout content
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(0..<5) { _ in
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.white.opacity(0.1))
                                    .frame(height: 80)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                .opacity(1 - progress)
            }
            .matchedGeometryEffect(id: "icon", in: namespace)
            .frame(width: width, height: height)
            .cornerRadius(progress * 30) // 30 is half button width
            .position(x: currentX, y: currentY)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.height > 0 {
                            offsetY = value.translation.height
                        }
                    }
                    .onEnded { value in
                        if value.translation.height > dismissThreshold {
                            // First complete the morph to circle
                            withAnimation(.easeOut(duration: 0.3)) {
                                offsetY = maxDragDistance
                            }
                            
                            //after 0.5 seconds change isExpanded to false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                isExpanded = false
                            }
                            
                            
                        } else {
                            withAnimation(.spring()) {
                                offsetY = 0
                            }
                        }
                    }
            )
        }
    }
}
