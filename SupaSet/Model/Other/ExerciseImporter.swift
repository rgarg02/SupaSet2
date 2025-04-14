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
        //        exercises.first(where: { $0.id == exerciseId })?.name ?? ""
        do {
            var descriptor = FetchDescriptor<ExerciseEntity>(predicate: #Predicate {$0.id == exerciseId})
            descriptor.fetchLimit = 1
            descriptor.propertiesToFetch = [\.name]
            let exerciseName = try modelContext.fetch(descriptor)
            return exerciseName.first?.name ?? ""
        } catch {
            return ""
        }
    }

    func getExercise(for exerciseId: String) -> ExerciseEntity? {
        do {
            var descriptor = FetchDescriptor<ExerciseEntity>(predicate: #Predicate {$0.id == exerciseId})
            descriptor.fetchLimit = 1
            let exercises = try modelContext.fetch(descriptor)
            if let exercise = exercises.first {
                return exercise
            }
            return nil
        } catch {
            return nil
        }
    }
    func findOrCreateExerciseID(for name: String) -> String {
        let threshold: Double = 0.85  // Adjust this for better accuracy
        var bestMatch: (id: String, similarity: Double)? = nil
        let descriptor = FetchDescriptor<ExerciseEntity>()
        if let exercises = try? modelContext.fetch(descriptor) {
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
        return createNewExercise(with: name)
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
    @MainActor
    func loadAndSaveExercises() {
        guard let exercises = ExerciseLoader.loadExercises() else { return }
        let context = modelContext
        
        exercises.forEach { exercise in
            let exerciseEntity = ExerciseEntity(from: exercise)
            context.insert(exerciseEntity)
        }
        
        do {
            try context.save()
            print("Exercises loaded and saved successfully.")
        } catch {
            print("Failed to save exercises: \(error)")
        }
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
            if exerciseEntities.isEmpty {
                loadAndSaveExercises()
            }
        } catch {
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
    }
    
    func confirmNewExercise(_ exerciseId: String) {
        // Mark this exercise as confirmed to be added
        if let index = _newExercises.firstIndex(where: { $0.id == exerciseId }) {
            _confirmedNewExercises.append(_newExercises[index])
        }
    }
    
    func clearNewExercises() {
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
