//
//  GRDBManager.swift
//  SupaSetGRDB
//
//  Created by Rishi Garg on 4/13/25.
//


import Foundation
import GRDB
import os // For logging

class GRDBManager {
    
    static let shared = GRDBManager()
    internal var dbQueue: DatabaseQueue!
    internal let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "GRDBManager")
    
    internal let initialImportCompletedKey = "initialExerciseImportCompleted"
    
    private init() {
        setupDatabase()
    }
    
    // MARK: - Database Setup
    private func setupDatabase() {
        do {
            let fileManager = FileManager.default
            // Choose a location for the database file (e.g., Application Support)
            let dbURL = try fileManager
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("supaset.sqlite")
            
            logger.info("Database path: \(dbURL.path)")
            
            // Connect to the database
            dbQueue = try DatabaseQueue(path: dbURL.path)
            
            // Define and run migrations
            try runMigrations()
            
        } catch {
            logger.critical("Failed to initialize database: \(error.localizedDescription)")
            // Handle critical error - perhaps crash or show an error message
            fatalError("Could not set up database: \(error)")
        }
    }
    
    // MARK: - Migrations
    private func runMigrations() throws {
        var migrator = DatabaseMigrator()
        
#if DEBUG
        // Speed up development by erasing the database on every launch
        // migrator.eraseDatabaseOnSchemaChange = true
#endif
        
        migrator.registerMigration("v1.0-createTables") { db in
            // Create Exercise table
            try db.create(table: ExerciseRecord.databaseTableName) { t in
                t.primaryKey("id", .text).notNull()
                t.column("name", .text).notNull()
                t.column("force", .text) // Store enum raw value
                t.column("level", .text).notNull()
                t.column("mechanic", .text)
                t.column("equipment", .text)
                t.column("category", .text).notNull()
                t.column("frequency", .integer)
            }
            // Add index on name for faster searching (optional but recommended)
            try db.create(index: "index_exercise_name", on: ExerciseRecord.databaseTableName, columns: ["name"])
            
            
            // Create ExercisePrimaryMuscle table
            try db.create(table: ExercisePrimaryMuscle.databaseTableName) { t in
                t.autoIncrementedPrimaryKey("id")
                // Foreign key constraint to link to ExerciseRecord
                t.column("exerciseId", .text).notNull().indexed()
                    .references(ExerciseRecord.databaseTableName, onDelete: .cascade)
                t.column("muscle", .text).notNull()
            }
            
            // Create ExerciseSecondaryMuscle table
            try db.create(table: ExerciseSecondaryMuscle.databaseTableName) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("exerciseId", .text).notNull().indexed()
                    .references(ExerciseRecord.databaseTableName, onDelete: .cascade)
                t.column("muscle", .text).notNull()
            }
            
            // Create ExerciseInstruction table
            try db.create(table: ExerciseInstruction.databaseTableName) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("exerciseId", .text).notNull().indexed()
                    .references(ExerciseRecord.databaseTableName, onDelete: .cascade)
                t.column("text", .text).notNull()
                t.column("orderIndex", .integer).notNull() // To preserve order
            }
            // Add index for efficient lookup of instructions by exercise
            try db.create(index: "index_instruction_exerciseId_order", on: ExerciseInstruction.databaseTableName, columns: ["exerciseId", "orderIndex"])
            
            
            // Create ExerciseImage table
            try db.create(table: ExerciseImage.databaseTableName) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("exerciseId", .text).notNull().indexed()
                    .references(ExerciseRecord.databaseTableName, onDelete: .cascade)
                t.column("url", .text).notNull()
                t.column("orderIndex", .integer).notNull() // To preserve order
            }
            // Add index for efficient lookup of images by exercise
            try db.create(index: "index_image_exerciseId_order", on: ExerciseImage.databaseTableName, columns: ["exerciseId", "orderIndex"])
            try db.create(table: WorkoutRecord.databaseTableName) { t in
                t.autoIncrementedPrimaryKey(WorkoutRecord.Columns.id.rawValue) // Changed
                t.column(WorkoutRecord.Columns.name.rawValue, .text).notNull()
                t.column(WorkoutRecord.Columns.date.rawValue, .datetime).notNull().indexed()
                t.column(WorkoutRecord.Columns.endTime.rawValue, .datetime)
                t.column(WorkoutRecord.Columns.isFinished.rawValue, .boolean).notNull()
                t.column(WorkoutRecord.Columns.notes.rawValue, .text).notNull()
            }
            try db.create(table: WorkoutExerciseRecord.databaseTableName) { t in
                t.autoIncrementedPrimaryKey(WorkoutExerciseRecord.Columns.id.rawValue)
                t.column(WorkoutExerciseRecord.Columns.workoutId.rawValue, .text).notNull().indexed()
                    .references(WorkoutRecord.databaseTableName, onDelete: .cascade) // Cascade delete if workout is deleted
                t.column(WorkoutExerciseRecord.Columns.exerciseID.rawValue, .text).notNull().indexed()
                    // Optional: Add FK to ExerciseRecord if it exists and makes sense
                    // .references(ExerciseRecord.databaseTableName, onDelete: .restrict) // Or .setNull depending on requirement
                t.column(WorkoutExerciseRecord.Columns.order.rawValue, .integer).notNull()
                t.column(WorkoutExerciseRecord.Columns.notes.rawValue, .text)
            }
            
            // Index for faster lookup of exercises within a workout
            try db.create(index: "idx_workoutExercise_workoutId_order", on: WorkoutExerciseRecord.databaseTableName, columns: [WorkoutExerciseRecord.Columns.workoutId.rawValue, WorkoutExerciseRecord.Columns.order.rawValue])
            try db.create(table: ExerciseSetRecord.databaseTableName) { t in
                t.autoIncrementedPrimaryKey(ExerciseSetRecord.Columns.id.rawValue)
                t.column(ExerciseSetRecord.Columns.workoutExerciseId.rawValue, .text).notNull().indexed()
                    .references(WorkoutExerciseRecord.databaseTableName, onDelete: .cascade) // Cascade delete if workoutExercise is deleted
                t.column(ExerciseSetRecord.Columns.reps.rawValue, .integer).notNull()
                t.column(ExerciseSetRecord.Columns.weight.rawValue, .double).notNull()
                t.column(ExerciseSetRecord.Columns.type.rawValue, .text).notNull() // Store enum raw value
                t.column(ExerciseSetRecord.Columns.rpe.rawValue, .double)
                t.column(ExerciseSetRecord.Columns.notes.rawValue, .text)
                t.column(ExerciseSetRecord.Columns.order.rawValue, .integer).notNull()
                t.column(ExerciseSetRecord.Columns.isDone.rawValue, .boolean).notNull()
            }
            // Index for faster lookup of sets within a workout exercise
            try db.create(index: "idx_exerciseSet_workoutExerciseId_order", on: ExerciseSetRecord.databaseTableName, columns: [ExerciseSetRecord.Columns.workoutExerciseId.rawValue, ExerciseSetRecord.Columns.order.rawValue])
            self.logger.info("Database migration 'v1.0-createTables' successful.")
        }
        
        // --- Add future migrations here ---
        // migrator.registerMigration("v1.1-addFeature") { db in ... }
        
        // Apply migrations
        try migrator.migrate(dbQueue)
        logger.info("Database migrations completed.")
    }
    
}
