import SwiftData
import Foundation

@MainActor
struct PreviewContainer {
    let container: ModelContainer
    let workout: Workout
    let template: Template
    let completedWorkouts: [Workout]
    let viewModel: ExerciseViewModel
    
    init() throws {
        // Create schema and configuration
        let schema = Schema([
            Workout.self,
            WorkoutExercise.self,
            ExerciseSet.self,
            Template.self,
            TemplateExercise.self,
            ExerciseDetail.self
        ])
        
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        
        // Initialize container
        container = try ModelContainer(
            for: schema,
            configurations: config
        )
        
        // Initialize view model for exercises
        viewModel = ExerciseViewModel()
        viewModel.loadExercises()
        
        // Create sample active workout
        workout = Workout(name: "Preview Workout", isFinished: false)
        container.mainContext.insert(workout)
        template = Template(name: "Preview Template", order: 0)
        container.mainContext.insert(template)
        template.insertExercise(viewModel.exercises.randomElement()!.id)
        template.insertExercise(viewModel.exercises.randomElement()!.id)
        for index in 0..<5 {
            let randomTemplate = Template(name: "Template \(index)", order: index)
            container.mainContext.insert(randomTemplate)
            randomTemplate.insertExercise(viewModel.exercises.randomElement()!.id)
            randomTemplate.insertExercise(viewModel.exercises.randomElement()!.id)
            randomTemplate.insertExercise(viewModel.exercises.randomElement()!.id)
            randomTemplate.insertExercise(viewModel.exercises.randomElement()!.id)
            randomTemplate.insertExercise(viewModel.exercises.randomElement()!.id)
            randomTemplate.insertExercise(viewModel.exercises.randomElement()!.id)
        }
        workout.insertExercise(viewModel.exercises.randomElement()!.id)
        workout.insertExercise(viewModel.exercises.randomElement()!.id)
        // Create completed workouts
        completedWorkouts = PreviewContainer.createCompletedWorkouts(
            using: container.mainContext,
            exercises: viewModel.exercises
        )
    }
    
    // Static helper for previews
    static var preview: PreviewContainer {
        do {
            return try PreviewContainer()
        } catch {
            fatalError("Failed to create PreviewContainer: \(error)")
        }
    }
    
    // Helper to create sample completed workouts
    private static func createCompletedWorkouts(
        using context: ModelContext,
        exercises: [Exercise]
    ) -> [Workout] {
        guard !exercises.isEmpty else { return [] }
        
        // Helper to get random exercises
        func getRandomExercises() -> [Exercise] {
            let count = Int.random(in: 2...4)
            return Array(exercises.shuffled().prefix(count))
        }
        
        // Create several completed workouts over the past month
        let workouts: [Workout] = [
            // Yesterday's workout
            createWorkout(
                name: "Push Day",
                daysAgo: 1,
                exercises: getRandomExercises().filter { $0.category == .strength },
                notes: "Great pump today!"
            ),
            
            // Last week's workout
            createWorkout(
                name: "Pull Day",
                daysAgo: 7,
                exercises: getRandomExercises().filter { $0.category == .strength },
                notes: "New PR on deadlifts!"
            ),
            
            // Two weeks ago
            createWorkout(
                name: "Leg Day",
                daysAgo: 14,
                exercises: getRandomExercises().filter { $0.category == .strength },
                notes: "Focused on form"
            ),
            
            // Cardio session
            createWorkout(
                name: "Cardio",
                daysAgo: 3,
                exercises: exercises.filter { $0.category == .cardio }.prefix(2).map { $0 },
                notes: "Good endurance work"
            )
        ]
        
        // Insert all workouts into context
        workouts.forEach { context.insert($0) }
        
        return workouts
    }
    
    private static func createWorkout(
        name: String,
        daysAgo: Int,
        exercises: [Exercise],
        notes: String = ""
    ) -> Workout {
        let startDate = Calendar.current.date(
            byAdding: .day,
            value: -daysAgo,
            to: Date()
        ) ?? Date()
        
        let workout = Workout(
            name: name,
            date: startDate,
            endTime: startDate.addingTimeInterval(3600),
            isFinished: true,
            notes: notes
        )
        
        // Add exercises with realistic sets
        exercises.enumerated().forEach { index, exercise in
            let workoutExercise = WorkoutExercise(
                exerciseID: exercise.id,
                order: index,
                notes: exercise.category == .cardio ? "Keeping heart rate steady" : nil
            )
            
            if exercise.category == .cardio {
                // Cardio-style sets
                workoutExercise.sets = [
                    ExerciseSet(reps: 1, weight: 0, notes: "30 mins steady state", isDone: true)
                ]
            } else {
                // Strength training sets
                let warmupSet = ExerciseSet(
                    reps: 10,
                    weight: 95,
                    isWarmupSet: true,
                    order: 0,
                    isDone: true
                )
                
                let workingSets = (1...3).map { setIndex in
                    ExerciseSet(
                        reps: 8,
                        weight: Double.random(in: 135...225),
                        rpe: Int.random(in: 7...9),
                        notes: setIndex == 3 ? "Last set, pushed hard" : nil,
                        order: setIndex,
                        isDone: true
                    )
                }
                
                workoutExercise.sets = [warmupSet] + workingSets
            }
            
            workout.exercises.append(workoutExercise)
        }
        
        return workout
    }
}
