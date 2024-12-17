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
                    Image(systemName: "note")
                    Text("Add a Note")
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
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {  // Added specific duration
                    showRestTimer = true
                }
            } label: {
                HStack{
                    Image(systemName: "timer")
                    Text("Auto Rest Timer")
                        .bold()
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color.theme.accent)
                }
            }
            .padding(.vertical, 5)
            Spacer()
        }
        .background(Color.theme.primary)
        .frame(maxWidth: .infinity)
        .padding()
        .padding(.top)
        .frame(width: 320, height: 400)
    }
}
#Preview {
    let preview = PreviewContainer.preview
    ExerciseMenu(workoutExercise: preview.workout.sortedExercises[0], showRestTimer: .constant(false))
        .modelContainer(preview.container)
}
