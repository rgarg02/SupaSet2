//
//  ExerciseImporter.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/5/24.
//
import SwiftData
import Foundation

@Observable
class ExerciseViewModel {
    private(set) var exercises: [Exercise] = []
    private(set) var error: Error?
    private(set) var isLoading = false
    init(){
            loadExercises()
        }
    // Filtered collections
    var strengthExercises: [Exercise] {
        exercises.filter { $0.category == .strength }
    }
    
    var cardioExercises: [Exercise] {
        exercises.filter { $0.category == .cardio }
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
    func loadExercises() {
            guard let filePath = Bundle.main.path(forResource: "exercises", ofType: "json") else { return }
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
                let decoder = JSONDecoder()
                let exercises = try decoder.decode([Exercise].self, from: data)
                self.exercises = exercises
            } catch {
                print("Error while loading or decoding exercises: \(error)")
            }
        }
}
enum ExerciseError: LocalizedError {
    case fileNotFound
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Exercise data file not found in bundle"
        }
    }
}
