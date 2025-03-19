//
//  ExerciseSet.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/29/25.
//

import SwiftData
import Foundation
import SwiftUI

enum SetType: String, Codable {
    case warmup
    case working
    case drop
    case failure
    var description: String {
        switch self {
        case .warmup:
            return "Warmup"
        case .working:
            return "Working"
        case .drop:
            return "Drop"
        case .failure:
            return "Failure"
        }
    }
    var color: Color {
        switch self {
        case .failure:
            return Color(UITraitCollection.current.userInterfaceStyle == .dark ? #colorLiteral(red: 1, green: 0.231, blue: 0.188, alpha: 1) : #colorLiteral(red: 0.718, green: 0.11, blue: 0.11, alpha: 1))  // #FF3B30 : #B71C1C
        case .working:
            return Color(UITraitCollection.current.userInterfaceStyle == .dark ? #colorLiteral(red: 0.204, green: 0.78, blue: 0.349, alpha: 1) : #colorLiteral(red: 0.18, green: 0.49, blue: 0.196, alpha: 1))  // #34C759 : #2E7D32
        case .warmup:
            return Color(UITraitCollection.current.userInterfaceStyle == .dark ? #colorLiteral(red: 1, green: 0.584, blue: 0, alpha: 1) : #colorLiteral(red: 0.902, green: 0.318, blue: 0, alpha: 1))  // #FF9500 : #E65100
        case .drop:
            return Color(UITraitCollection.current.userInterfaceStyle == .dark ? #colorLiteral(red: 0.345, green: 0.337, blue: 0.839, alpha: 1) : #colorLiteral(red: 0.192, green: 0.106, blue: 0.573, alpha: 1))  // #5856D6 : #311B92
        }
    }
}
extension SupaSetSchemaV1 {
    @Model
    final class ExerciseSet: Hashable {
        private(set) var id: UUID
        var reps: Int
        var weight: Double
        var type: SetType
        var rpe: Int?
        var notes: String?
        var order: Int
        var isDone: Bool
        
        @Relationship(inverse: \WorkoutExercise.sets)
        var workoutExercise: WorkoutExercise?
        
        init(reps: Int,
             weight: Double,
             type: SetType = .working,
             rpe: Int? = nil,
             notes: String? = nil,
             order: Int = 0,
             isDone: Bool = false) {
            self.id = UUID()
            self.reps = reps
            self.weight = weight
            self.type = .working
            self.rpe = rpe
            self.notes = notes
            self.order = order
            self.isDone = isDone
        }
    }
}
