import SwiftData
import Foundation

@MainActor
struct PreviewContainer {
    let container: ModelContainer
    let workout: Workout
    let template: Template
    let completedWorkouts: [Workout]
    let viewModel: ExerciseViewModel
    let authViewModel: AuthenticationViewModel
    
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
        
        authViewModel = AuthenticationViewModel()
        
        // Create sample active workout
        workout = Workout(name: "Today's Workout", isFinished: false)
        container.mainContext.insert(workout)
        
        template = Template(name: "Full Body Routine", order: 0)
        container.mainContext.insert(template)
        
        // Add exercises to template
        if !viewModel.exercises.isEmpty {
            for _ in 0..<6 {
                template.insertExercise(viewModel.exercises.randomElement()!.id)
            }
            
            // Create additional templates
            for index in 0..<5 {
                let templateNames = ["Push Day", "Pull Day", "Leg Day", "Upper Body", "Lower Body"]
                let randomTemplate = Template(name: templateNames[index % templateNames.count], order: index)
                container.mainContext.insert(randomTemplate)
                
                for _ in 0..<6 {
                    randomTemplate.insertExercise(viewModel.exercises.randomElement()!.id)
                }
            }
            
            // Add exercises to current workout
            workout.insertExercise(viewModel.exercises.randomElement()!.id)
            workout.insertExercise(viewModel.exercises.randomElement()!.id)
            
            // Add some sets to the current workout's exercises
            if let firstExercise = workout.exercises.first {
                firstExercise.sets = [
                    ExerciseSet(reps: 10, weight: 135, type: .warmup, order: 0),
                    ExerciseSet(reps: 8, weight: 155, type: .working, order: 1),
                    ExerciseSet(reps: 8, weight: 155, type: .working, order: 2),
                    ExerciseSet(reps: 6, weight: 175, type: .working, rpe: 8, order: 3)
                ]
                
                // Mark first set as completed
                firstExercise.sets[0].isDone = true
            }
            
            if workout.exercises.count > 1 {
                let secondExercise = workout.exercises[1]
                secondExercise.sets = [
                    ExerciseSet(reps: 12, weight: 50, type: .warmup, order: 0),
                    ExerciseSet(reps: 10, weight: 60, type: .working, order: 1),
                    ExerciseSet(reps: 10, weight: 60, type: .working, rpe: 7, order: 2)
                ]
            }
        }
        
