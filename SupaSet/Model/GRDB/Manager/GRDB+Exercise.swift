//
//  GRDB+Exercise.swift
//  SupaSet
//
//  Created by Rishi Garg on 4/14/25.
//

import GRDB

extension GRDBManager {
    // MARK: - Paginated Data Access
    
    /// Fetches a specific page of ExerciseRecords.
    /// - Parameters:
    ///   - page: The page number to fetch (1-based).
    ///   - pageSize: The number of items per page.
    /// - Returns: An array of ExerciseRecord for the requested page.
    func fetchExerciseRecords(page: Int, pageSize: Int) async throws -> [ExerciseRecord] {
        guard page >= 1 else {
            logger.warning("Requested page must be 1 or greater.")
            return [] // Or throw an error
        }
        let offset = (page - 1) * pageSize
        
        return try await dbQueue.read { db in
            try ExerciseRecord
                .order(Column("name")) // Order consistently for pagination
                .limit(pageSize, offset: offset)
                .fetchAll(db)
        }
    }
    
    /// Fetches the total count of exercises in the database.
    /// - Returns: The total number of exercises.
    func fetchTotalExerciseCount() async throws -> Int {
        return try await dbQueue.read { db in
            try ExerciseRecord.fetchCount(db)
        }
    }
    func fetchPrimaryMuscles(id: String) async throws -> [MuscleGroup] {
        return try await dbQueue.read { db in
            let primaryRequest = ExercisePrimaryMuscle.filter(ExercisePrimaryMuscle.Columns.exerciseId == id)
            let primaryMuscles = try primaryRequest.fetchAll(db).map { $0.muscle }
            return primaryMuscles
        }
    }
    /// Fetches the full details for a single exercise, including related data.
    /// Note: This demonstrates fetching related data if needed later.
    /// The basic list view might only need ExerciseRecord.
    func fetchFullExercise(id: String) async throws -> Exercise? {
        return try await dbQueue.read { db in
            // 1. Fetch the main record
            guard let record = try ExerciseRecord.fetchOne(db, key: id) else {
                return nil
            }
            
            // 2. Fetch related data using associations (if defined) or separate queries
            let primaryRequest = ExercisePrimaryMuscle.filter(ExercisePrimaryMuscle.Columns.exerciseId == id)
            let secondaryRequest = ExerciseSecondaryMuscle.filter(ExerciseSecondaryMuscle.Columns.exerciseId == id)
            let instructionRequest = ExerciseInstruction.filter(ExerciseInstruction.Columns.exerciseId == id).order(ExerciseInstruction.Columns.orderIndex)
            let imageRequest = ExerciseImage.filter(ExerciseImage.Columns.exerciseId == id).order(ExerciseImage.Columns.orderIndex)
            
            let primaryMuscles = try primaryRequest.fetchAll(db).map { $0.muscle }
            let secondaryMuscles = try secondaryRequest.fetchAll(db).map { $0.muscle }
            let instructions = try instructionRequest.fetchAll(db).map { $0.text }
            let images = try imageRequest.fetchAll(db).map { $0.url }
            
            // 3. Assemble the original Exercise model
            // (Make sure your original Exercise struct has an appropriate initializer)
            return Exercise(
                id: record.id,
                name: record.name,
                force: record.force,
                level: record.level,
                mechanic: record.mechanic,
                equipment: record.equipment,
                primaryMuscles: primaryMuscles,
                secondaryMuscles: secondaryMuscles,
                instructions: instructions,
                category: record.category,
                images: images,
                frequency: record.frequency
            )
        }
    }
    
    /// Fetches the total count of exercises matching the optional filters.
    /// - Parameters:
    ///   - category: Optional category filter.
    ///   - muscleGroup: Optional muscle group filter.
    ///   - level: Optional level filter.
    ///   - equipment: Optional equipment filter.
    /// - Returns: The total number of exercises matching the filters.
    func fetchTotalExerciseCount(
        category: Category? = nil,
        muscleGroup: MuscleGroup? = nil,
        level: Level? = nil,
        equipment: Equipment? = nil
    ) async throws -> Int {
        // Get the base filtered request
        let request = filteredExerciseRequest(
            category: category,
            muscleGroup: muscleGroup,
            level: level,
            equipment: equipment
        )
        // Fetch the count based on the filtered request
        return try await dbQueue.read { db in
            try request.fetchCount(db)
        }
    }
    
    // MARK: - Paginated & Filtered Data Access
    
    /// Creates a base filtered request without pagination or ordering.
    private func filteredExerciseRequest(
        category: Category? = nil,
        muscleGroup: MuscleGroup? = nil,
        level: Level? = nil,
        equipment: Equipment? = nil
    ) -> QueryInterfaceRequest<ExerciseRecord> {
        
        var request = ExerciseRecord.all()
        
        // Filter by direct columns
        if let category = category {
            request = request.filter(Column("category") == category.rawValue)
        }
        if let level = level {
            request = request.filter(Column("level") == level.rawValue)
        }
        if let equipment = equipment {
            request = request.filter(Column("equipment") == equipment.rawValue)
        }
        
        // Filter by related muscle group (primary OR secondary)
        if let muscleGroup = muscleGroup {
            // We need to join the muscle tables to filter by muscle group
            // Use aliases to avoid naming conflicts if joining multiple times or for complex queries
            let primaryAlias = TableAlias(name: "primary")
            
            // Find exercises associated with the selected muscle group
            // either in the primary or secondary muscle table.
            request = request
                .joining(optional: ExerciseRecord.primaryMuscles.aliased(primaryAlias)) // Optional join
                .filter(
                    primaryAlias[ExercisePrimaryMuscle.Columns.muscle] == muscleGroup.rawValue
                )
                .distinct() // Ensure exercises aren't duplicated if they match both joins
        }
        
        return request
    }
    
    
    /// Fetches a specific page of potentially filtered ExerciseRecords.
    /// - Parameters:
    ///   - page: The page number to fetch (1-based).
    ///   - pageSize: The number of items per page.
    ///   - category: Optional category filter.
    ///   - muscleGroup: Optional muscle group filter.
    ///   - level: Optional level filter.
    ///   - equipment: Optional equipment filter.
    /// - Returns: An array of ExerciseRecord for the requested page and filters.
    func fetchExerciseRecords(
        page: Int,
        pageSize: Int,
        category: Category? = nil,
        muscleGroup: MuscleGroup? = nil,
        level: Level? = nil,
        equipment: Equipment? = nil
    ) async throws -> [ExerciseRecord] {
        
        guard page >= 1 else {
            logger.warning("Requested page must be 1 or greater.")
            return []
        }
        let offset = (page - 1) * pageSize
        
        // Get the base filtered request
        let request = filteredExerciseRequest(
            category: category,
            muscleGroup: muscleGroup,
            level: level,
            equipment: equipment
        )
        
        // Apply ordering and pagination
        return try await dbQueue.read { db in
            try request
                .order(Column("name").asc) // Consistent ordering is crucial for pagination
                .limit(pageSize, offset: offset)
                .fetchAll(db)
        }
    }
}
