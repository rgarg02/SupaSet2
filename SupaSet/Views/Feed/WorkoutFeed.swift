//
//  WorkoutFeed.swift
//  SupaSet
//
//  Created by Rishi Garg on 4/4/25.
//

import SwiftUI
// Helper Struct to combine User and Workout for the feed
struct WorkoutFeedItem: Identifiable {
    // Use the workout's Firestore ID as the Identifiable ID
    var id: String { workout.id }
    let user: User
    let workout: WorkoutFS // Use the Firestore model directly for the feed
}
struct WorkoutFeed: View {
    // Assuming UserManager provides access to user fetching methods
    @Environment(UserManager.self) private var userManager
    // State variable holding an array of combined items
    let feedItems: [WorkoutFeedItem]
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    
    var body: some View {
        VStack {
            if isLoading && feedItems.isEmpty {
                ProgressView("Loading Workouts...")
            } else if feedItems.isEmpty {
                ContentUnavailableView {
                    Label("No Workouts Found", systemImage: "figure.walk.motion")
                } description: {
                    Text("Workouts from users you follow will appear here.")
                }
            } else {
                ForEach(feedItems) { item in
                    NavigationLink {
                        WorkoutDetailView(workout: workoutFromFS(item.workout))
                    } label: {
                        WorkoutCardView(user: item.user, workout: item.workout)
                    }
                    .padding(.vertical, 6) // Add some vertical space between cards
                }
            }
        }
    }
    func workoutFromFS(_ workoutFS: WorkoutFS) -> Workout {
        // Convert the Firestore model to your local model if needed
        // Assuming you have a method to fetch or convert it
        let workout =  Workout(
            name: workoutFS.name,
            date: workoutFS.date.dateValue(),
            endTime: workoutFS.endTime?.dateValue(),
            isFinished: workoutFS.isFinished,
            notes: workoutFS.notes ?? ""
        )
        workout.exercises = workoutFS.exercises.map { exercise in
            let sets = exercise.sets.map { set in
                ExerciseSet(
                    reps: set.reps,
                    weight: set.weight,
                    type: SetType(rawValue: set.type.rawValue) ?? .working,
                    rpe: set.rpe,
                    notes: set.notes,
                    order: set.order,
                    isDone: set.isDone
                )
            }
            let exercise = WorkoutExercise(exerciseID: exercise.exerciseID, order: exercise.order, notes: exercise.notes)
            exercise.sets = sets
            return exercise
        }
        return workout
    }
}
struct WorkoutCardView: View {
    let user: User
    let workout: WorkoutFS // Using the Firestore struct
    
    // Simple Date Label used within the card
    private struct DateLabel: View {
        let date: Date
        
        var body: some View {
            Text(date, style: .date) // Example format, adjust as needed
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // MARK: - User Header
            HStack {
                // Profile Picture
                AsyncImage(url: URL(string: user.profilePicUrl ?? "")) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle()) // Clip shape for placeholder too
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill) // Use fill to ensure circle is filled
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    case .failure:
                        // Placeholder image if loading fails
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
                
                // User Name
                Text(user.fullName)
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer() // Pushes content to the sides
                
                // Timestamp/Relative Date using the subview
                DateLabel(date: workout.date.dateValue())
                
            }
            .padding(.horizontal)
            .padding(.top) // Add padding top
            
            // MARK: - Workout Details
            VStack(alignment: .leading, spacing: 5) { // Reduced spacing here
                // Workout Name
                Text(workout.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .lineLimit(2) // Allow up to two lines
                
                // Optional: Workout Notes Snippet
                if let notes = workout.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(3) // Show a snippet
                        .padding(.top, 1)
                }
                
                // Optional: Footer details like exercise count or completion status
                HStack {
                    Text("\(workout.exercises.count) Exercises")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer() // Pushes the text to the left
                    
                    if workout.isFinished {
                        Text("Completed")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else {
                        Text("In Progress")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 8) // Add some space above footer
            }
            .padding(.horizontal)
            .padding(.bottom) // Add padding bottom
            
        }
        .foregroundStyle(.text) // Use primary color for text
        // Background and Styling
        .background(.regularMaterial) // Adapts to light/dark mode
        .clipShape(RoundedRectangle(cornerRadius: 12)) // Apply clipping *after* background
        // Optional Shadow (uncomment to add)
        // .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        // Padding around the card itself within its container (like a List row or VStack)
        .padding(.horizontal)
        .padding(.vertical, 6) // Give cards some vertical separation
    }
}
