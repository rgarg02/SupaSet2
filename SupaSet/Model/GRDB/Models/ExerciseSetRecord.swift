import GRDB
import Foundation
import SwiftUI // For SetType enum, if needed

struct ExerciseSetRecord: Codable, FetchableRecord, PersistableRecord {
    static var databaseTableName = "exerciseSet"

    var id: Int64? // Changed
    var workoutExerciseId: Int64 // Changed (Foreign Key to auto-incrementing WorkoutExerciseRecord.id)
    var reps: Int
    var weight: Double
    var type: String // Stores SetType raw value
    var rpe: Double?
    var notes: String?
    var order: Int
    var isDone: Bool

    enum Columns: String, CodingKey, ColumnExpression {
        case id, workoutExerciseId, reps, weight, type, rpe, notes, order, isDone
    }

    static let workoutExercise = belongsTo(WorkoutExerciseRecord.self)

    // Initializer updated
    init(id: Int64? = nil, workoutExerciseId: Int64, reps: Int, weight: Double, type: SetType, rpe: Double? = nil, notes: String? = nil, order: Int, isDone: Bool) {
        self.id = id
        self.workoutExerciseId = workoutExerciseId
        self.reps = reps
        self.weight = weight
        self.type = type.rawValue
        self.rpe = rpe
        self.notes = notes
        self.order = order
        self.isDone = isDone
    }

    var setType: SetType? { SetType(rawValue: type) }
}
