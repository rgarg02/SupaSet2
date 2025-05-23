//
//  WorkoutAttributes.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/11/24.
//


import ActivityKit
import Foundation
import SwiftUI
import WidgetKit

// MARK: - Activity Attributes
struct WorkoutAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var workoutName: String
        var currentExerciseName: String
        var currentSetNumber: Int
        var totalSets: Int
        var weight: Double
        var targetReps: Int
        var type: SetType
        var exerciseNumber: Int
        var totalExercises: Int
    }
    var workoutId: String
    var startTime: Date
}
