//
//  WorkoutTopControls.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/8/24.
//

import SwiftUI

struct WorkoutTopControls: View {
    @Bindable var workout : Workout
    @Environment(\.modelContext) var modelContext
    @Binding var isExpanded : Bool
    let scrollOffset: CGFloat
    private let titleShowThreshold: CGFloat = 30
    var body: some View {
        HStack{
            Button("Cancel"){
                cancelWorkout()
            }
            .padding(.leading)
            .foregroundStyle(.red)
            .font(.headline)
            Spacer()
            if scrollOffset > titleShowThreshold {
                Text(workout.name)
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.theme.text)
                    .transition(.opacity)
                Spacer()
            }

            Button("Finish"){
                finishWorkout()
            }
            .foregroundStyle(.green)
            .font(.headline)
            .padding(.trailing, 20)
        }
    }
    private func finishWorkout() {
        workout.isFinished = true
        workout.endTime = Date()
        
        // Save the context
        do {
            try modelContext.save()
            withAnimation {
                isExpanded = false
            }
        } catch {
            print("Error saving workout: \(error)")
        }
    }
    
    private func cancelWorkout() {
        modelContext.delete(workout)
        withAnimation {
            isExpanded = false
        }
    }
}

