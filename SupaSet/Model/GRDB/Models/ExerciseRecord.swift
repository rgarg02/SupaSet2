//
//  ExerciseRecord.swift
//  SupaSetGRDB
//
//  Created by Rishi Garg on 4/13/25.
//


//
//  ExerciseRecord.swift
//  SupaSet
//
//  Created by [Your Name/AI] on [Date]
//

import Foundation
import GRDB
import SwiftUICore
// MARK: - Main Exercise Table Record
struct ExerciseRecord: Codable, FetchableRecord, PersistableRecord {
    static var databaseTableName = "exercise"

    var id: String              // Primary Key
    var name: String
    var force: Force?           // Store rawValue (String)
    var level: Level            // Store rawValue (String)
    var mechanic: Mechanic?     // Store rawValue (String)
    var equipment: Equipment?   // Store rawValue (String)
    var category: Category      // Store rawValue (String)
    var frequency: Int?
    // MARK: - Associations (MUST be inside the struct)
    static let primaryMuscles = hasMany(ExercisePrimaryMuscle.self)
    static let secondaryMuscles = hasMany(ExerciseSecondaryMuscle.self)
    // Helper initializer to convert from the JSON model
    init(exercise: Exercise) {
        self.id = exercise.id
        self.name = exercise.name
        self.force = exercise.force
        self.level = exercise.level
        self.mechanic = exercise.mechanic
        self.equipment = exercise.equipment
        self.category = exercise.category
        self.frequency = exercise.frequency
    }

    // Define columns for Codable conformance if needed,
    // or rely on automatic synthesis if names match.
    // enum CodingKeys: String, CodingKey { ... }

    // Define primary key for PersistableRecord conformance
    static func persistenceConflictPolicy(for primaryKey: String) -> PersistenceConflictPolicy {
        // Assuming `id` is unique and shouldn't be replaced if it exists
        return PersistenceConflictPolicy(insert: .ignore, update: .abort)
    }
}

// MARK: - Relational Table Records

struct ExercisePrimaryMuscle: Codable, FetchableRecord, PersistableRecord {
    static var databaseTableName = "exercisePrimaryMuscle"
    static let exercise = belongsTo(ExerciseRecord.self) // Define relationship

    var id: Int64? // Auto-incrementing primary key for the relation itself
    var exerciseId: String
    var muscle: MuscleGroup // Store rawValue (String)

    // Define table columns if necessary
    enum Columns: String, ColumnExpression {
        case id, exerciseId, muscle
    }
}

struct ExerciseSecondaryMuscle: Codable, FetchableRecord, PersistableRecord {
    static var databaseTableName = "exerciseSecondaryMuscle"
    static let exercise = belongsTo(ExerciseRecord.self) // Define relationship

    var id: Int64?
    var exerciseId: String
    var muscle: MuscleGroup

    enum Columns: String, ColumnExpression {
        case id, exerciseId, muscle
    }
}

struct ExerciseInstruction: Codable, FetchableRecord, PersistableRecord {
    static var databaseTableName = "exerciseInstruction"
    static let exercise = belongsTo(ExerciseRecord.self) // Define relationship

    var id: Int64?
    var exerciseId: String
    var text: String
    var orderIndex: Int // To maintain the order of instructions

    enum Columns: String, ColumnExpression {
        case id, exerciseId, text, orderIndex
    }
}

struct ExerciseImage: Codable, FetchableRecord, PersistableRecord {
    static var databaseTableName = "exerciseImage"
    static let exercise = belongsTo(ExerciseRecord.self) // Define relationship

    var id: Int64?
    var exerciseId: String
    var url: String
    var orderIndex: Int // To maintain the order of images

     enum Columns: String, ColumnExpression {
        case id, exerciseId, url, orderIndex
    }
}
