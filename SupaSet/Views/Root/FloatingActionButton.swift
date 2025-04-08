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
struct FABButtonStyle: ButtonStyle {
func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        configuration.label
            .padding()
            .background(ZStack{
                Circle()
                    .fill(.ultraThickMaterial)
                Circle()
                    .fill(Color.text.opacity(0.2))
                Circle()
                    .stroke(.ultraThinMaterial, lineWidth: 1)
            })
            .foregroundStyle(.text)
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}


struct FloatingActionButton: View {
    var icon: String
    var action: () -> Void
        
    var body: some View {
        Button(action: {
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .bold))
                .frame(width: 30, height: 30)
        }
        .buttonStyle(FABButtonStyle())
    }
}

struct NewWorkoutFAB: View {
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
                .padding(.bottom, 55)
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
    }
}

#Preview {
    NewWorkoutFAB(
        currentWorkout: .constant(nil)
    )
}
