//
//  TemplateCard.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/25/25.
//

import SwiftUI
import SwiftData
// Template Card View
struct TemplateCard: View {
    let template: Template
    @Environment(ExerciseViewModel.self) private var exerciseViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.alertController) private var alertController
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Template Name
            Text(template.name)
                .lineLimit(1)
                .font(.headline)
                .foregroundStyle(Color.theme.text)
                .padding(.vertical, 3)
            // Creation Date
            Text("Created: \(formattedDate(template.createdAt))")
                .font(.caption2)
                .padding(.vertical, 3)
            
            // Exercises Preview
            VStack(alignment: .leading, spacing: 4) {
                ForEach(template.sortedExercises.prefix(4), id: \.id) { exercise in
                    HStack{
                        Text("\(exercise.sets.count)x")
                            .font(.caption)
                            .lineLimit(1)
                            .foregroundStyle(Color.theme.accent)
                        Text(exerciseViewModel.getExerciseName(for: exercise.exerciseID))
                            .foregroundStyle(Color.theme.text)
                            .font(.caption)
                            .lineLimit(1)
                    }
                }
                if template.exercises.count > 4 {
                    Text("+ \(template.exercises.count - 4) more")
                        .font(.caption)
                        .foregroundStyle(Color.theme.text)
                }
            }
            Spacer()
            StartWorkoutButton(template: template)
                .frame(maxWidth: .infinity)
        }
        .frame(height: 165)
        .foregroundStyle(Color.theme.text)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color.theme.primarySecond)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    @ViewBuilder
    private func StartWorkoutButton(template: Template) -> some View {
        Button {
            startWorkout(with: template)
            
        } label: {
            HStack {
                Spacer()
                Text("Start Workout")
                    .fontWeight(.medium)
                    .font(.caption)
                    .foregroundColor(.theme.accent)
                Spacer()
            }
            .padding(.vertical, 4)
            .background(Color.theme.accent.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
    private func startWorkout(with template: Template) {
        // Check for unfinished workouts
        let descriptor = FetchDescriptor<Workout>(
            predicate: #Predicate<Workout> {$0.isFinished == false}
        )
        
        do {
            let unfinishedWorkouts = try modelContext.fetch(descriptor)
            if !unfinishedWorkouts.isEmpty {
                // If an unfinished workout exists, show an alert
                alertController.present(.alert, title: "Unfinished Workout", message: "You already have an unfinished workout. Please finish it before starting a new one.", buttons: [
                    AlertButton(.ok)])
                return
            } else {
                // If no unfinished workouts exist, create a new one
                let buttons = [
                    AlertButton(title: "Cancel", role: .cancel),
                    AlertButton(title: "Start Workout", action: {
                        let workout = Workout(template: template)
                        withAnimation(.smooth) {
                            modelContext.insert(workout)
                        }
                    })]
                alertController.present(title: "Start Workout", message: "Start a new workout using \(template.name)?", buttons: buttons)
            }
        } catch {
            print("Error fetching unfinished workouts: \(error)")
        }
    }
}

#Preview {
    let preview = PreviewContainer.preview
    let columns = [
        GridItem(.adaptive(minimum: 280, maximum: 320), spacing: 16),
        GridItem(.adaptive(minimum: 280, maximum: 320), spacing: 16)
    ]
    LazyVGrid(columns: columns) {
        TemplateCard(template: preview.template)
        
        TemplateCard(template: Template(name: "Cardio", order: 1))
    }
    .padding()
    .modelContainer(preview.container)
    .environment(preview.viewModel)
}
