//
//  FloatingActionButton.swift
//  SupaSet
//
//  Created by Rishi Garg on 3/13/25.
//


//
//  FloatingActionButton.swift
//  SupaSet
//
//  Created by Rishi Garg on 3/13/25.
//

import SwiftUI

struct FloatingActionButton: View {
    var icon: String
    var action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            // Use slight delay to allow animation to play
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                action()
                
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
        }) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(Color.theme.accent)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 3)
                .scaleEffect(isPressed ? 0.9 : 1.0)
        }
    }
}

struct NewWorkoutFAB: View {
    @Binding var showWorkoutOverlay: Bool
    @Binding var currentWorkout: Workout?
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                FloatingActionButton(icon: "plus") {
                    createAndShowWorkout()
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    private func createAndShowWorkout() {
        // Create a new workout
        let newWorkout = Workout(name: "New Workout")
        newWorkout.date = Date()
        
        // Add to model context (database)
        modelContext.insert(newWorkout)
        
        // Set as current and show overlay
        currentWorkout = newWorkout
        
        withAnimation(.spring) {
            showWorkoutOverlay = true
        }
    }
}

#Preview {
    NewWorkoutFAB(
        showWorkoutOverlay: .constant(false),
        currentWorkout: .constant(nil)
    )
}
