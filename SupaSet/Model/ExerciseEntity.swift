//
//  ExerciseEntity.swift
//  SupaSet
//
//  Created by Rishi Garg on 3/2/25.
//



import SwiftData
import Foundation

@Model
final class ExerciseEntity: Identifiable {
    var id: String
    var name: String
    var force: Force?
    var level: Level
    var mechanic: Mechanic?
    var equipment: Equipment?
    var primaryMuscles: [MuscleGroup]
    var secondaryMuscles: [MuscleGroup]
    var instructions: [Instruction]
    var category: Category
    var images: [ImageString]
    var frequency: Int?
    
    init(from exercise: Exercise) {
        self.id = exercise.id
        self.name = exercise.name
        self.force = exercise.force
        self.level = exercise.level
        self.mechanic = exercise.mechanic
        self.equipment = exercise.equipment
        self.primaryMuscles = exercise.primaryMuscles
        self.secondaryMuscles = exercise.secondaryMuscles
        self.instructions = exercise.instructions.map(Instruction.init)
        self.category = exercise.category
        self.images = exercise.images.map(ImageString.init)
        self.frequency = exercise.frequency
    }
}
struct ExerciseLoader {
    static func loadExercises() -> [Exercise]? {
        guard let url = Bundle.main.url(forResource: "exercises_standardized", withExtension: "json") else {
            print("Could not find exercises.json in the bundle.")
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let exercises = try decoder.decode([Exercise].self, from: data)
            return exercises
        } catch {
            print("Error decoding exercises: \(error)")
            return nil
        }
    }
}
@MainActor
func loadAndSaveExercises(container: ModelContainer) {
    let userDefaultsKey = "hasLoadedExercises"
    if !UserDefaults.standard.bool(forKey: userDefaultsKey) {
        guard let exercises = ExerciseLoader.loadExercises() else { return }
        let context = container.mainContext
        
        // Convert each Exercise to an ExerciseEntity and insert it into the context.
        exercises.forEach { exercise in
            let exerciseEntity = ExerciseEntity(from: exercise)
            context.insert(exerciseEntity)
        }
        
        do {
            try context.save()
            UserDefaults.standard.set(true, forKey: userDefaultsKey)
            print("Exercises loaded and saved successfully.")
        } catch {
            print("Failed to save exercises: \(error)")
        }
    }
}
