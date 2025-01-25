//
//  TemplateCard.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/25/25.
//

import SwiftUI
// Template Card View
struct TemplateCard: View {
    let template: Template
    @Environment(ExerciseViewModel.self) var exerciseViewModel
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Template Name
            Text(template.name)
                .lineLimit(1)
                .font(.headline)
                .foregroundStyle(.primary)
                .padding(.vertical, 3)
            
            // Creation Date
            Text("Created: \(formattedDate(template.createdAt))")
                .font(.caption)
                .padding(.vertical, 3)
            
            // Exercises Preview
            VStack(alignment: .leading, spacing: 4) {
                ForEach(template.sortedExercises.prefix(4), id: \.id) { exercise in
                    HStack{
                        Text("\(exercise.sets.count)x")
                            .font(.subheadline)
                            .lineLimit(1)
                            .foregroundStyle(Color.theme.accent)
                        Text(exerciseViewModel.getExerciseName(for: exercise.exerciseID))
                            .font(.subheadline)
                            .lineLimit(1)
                    }
                }
                if template.exercises.count > 4 {
                    Text("+ \(template.exercises.count - 4) more")
                        .font(.subheadline)
                }
            }
            Spacer()
        }
        .frame(height: 150)
        .foregroundStyle(Color.theme.text)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.theme.primarySecond)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
