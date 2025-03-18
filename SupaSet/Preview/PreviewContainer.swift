import SwiftData
import Foundation

@MainActor
struct PreviewContainer {
    let container: ModelContainer
    let workout: Workout
    let template: Template
    let completedWorkouts: [Workout]
    let viewModel: ExerciseViewModel
    
    // Make the initializer support concurrency
    init() async throws {
        // Create schema and configuration
        let schema = Schema([
            Workout.self,
            WorkoutExercise.self,
            ExerciseSet.self,
            Template.self,
            TemplateExercise.self,
            ExerciseDetail.self,
            ExerciseEntity.self
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
        viewModel = ExerciseViewModel(modelContext: container.mainContext)
        try await viewModel.loadExercises()
        
        
        // Create sample active workout
        workout = Workout(name: "Preview Workout", isFinished: false)
        container.mainContext.insert(workout)
        
        template = Template(name: "Preview Template", order: 0)
        container.mainContext.insert(template)
        
        // Add exercises to template
        if !viewModel.exercises.isEmpty {
            for _ in 0..<6 {
                template.insertExercise(viewModel.exercises.randomElement()!.id)
            }
            
            // Create additional templates
            for index in 0..<5 {
                let randomTemplate = Template(name: "Template \(index)", order: index)
                container.mainContext.insert(randomTemplate)
                
                for _ in 0..<6 {
                    randomTemplate.insertExercise(viewModel.exercises.randomElement()!.id)
                }
            }
            
            // Add exercises to workout
            workout.insertExercise(viewModel.exercises.randomElement()!.id)
            workout.insertExercise(viewModel.exercises.randomElement()!.id)
        }
        
        // Create completed workouts
        completedWorkouts = try await PreviewContainer.createCompletedWorkouts(
            using: container.mainContext,
            exercises: viewModel.exercises
        )
    }
    
    // Static helper for previews - now needs to be async
    static var preview: PreviewContainer {
        // Since we can't use async in this property, we'll create a basic version
        // that doesn't rely on loadExercises
        do {
            let schema = Schema([
                Workout.self,
                WorkoutExercise.self,
                ExerciseSet.self,
                Template.self,
                TemplateExercise.self,
                ExerciseDetail.self,
                ExerciseEntity.self
            ])
            
            let config = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: true
            )
            
            let container = try ModelContainer(
                for: schema,
                configurations: config
            )
            
            // Create a basic view model
            let viewModel = ExerciseViewModel(modelContext: container.mainContext)
            
            // Add some sample exercises to the database directly
            let exercises = createFallbackExercises()
            let exerciseEntities = exercises.map { createExerciseEntity(from: $0) }
            for entity in exerciseEntities {
                container.mainContext.insert(entity)
            }
            
            // Create a basic workout
            let workout = Workout(name: "Preview Workout", isFinished: false)
            container.mainContext.insert(workout)
            
            // Add a couple exercises
            if !exercises.isEmpty {
                workout.insertExercise(exercises[0].id)
                if exercises.count > 1 {
                    workout.insertExercise(exercises[1].id)
                }
            }
            
            // Create a template
            let template = Template(name: "Preview Template", order: 0)
            container.mainContext.insert(template)
            
            // Add exercises to template
            if !exercises.isEmpty {
                template.insertExercise(exercises[0].id)
                if exercises.count > 1 {
                    template.insertExercise(exercises[1].id)
                }
            }
            
            // Create a simple completed workout
            let completedWorkout = Workout(
                name: "Completed Workout",
                date: Date().addingTimeInterval(-86400), // Yesterday
                endTime: Date().addingTimeInterval(-82800), // 1 hour after start
                isFinished: true
            )
            container.mainContext.insert(completedWorkout)
            
            // Return a simplified preview container
            return PreviewContainer(
                container: container,
                workout: workout,
                template: template,
                completedWorkouts: [completedWorkout],
                viewModel: viewModel
            )
            
        } catch {
            fatalError("Failed to create PreviewContainer: \(error)")
        }
    }
    
    // Direct initializer that doesn't require async
    private init(
        container: ModelContainer,
        workout: Workout,
        template: Template,
        completedWorkouts: [Workout],
        viewModel: ExerciseViewModel
    ) {
        self.container = container
        self.workout = workout
        self.template = template
        self.completedWorkouts = completedWorkouts
        self.viewModel = viewModel
    }
    
    // Helper to create sample completed workouts
    private static func createCompletedWorkouts(
        using context: ModelContext,
        exercises: [Exercise]
    ) async throws -> [Workout] {
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
    
    // Helper function to create fallback exercises for preview
    private static func createFallbackExercises() -> [Exercise] {
        return [
            Exercise(
                id: UUID().uuidString,
                name: "Bench Press",
                force: .push,
                level: .intermediate,
                mechanic: .compound,
                equipment: .barbell,
                primaryMuscles: [.chest],
                secondaryMuscles: [.triceps, .shoulders],
                instructions: ["Lie on bench", "Lower bar to chest", "Press up"],
                category: .strength,
                images: []
            ),
            Exercise(
                id: UUID().uuidString,
                name: "Squats",
                force: .push,
                level: .intermediate,
                mechanic: .compound,
                equipment: .barbell,
                primaryMuscles: [.quadriceps, .glutes],
                secondaryMuscles: [.hamstrings, .calves],
                instructions: ["Stand with bar on shoulders", "Squat down", "Stand up"],
                category: .strength,
                images: []
            ),
            Exercise(
                id: UUID().uuidString,
                name: "Deadlift",
                force: .pull,
                level: .intermediate,
                mechanic: .compound,
                equipment: .barbell,
                primaryMuscles: [.lowerBack, .glutes],
                secondaryMuscles: [.hamstrings, .traps],
                instructions: ["Stand with bar at feet", "Lift bar", "Lower bar"],
                category: .strength,
                images: []
            ),
            Exercise(
                id: UUID().uuidString,
                name: "Treadmill",
                force: nil,
                level: .beginner,
                mechanic: nil,
                equipment: .machine,
                primaryMuscles: [.quadriceps],
                secondaryMuscles: [.calves, .hamstrings],
                instructions: ["Set speed", "Run at steady pace"],
                category: .cardio,
                images: []
            )
        ]
    }
    
    // Helper to create exercise entity from Exercise struct
    private static func createExerciseEntity(from exercise: Exercise) -> ExerciseEntity {
        let entity = ExerciseEntity(from: exercise)
        
        return entity
    }
}
