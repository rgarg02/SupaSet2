//
//  ExerciseRowView.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/6/24.
//
import SwiftUI
struct ExerciseRowView: View {
    let exercise: Exercise
    @Binding var selectedExercise: Exercise?
    @Binding var isShowingDetail: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Exercise Name and Level
            HStack {
                Text(exercise.name)
                    .font(.headline)
                Spacer()
                Badge(for: exercise.level)
                Button {
                    selectedExercise = exercise
                    isShowingDetail = true
                } label: {
                    Image(systemName: "info.circle")
                }
                .buttonStyle(.plain)
            }
            
            // Equipment
            if let equipment = exercise.equipment {
                HStack {
                    equipment.image
                        .imageScale(.small)
                    Text(equipment.rawValue.capitalized)
                        .font(.subheadline)
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
        .padding(.all, 8)
    }
}

// Supporting Views
struct Badge<T: RawRepresentable>: View where T.RawValue == String {
   let text: String
   let backgroundColor: Color
   let textColor: Color
   
    init(for value: T, backgroundColor: Color = .secondaryTheme, textColor: Color? = nil) {
       self.text = value.rawValue.capitalized
       
       if let level = value as? Level {
           self.backgroundColor = level.color.shade(50)
           self.textColor = level.color.shade(50).bestTextColor()
       } else {
           self.backgroundColor = backgroundColor
           self.textColor = backgroundColor.bestTextColor()
       }
   }
   
   var body: some View {
       Text(text)
           .font(.caption)
           .padding(.horizontal, 8)
           .padding(.vertical, 4)
           .background(backgroundColor)
           .foregroundColor(textColor)
           .bold()
           .clipShape(Capsule())
   }
}

// Preview Provider
#Preview {
    @Previewable @State var exercise : Exercise? = Exercise(
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
    )
    if let exercise{
        NavigationView{
            List{
                ExerciseRowView(exercise: exercise, selectedExercise: $exercise,
                                isShowingDetail: .constant(false))
                .padding()
                ExerciseRowView(exercise: exercise, selectedExercise: $exercise,
                                isShowingDetail: .constant(false))
                .padding()
                .colorScheme(.dark)
            }
        }
    }
}
