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
    private let titleShowThreshold: CGFloat = 60
    func formattedDate() -> String {
        let elapsed = Date().timeIntervalSince(workout.date)
        if elapsed < 600 {
            return "0:00"
        }
        if elapsed < 3600 {
            return "00:00"
        }
        if elapsed < 36000 {
            return "0:00:00"
        }
        return "00:00:00"
    }
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
                Image(systemName: "clock")
                Text(formattedDate())
                    .hidden()
                    .overlay(alignment:.leading){
                        Text(workout.date, style: .timer)
                            .foregroundStyle(Color.theme.accent)
                    }
                
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
            WorkoutActivityManager.shared.endAllActivities()
        } catch {
            print("Error saving workout: \(error)")
        }
    }
    
    private func cancelWorkout() {
        modelContext.delete(workout)
        withAnimation {
            isExpanded = false
        }
        WorkoutActivityManager.shared.endAllActivities()
    }
}

