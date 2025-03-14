//
//  ExerciseImporter.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/5/24.
//
import SwiftData
import Foundation
import NaturalLanguage

extension String {
    // Remove content within parentheses for comparison
//    private func removeParentheses() -> String {
//        var result = ""
//        var depth = 0
//        
//        for char in self {
//            if char == "(" {
//                depth += 1
//            } else if char == ")" {
//                depth -= 1
//            } else if depth == 0 {
//                result.append(char)
//            }
//        }
//        
//        return result.trimmingCharacters(in: .whitespacesAndNewlines)
//    }
    
    func similarity(to other: String) -> Double {
        // Remove content within parentheses from both strings
//        let cleanSelf = self.removeParentheses()
//        let cleanOther = other.removeParentheses()
        
        let tokenizer = NLTokenizer(unit: .word)
        
        // Tokenize cleaned strings
        tokenizer.string = self.lowercased()
        let tokensA = Set(tokenizer.tokens(for: self.startIndex..<self.endIndex).map { String(self[$0]) })
        
        tokenizer.string = other.lowercased()
        let tokensB = Set(tokenizer.tokens(for: other.startIndex..<other.endIndex).map { String(other[$0]) })
        
        let intersection = tokensA.intersection(tokensB).count
        let union = tokensA.union(tokensB).count
        
        return union == 0 ? 0.0 : Double(intersection) / Double(union)
    }
}
enum ExerciseImporterError: Error {
    case unexpected
    case couldNotLoad
}
@Observable
class ExerciseViewModel {
    private(set) var exercises: [Exercise] = []
    private(set) var isLoading = false
    private var modelContext: ModelContext
    private var _newExercises: [Exercise] = []
    private var _confirmedNewExercises: [Exercise] = []
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        Task {
            try? await loadExercises()
        }
    }
    func getExerciseName(for exerciseId: String) -> String {
        // Find the exercise in the view model by ID and return its name
        exercises.first(where: { $0.id == exerciseId })?.name ?? ""
    }
    func findOrCreateExerciseID(for name: String) -> String {
        let threshold: Double = 0.85  // Adjust this for better accuracy
        var bestMatch: (id: String, similarity: Double)? = nil
        for exercise in exercises {
            let similarity = name.similarity(to: exercise.name)
            if similarity >= threshold, similarity > (bestMatch?.similarity ?? 0) {
                bestMatch = (exercise.id, similarity)
            }
        }
        
        if let bestMatch = bestMatch {
            return bestMatch.id
        } else {
            return createNewExercise(with: name)
        }
    }
    func createNewExercise(with name: String) -> String {
        let newExercise = Exercise(
            id: UUID().uuidString,  // Generate unique ID
            name: name,
            force: nil,
            level: .beginner,  // Default level
            mechanic: nil,
            equipment: nil,
            primaryMuscles: [],
            secondaryMuscles: [],
            instructions: [],
            category: .strength,  // Default category
            images: [],
            frequency: nil
        )
        exercises.append(newExercise)
        _newExercises.append(newExercise)
        
        return newExercise.id
    }

    // Update the addNewExercisesToStore method in ExerciseViewModel
    func addNewExercisesToStore() {
        // This is now just for compatibility - we'll use addConfirmedExercisesToStore instead
        for exercise in _newExercises {
            let entity = ExerciseEntity(from: exercise)
            modelContext.insert(entity)
        }
        try? modelContext.save()
        _newExercises.removeAll()
    }
    // Search and filter
    func exercises(matching query: String) -> [Exercise] {
        guard !query.isEmpty else { return exercises }
        return exercises.filter {
            $0.name.localizedCaseInsensitiveContains(query) ||
            $0.primaryMuscles.map(\.rawValue).contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }
    
    func exercises(forMuscle muscle: MuscleGroup) -> [Exercise] {
        exercises.filter {
            $0.primaryMuscles.contains(muscle) || $0.secondaryMuscles.contains(muscle)
        }
    }
    
    func exercises(forEquipment equipment: Equipment) -> [Exercise] {
        exercises.filter { $0.equipment == equipment }
    }
    
    // Load data
    // Load data from SwiftData
    @MainActor
    func loadExercises() async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Create a fetch descriptor for ExerciseEntity
            let descriptor = FetchDescriptor<ExerciseEntity>()
            
            // Fetch all exercise entities
            let exerciseEntities = try modelContext.fetch(descriptor)
            
            // Map to Exercise structs
            self.exercises = exerciseEntities.map { entity -> Exercise in
                // Convert primary muscles
                let primaryMuscles = entity.primaryMuscles
                
                // Convert secondary muscles
                let secondaryMuscles = entity.secondaryMuscles
                
                // Create Exercise object
                return Exercise(
                    id: entity.id,
                    name: entity.name,
                    force: entity.force,
                    level: entity.level,
                    mechanic: entity.mechanic,
                    equipment: entity.equipment,
                    primaryMuscles: primaryMuscles,
                    secondaryMuscles: secondaryMuscles,
                    instructions: entity.instructions.map {$0.text},
                    category: entity.category,
                    images: entity.images.map { $0.url },
                    frequency: entity.frequency
                )
            }
            
            print("Loaded \(self.exercises.count) exercises from SwiftData")
        } catch {
            print("Failed to load exercises from SwiftData: \(error.localizedDescription)")
            throw ExerciseImporterError.couldNotLoad
        }
        }}
enum ExerciseError: LocalizedError {
    case fileNotFound
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Exercise data file not found in bundle"
        }
    }
}
extension ExerciseViewModel {
    var newExercises: [Exercise] {
            get { _newExercises }
        }
    func mapExerciseToExisting(fromId: String, toId: String) {
        // Update all workouts that use fromId to use toId instead
        Task {
            await performExerciseMapping(fromId: fromId, toId: toId)
        }
        
        // Remove the new exercise from our tracking lists
        _newExercises.removeAll(where: { $0.id == fromId })
        exercises.removeAll(where: { $0.id == fromId })
    }
    
    func confirmNewExercise(_ exerciseId: String) {
        // Mark this exercise as confirmed to be added
        if let index = _newExercises.firstIndex(where: { $0.id == exerciseId }) {
            _confirmedNewExercises.append(_newExercises[index])
        }
    }
    
    func clearNewExercises() {
        // Clear all new exercises (used when canceling)
        exercises.removeAll(where: { exercise in
            _newExercises.contains(where: { $0.id == exercise.id })
        })
        _newExercises.removeAll()
        _confirmedNewExercises.removeAll()
    }
    
    func addConfirmedExercisesToStore() {
        // Add only the confirmed new exercises to the store
        for exercise in _confirmedNewExercises {
            let entity = ExerciseEntity(from: exercise)
            modelContext.insert(entity)
        }
        try? modelContext.save()
        
        // Clear lists
        _newExercises.removeAll()
        _confirmedNewExercises.removeAll()
    }
    
    @MainActor
    private func performExerciseMapping(fromId: String, toId: String) async {
        do {
            // Fetch all workout exercises that use the fromId
            let descriptor = FetchDescriptor<WorkoutExercise>(predicate: #Predicate<WorkoutExercise> {
                $0.exerciseID == fromId
            })
            
            let workoutExercises = try modelContext.fetch(descriptor)
            
            // Update all references to use the toId
            for workoutExercise in workoutExercises {
                workoutExercise.exerciseID = toId
            }
            
            try modelContext.save()
        } catch {
            print("Error mapping exercise: \(error.localizedDescription)")
        }
    }
}
