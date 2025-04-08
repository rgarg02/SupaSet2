//
//  ExerciseDetail.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/29/25.
//
import SwiftData
import Foundation
extension SupaSetSchemaV1 {
    @Model
    final class ExerciseDetail: Hashable {
        private(set) var id: UUID
        var exerciseID: String
        var autoRestTimer: TimeInterval
        var notes: String
        var unit: Unit
        
        init(exerciseID: String,
             autoRestTimer: TimeInterval = 0,
             notes: String = "",
             unit: Unit = .lbs) {
            self.id = UUID()
            self.exerciseID = exerciseID
            self.autoRestTimer = autoRestTimer
            self.notes = notes
            self.unit = unit
        }
        
        static func == (lhs: ExerciseDetail, rhs: ExerciseDetail) -> Bool {
            lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
}
