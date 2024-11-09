//
//  WorkoutAttributes.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/8/24.
//

import ActivityKit
import Foundation

struct WorkoutAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var workoutStartTime: Date
        var currentExerciseName: String
        var setNumber: Int
    }
}
