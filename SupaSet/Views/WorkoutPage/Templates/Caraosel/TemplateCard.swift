import SwiftUI
import SwiftData

struct TemplateCard: View {
    let template: Template
    let collapsed: Bool
    @Environment(ExerciseViewModel.self) private var exerciseViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.alertController) private var alertController
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Template Name
            Text(template.name)
                .lineLimit(1)
                .font(.headline)
                .foregroundStyle(Color.text)
                .padding(.vertical, 3)
            if !collapsed {
                // Creation Date
                Text("Created: \(formattedDate(template.createdAt))")
                    .font(.caption2)
                    .foregroundStyle(Color.text.opacity(0.8))
                    .padding(.vertical, 3)
                
                // Exercises Preview
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(template.sortedExercises.prefix(4), id: \.id) { exercise in
                        HStack {
                            Text("\(exercise.sets.count)x")
                                .font(.caption)
                                .lineLimit(1)
                                .foregroundStyle(Color.accent.adjusted(by: -25))
                            Text(exerciseViewModel.getExerciseName(for: exercise.exerciseID))
                                .font(.caption)
                                .lineLimit(1)
                                .foregroundStyle(Color.text.opacity(0.9))
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
        }
        .frame(height: collapsed ? nil : 165)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(ZStack{
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.thinMaterial)
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.text.opacity(0.3), lineWidth: 1)
        })
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
            HStack(spacing: 12) {
                // Add an icon similar to the trophy in the image
                Image(systemName: "figure.run")
                    .font(.caption)
                    .fontWeight(.light)
                    .padding(.leading)
                    .foregroundStyle(Color.text)
                Text("Start Workout")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.text)
                
                Spacer()
            }
            .padding(5)
            .background(
                ZStack {
                    // This creates the glass effect
                    Capsule()
                        .fill(.ultraThinMaterial)
                    
                    // This adds a subtle glow/highlight to make it brighter
                    Capsule()
                        .fill(Color.text.opacity(0.15))
                    
                    // Border to give it definition like in the image
                    Capsule()
                        .stroke(Color.text.opacity(0.3), lineWidth: 1)
                }
            )
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
    ZStack {
        // Add a gradient background to showcase the glassmorphism effect
        LinearGradient(
            gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.purple.opacity(0.3)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        Circle()
            .fill(Color.red)
            .frame(width: 200, height: 200)
            .offset(x: 100, y: -100)
        LazyVGrid(columns: columns) {
            TemplateCard(template: preview.template, collapsed: false)
            TemplateCard(template: Template(name: "Cardio", order: 1), collapsed: true)
        }
        .padding()
    }
    .modelContainer(preview.container)
    .environment(preview.viewModel)
}
