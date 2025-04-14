import GRDB
import Foundation

struct WorkoutRecord: Codable, FetchableRecord, PersistableRecord {
    static var databaseTableName = "workout"

    var id: Int64? // Changed to auto-incrementing Int64
    var name: String
    var date: Date
    var endTime: Date?
    var isFinished: Bool
    var notes: String

    enum Columns: String, CodingKey, ColumnExpression {
        case id, name, date, endTime, isFinished, notes
    }

    static let exercises = hasMany(WorkoutExerciseRecord.self)

    // Initializer updated (id is now optional and auto-assigned)
    init(id: Int64? = nil, name: String, date: Date, endTime: Date? = nil, isFinished: Bool, notes: String) {
        self.id = id
        self.name = name
        self.date = date
        self.endTime = endTime
        self.isFinished = isFinished
        self.notes = notes
    }
}
