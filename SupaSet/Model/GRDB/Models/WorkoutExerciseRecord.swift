import GRDB
import Foundation

struct WorkoutExerciseRecord: Codable, FetchableRecord, PersistableRecord {
    static var databaseTableName = "workoutExercise"

    var id: Int64? // Changed
    var workoutId: Int64 // Changed (Foreign Key to auto-incrementing WorkoutRecord.id)
    var exerciseID: String // Stays String (refers to ExerciseRecord.id)
    var order: Int
    var notes: String?

    enum Columns: String, CodingKey, ColumnExpression {
        case id, workoutId, exerciseID, order, notes
    }

    static let workout = belongsTo(WorkoutRecord.self)
    static let exerciseSets = hasMany(ExerciseSetRecord.self)
    // static let exerciseEntity = belongsTo(ExerciseRecord.self, key: "exerciseID") // ExerciseRecord.id is String

    // Initializer updated
    init(id: Int64? = nil, workoutId: Int64, exerciseID: String, order: Int, notes: String?) {
        self.id = id
        self.workoutId = workoutId
        self.exerciseID = exerciseID
        self.order = order
        self.notes = notes
    }
}
