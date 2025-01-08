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
    @Binding var show : Bool
    @Binding var offset: CGFloat
    private let titleShowThreshold: CGFloat = 100
    @State var elapsedTime : String = "0s"
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let maxOffsetHide: CGFloat = 100
    var body: some View {
        VStack{
            HStack{
                // Make the button border red and a capsule
                if show {
                    Button("Cancel"){
                        cancelWorkout()
                    }
                    .foregroundStyle(.red)
                    .background(.clear)
                    .buttonBorderShape(.capsule)
                    .font(.headline)
                    .opacity(max(0, CGFloat(1 - offset / maxOffsetHide)))
                }
                Spacer()
                Text(workout.name)
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.theme.text)
                    .transition(.opacity)
                Spacer()
                
                if show{
                    Button("Finish"){
                        finishWorkout()
                    }
                    .foregroundStyle(Color.theme.secondary)
                    .background(.clear)
                    .buttonBorderShape(.capsule)
                    .font(.headline)
                    .opacity(max(0, CGFloat(1 - offset / maxOffsetHide)))
                }
            }
            .allowsHitTesting(show)
            WorkoutTimer(workout: workout)
            Spacer()
            Divider()
        }
        .onTapGesture {
            if !show{
                withAnimation(.spring()){
                    show = true
                    offset = 0
                }
            }
        }
        .frame(height: 50)
        .padding(.horizontal)
    }
    private func finishWorkout() {
        workout.isFinished = true
        workout.endTime = Date()
        
        // Save the context
        do {
            try modelContext.save()
            withAnimation {
                show = false
            }
            WorkoutActivityManager.shared.endAllActivities()
        } catch {
            print("Error saving workout: \(error)")
        }
    }
    
    private func cancelWorkout() {
        modelContext.delete(workout)
        withAnimation {
            show = false
        }
        WorkoutActivityManager.shared.endAllActivities()
    }
}


#Preview {
    let previewContainer = PreviewContainer.preview
    
    WorkoutTopControls(
        workout: previewContainer.workout, show: .constant(true), offset: .constant(0)
    )
    .modelContainer(previewContainer.container)
    .environment(previewContainer.viewModel)
}
