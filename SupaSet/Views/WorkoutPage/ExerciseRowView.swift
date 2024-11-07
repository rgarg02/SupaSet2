//
//  ExerciseRowView.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/6/24.
//
import SwiftUI
struct ExerciseRowView: View {
    let exercise: Exercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Exercise Name and Level
            HStack {
                Text(exercise.name)
                    .font(.headline)
                Spacer()
                Badge(for: exercise.level)
            }
            
            // Equipment
            if let equipment = exercise.equipment {
                HStack {
                    Image(systemName: "dumbbell.fill")
                        .imageScale(.small)
                    Text(equipment.rawValue.capitalized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Primary Muscles
            HStack {
                Image(systemName: "figure.strengthtraining.traditional")
                    .imageScale(.small)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(exercise.primaryMuscles, id: \.self) { muscle in
                            Badge(for: muscle)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// Supporting Views
struct Badge<T: RawRepresentable>: View where T.RawValue == String {
   let text: String
   let backgroundColor: Color
   let textColor: Color
   
   init(for value: T, backgroundColor: Color = .gray, textColor: Color? = nil) {
       self.text = value.rawValue.capitalized
       
       if let level = value as? Level {
           self.backgroundColor = level.color.opacity(0.2)
           self.textColor = level.color
       } else {
           self.backgroundColor = backgroundColor.opacity(0.2)
           self.textColor = textColor ?? backgroundColor
       }
   }
   
   var body: some View {
       Text(text)
           .font(.caption)
           .padding(.horizontal, 8)
           .padding(.vertical, 4)
           .background(backgroundColor)
           .foregroundColor(textColor)
           .clipShape(Capsule())
   }
}

// Preview Provider
#Preview {
    ExerciseRowView(exercise: Exercise(
        id: "1",
        name: "Bench Press",
        force: .push,
        level: .intermediate,
        mechanic: .compound,
        equipment: .barbell,
        primaryMuscles: [.chest, .triceps, .shoulders],
        secondaryMuscles: [.forearms],
        instructions: ["Sample instruction"],
        category: .strength,
        images: []
    ))
    .padding()
}