        // Create completed workouts
        completedWorkouts = try PreviewContainer.createCompletedWorkouts(
            using: container.mainContext,
            exercises: viewModel.exercises
        )
    }
    
    // Static helper for previews - now needs to be async
    static var preview: PreviewContainer {
        // Since we can't use async in this property, we'll create a basic version
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
            let authViewModel = AuthenticationViewModel()
            
            // Create a basic workout
            let workout = Workout(name: "Today's Workout", isFinished: false)
            container.mainContext.insert(workout)
            
            // Create a template
            let template = Template(name: "Full Body Routine", order: 0)
            container.mainContext.insert(template)
            
            // Create a simple completed workout
            let completedWorkout = Workout(
                name: "Completed Workout",
                date: Date().addingTimeInterval(-86400), // Yesterday
                endTime: Date().addingTimeInterval(-82800), // 1 hour after start
                isFinished: true
            )
            container.mainContext.insert(completedWorkout)
            let samples = try createCompletedWorkouts(using: container.mainContext, exercises: viewModel.exercises)
            for sample in samples {
                container.mainContext.insert(sample)
            }
            // Return a simplified preview container
            return PreviewContainer(
                container: container,
                workout: workout,
                template: template,
                completedWorkouts: [completedWorkout],
                viewModel: viewModel,
                authViewModel: authViewModel
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
        viewModel: ExerciseViewModel,
        authViewModel: AuthenticationViewModel
    ) {
        self.container = container
        self.workout = workout
        self.template = template
        self.completedWorkouts = completedWorkouts
        self.viewModel = viewModel
        self.authViewModel = authViewModel
    }
    
    // Helper to create sample completed workouts
    static func createCompletedWorkouts(
        using context: ModelContext,
        exercises: [Exercise]
    ) throws -> [Workout] {
        guard !exercises.isEmpty else { return [] }
        
        // Helper to get random exercises
        func getRandomExercises(category: Category, count: Int) -> [Exercise] {
            return Array(exercises.filter { $0.category == category }.shuffled().prefix(count))
        }
        
        // Get different types of exercises
        let strengthExercises = exercises.filter { $0.category == .strength }
        let cardioExercises = exercises.filter { $0.category == .cardio }
        
        // Create a workout history spanning over two months
        let workouts: [Workout] = [
            // Yesterday's workout
            createDetailedWorkout(
                name: "Push Day",
                daysAgo: 1,
                exercises: getRandomExercises(category: .strength, count: 4),
                notes: "Great pump today! Felt strong on bench press."
            ),
            
            // Three days ago
            createDetailedWorkout(
                name: "Pull Day",
                daysAgo: 3,
                exercises: strengthExercises.filter { $0.force == .pull }.prefix(4).map { $0 },
                notes: "New PR on deadlifts! Back felt great."
            ),
            
            // Five days ago
            createDetailedWorkout(
                name: "Leg Day",
                daysAgo: 5,
                exercises: strengthExercises.filter {
                    $0.primaryMuscles.contains(.quadriceps) ||
                    $0.primaryMuscles.contains(.hamstrings) ||
                    $0.primaryMuscles.contains(.glutes)
                }.prefix(4).map { $0 },
                notes: "Focused on form, especially during squats."
            ),
            
            // Cardio session last week
            createDetailedWorkout(
                name: "Cardio",
                daysAgo: 7,
                exercises: cardioExercises.prefix(2).map { $0 },
                notes: "Good endurance work. Kept heart rate around 140-150 BPM."
            ),
            
            // Last week's push workout
            createDetailedWorkout(
                name: "Push Day",
                daysAgo: 8,
                exercises: strengthExercises.filter { $0.force == .push }.prefix(4).map { $0 },
                notes: "Shoulder felt a bit tight, took it easier on overhead press."
            ),
            
            // Last week's pull workout
            createDetailedWorkout(
                name: "Pull Day",
                daysAgo: 10,
                exercises: strengthExercises.filter { $0.force == .pull }.prefix(4).map { $0 },
                notes: "Focused on lat activation during pulldowns."
            ),
            
            // Two weeks ago leg day
            createDetailedWorkout(
                name: "Leg Day",
                daysAgo: 12,
                exercises: strengthExercises.filter {
                    $0.primaryMuscles.contains(.quadriceps) ||
                    $0.primaryMuscles.contains(.hamstrings) ||
                    $0.primaryMuscles.contains(.glutes)
                }.prefix(4).map { $0 },
                notes: "Good session overall. Added extra glute isolation work."
            ),
            
            // Two weeks ago cardio
            createDetailedWorkout(
                name: "Cardio",
                daysAgo: 14,
                exercises: cardioExercises.prefix(2).map { $0 },
                notes: "HIIT session - 30 seconds on, 30 seconds off for 20 minutes."
            ),
            
            // Three weeks ago
            createDetailedWorkout(
                name: "Full Body",
                daysAgo: 17,
                exercises: Array(strengthExercises.shuffled().prefix(6)),
                notes: "First session back after a short break. Keeping weights moderate."
            ),
            
            // One month ago
            createDetailedWorkout(
                name: "Upper Body",
                daysAgo: 30,
                exercises: strengthExercises.filter {
                    $0.primaryMuscles.contains(.chest) ||
                    $0.primaryMuscles.contains(.middleBack) ||
                    $0.primaryMuscles.contains(.shoulders) ||
                    $0.primaryMuscles.contains(.triceps) ||
                    $0.primaryMuscles.contains(.biceps)
                }.prefix(5).map { $0 },
                notes: "Good session. Tried new cable fly variation."
            ),
            
            // Six weeks ago
            createDetailedWorkout(
                name: "Lower Body",
                daysAgo: 42,
                exercises: strengthExercises.filter {
                    $0.primaryMuscles.contains(.quadriceps) ||
                    $0.primaryMuscles.contains(.hamstrings) ||
                    $0.primaryMuscles.contains(.glutes) ||
                    $0.primaryMuscles.contains(.calves)
                }.prefix(5).map { $0 },
                notes: "Focusing on mind-muscle connection with lighter weights."
            )
        ]
        
        // Insert all workouts into context
        workouts.forEach { context.insert($0) }
        
        return workouts
    }
    
    // Enhanced version with more realistic workout data
    private static func createDetailedWorkout(
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
        
        // Add some time-of-day variation (morning, afternoon, evening workouts)
        let hourOffsets = [7, 12, 17] // 7am, 12pm, 5pm
        let selectedHour = hourOffsets.randomElement() ?? 17
        
        let startDateWithTime = Calendar.current.date(
            bySettingHour: selectedHour,
            minute: Int.random(in: 0...30),
            second: 0,
            of: startDate
        ) ?? startDate
        
        let workoutDuration = Double.random(in: 3600...7200) // 1-2 hours
        let endTime = startDateWithTime.addingTimeInterval(workoutDuration)
        
        let workout = Workout(
            name: name,
            date: startDateWithTime,
            endTime: endTime,
            isFinished: true,
            notes: notes
        )
        
        // Add exercises with realistic sets
        exercises.enumerated().forEach { index, exercise in
            let workoutExercise = WorkoutExercise(
                exerciseID: exercise.id,
                order: index,
                notes: generateExerciseNotes(for: exercise)
            )
            
            if exercise.category == .cardio {
                // Cardio-style sets with variations
                switch exercise.name.lowercased() {
                case let name where name.contains("treadmill"):
                    workoutExercise.sets = [
                        ExerciseSet(
                            reps: 1,
                            weight: 0,
                            notes: "30 mins at \(Int.random(in: 5...8)) mph",
                            isDone: true
                        )
                    ]
                case let name where name.contains("bike") || name.contains("cycling"):
                    workoutExercise.sets = [
                        ExerciseSet(
                            reps: 1,
                            weight: 0,
                            notes: "25 mins, resistance level \(Int.random(in: 5...10))",
                            isDone: true
                        )
                    ]
                case let name where name.contains("rowing"):
                    workoutExercise.sets = [
                        ExerciseSet(
                            reps: 1,
                            weight: 0,
                            notes: "2000m in \(Int.random(in: 7...10)) minutes",
                            isDone: true
                        )
                    ]
                default:
                    workoutExercise.sets = [
                        ExerciseSet(
                            reps: 1,
                            weight: 0,
                            notes: "\(Int.random(in: 20...45)) mins",
                            isDone: true
                        )
                    ]
                }
            } else {
                // Create strength training pattern based on exercise type
                var generatedSets: [ExerciseSet] = []
                
                // Determine if this is a primary or accessory exercise
                let isPrimaryExercise = index < 2 || exercise.mechanic == .compound
                
                if isPrimaryExercise {
                    // Primary compound movements (more sets, pyramiding weights)
                    // Warm-up sets
                    generatedSets.append(
                        ExerciseSet(
                            reps: Int.random(in: 10...15),
                            weight: Double.random(in: 45...85),
                            type: .warmup,
                            order: 0,
                            isDone: true
                        )
                    )
                    
                    generatedSets.append(
                        ExerciseSet(
                            reps: Int.random(in: 8...10),
                            weight: Double.random(in: 95...135),
                            type: .warmup,
                            order: 1,
                            isDone: true
                        )
                    )
                    
                    // Working sets (heavier with lower reps)
                    let mainWeight = Double.random(in: 150...225)
                    
                    for setIndex in 2...5 {
                        // Some variation in weights for progressive overload
                        let setWeight = mainWeight + Double(setIndex - 2) * Double.random(in: 5...15)
                        let repsForSet = max(4, 10 - setIndex) // Decreasing reps as weight increases
                        
                        generatedSets.append(
                            ExerciseSet(
                                reps: repsForSet,
                                weight: setWeight,
                                type: .working, rpe: setIndex == 5 ? Int.random(in: 8...10) : Int.random(in: 7...9),
                                notes: setIndex == 5 ? "PR attempt" : nil,
                                order: setIndex,
                                isDone: true
                            )
                        )
                    }
                } else {
                    // Accessory exercises (fewer sets, more consistent weight/reps)
                    // One warm-up
                    generatedSets.append(
                        ExerciseSet(
                            reps: Int.random(in: 12...15),
                            weight: Double.random(in: 40...70),
                            type: .warmup,
                            order: 0,
                            isDone: true
                        )
                    )
                    
                    // Working sets (consistent)
                    let accessoryWeight = Double.random(in: 70...150)
                    let accessoryReps = Int.random(in: 10...15) // Higher rep ranges for accessories
                    
                    for setIndex in 1...3 {
                        generatedSets.append(
                            ExerciseSet(
                                reps: accessoryReps,
                                weight: accessoryWeight,
                                type: .working, rpe: Int.random(in: 6...8),
                                order: setIndex,
                                isDone: true
                            )
                        )
                    }
                }
                
                workoutExercise.sets = generatedSets
            }
            
            workout.exercises.append(workoutExercise)
        }
        
        return workout
    }
    
    // Helper function to generate realistic exercise notes
    private static func generateExerciseNotes(for exercise: Exercise) -> String? {
        // Only add notes to about 30% of exercises
        guard Bool.random(probability: 0.3) else { return nil }
        
        let possibleNotes = [
            "Focus on contraction at the top",
            "Keep elbows tucked in",
            "Slower on the eccentric portion",
            "Full range of motion",
            "Pause at the bottom",
            "Maintain neutral spine",
            "Squeeze at the top",
            "Avoid locking out joints",
            "Controlled descent",
            "Keep core tight throughout"
        ]
        
        return possibleNotes.randomElement()
    }
}

// Helper extension for more natural random boolean generation
extension Bool {
    static func random(probability: Double) -> Bool {
        return Double.random(in: 0...1) < probability
    }
}
