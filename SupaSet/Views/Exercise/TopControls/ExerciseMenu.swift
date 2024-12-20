//
//  ExerciseMenu.swift
//  SupaSet
//
//  Created by Rishi Garg on 12/17/24.
//

import SwiftUI
struct ExerciseMenu: View {
    let workoutExercise: WorkoutExercise
    @Binding var showRestTimer: Bool
    @State var restTimerTime: TimeInterval = 30
    var body: some View {
        VStack {
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {  // Added specific duration
                }
            } label: {
                HStack{
                    Image(systemName: "arrow.2.squarepath")
                    Text("Replace Exercise")
                        .bold()
                    Spacer()
                }
            }
            .padding(.vertical, 5)
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {  // Added specific duration
                }
            } label: {
                HStack{
                    Image(systemName: "scalemass")
                    Text("Change Units")
                        .bold()
                    Spacer()
                }
            }
            .padding(.vertical, 5)
            NavigationLink {
                RestTimerView(selectedTime: $restTimerTime)
            } label: {
                HStack{
                    Image(systemName: "timer")
                    Text("Auto Rest Timer")
                        .bold()
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.theme.accent)
                }
            }
            .padding(.vertical, 5)
            Spacer()
        }
        .padding()
    }
}
#Preview {
    let preview = PreviewContainer.preview
    NavigationView {
        ExerciseMenu(workoutExercise: preview.workout.sortedExercises[0], showRestTimer: .constant(false))
            .modelContainer(preview.container)
    }
}
