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
    private let titleShowThreshold: CGFloat = 100
    @State var elapsedTime : String = "0s"
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    func formattedDate() {
        let seconds = Int(Date().timeIntervalSince(workout.date))
        if seconds < 60 {
            elapsedTime = "\(seconds)s"
            return
        }
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let remainingSeconds = seconds % 60
        
        if hours > 0 {
            elapsedTime = String(format: "%d:%02d:%02d", hours, minutes, remainingSeconds)
        } else {
            elapsedTime = String(format: "%d:%02d", minutes, remainingSeconds)
        }
    }
    var body: some View {
        HStack{
            // Make the button border red and a capsule
            Button("Cancel"){
                cancelWorkout()
            }
            .foregroundStyle(.red)
            .background(.clear)
            .buttonBorderShape(.capsule)
            .font(.headline)
            Spacer()
            if scrollOffset > titleShowThreshold {
                Text(workout.name)
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.theme.text)
                    .transition(.opacity)
                Image(systemName: "clock")
                Text(elapsedTime)
                
                Spacer()
            }

            Button("Finish"){
                finishWorkout()
            }
            .foregroundStyle(Color.theme.secondary)
            .font(.headline)
        }
        .onReceive(timer) { _ in
            formattedDate()
                }
        .padding(.horizontal)
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


#Preview {
    let previewContainer = PreviewContainer.preview
    
    WorkoutTopControls(
        workout: previewContainer.workout, isExpanded: .constant(true), scrollOffset: 150
    )
    .modelContainer(previewContainer.container)
    .environment(previewContainer.viewModel)
}
