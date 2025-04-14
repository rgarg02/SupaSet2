//
//  GRDB+ExerciseJson.swift
//  SupaSet
//
//  Created by Rishi Garg on 4/14/25.
//

import Foundation

extension GRDBManager{
    // MARK: - Data Import
    func importExercisesFromJSONIfNeeded(fileName: String = "exercises") {
        // Check if import has already been done
        guard !UserDefaults.standard.bool(forKey: initialImportCompletedKey) else {
            logger.info("Initial exercise import already completed. Skipping.")
            return
        }
        
        logger.info("Starting initial exercise import from \(fileName).json...")
        
        // 1. Find and load JSON data
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            logger.error("Failed to find \(fileName).json in bundle.")
            return
        }
        
        guard let data = try? Data(contentsOf: url) else {
            logger.error("Failed to load data from \(fileName).json.")
            return
        }
        
        // 2. Decode JSON into the original Exercise models
        let decoder = JSONDecoder()
        guard let exercises = try? decoder.decode([Exercise].self, from: data) else {
            logger.error("Failed to decode \(fileName).json.")
            return
        }
        
        guard !exercises.isEmpty else {
            logger.warning("\(fileName).json is empty or decoding resulted in an empty array.")
            return
        }
        
        // 3. Insert data into the database within a transaction
        do {
            try dbQueue.write { db in
                for exercise in exercises {
                    // Create and insert the main exercise record
                    let exerciseRecord = ExerciseRecord(exercise: exercise)
                    try exerciseRecord.insert(db)
                    
                    // Insert related data
                    for muscle in exercise.primaryMuscles {
                        let relation = ExercisePrimaryMuscle(exerciseId: exercise.id, muscle: muscle)
                        try relation.insert(db)
                    }
                    for muscle in exercise.secondaryMuscles {
                        let relation = ExerciseSecondaryMuscle(exerciseId: exercise.id, muscle: muscle)
                        try relation.insert(db)
                    }
                    for (index, instructionText) in exercise.instructions.enumerated() {
                        let relation = ExerciseInstruction(exerciseId: exercise.id, text: instructionText, orderIndex: index)
                        try relation.insert(db)
                    }
                    for (index, imageUrl) in exercise.images.enumerated() {
                        let relation = ExerciseImage(exerciseId: exercise.id, url: imageUrl, orderIndex: index)
                        try relation.insert(db)
                    }
                }
            }
            // Mark import as complete on success
            UserDefaults.standard.set(true, forKey: initialImportCompletedKey)
            logger.info("Successfully imported \(exercises.count) exercises into the database.")
            
        } catch {
            logger.error("Failed to import exercises into database: \(error.localizedDescription)")
            // Consider rolling back or cleaning up potentially partial data if needed,
            // though the transaction should handle atomicity.
            // Reset the flag so it can try again next time.
            UserDefaults.standard.set(false, forKey: initialImportCompletedKey)
        }
    }
}
