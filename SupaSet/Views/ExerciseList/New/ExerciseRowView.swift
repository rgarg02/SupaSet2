import SwiftUI
struct ExerciseRowView: View {
    @EnvironmentObject var viewModel: ExerciseListViewModel
    let exercise: ExerciseRecord
    @State private var primaryMuscles: [MuscleGroup] = []
    @Binding var selectedExercise: ExerciseRecord?
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
                        ForEach(primaryMuscles, id: \.self) { muscle in
                            Badge(for: muscle)
                        }
                    }
                }
            }
        }
        .contentShape(Rectangle())
        .task {
            primaryMuscles = await viewModel.fetchMuscleGroups(for: exercise.id)
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
           self.backgroundColor = level.color
           self.textColor = .text
       } else {
           self.backgroundColor = backgroundColor
           self.textColor = .text
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
