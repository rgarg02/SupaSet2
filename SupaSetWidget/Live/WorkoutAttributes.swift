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
        var currentExerciseName: String
        var currentSetNumber: Int
        var totalSets: Int
        var weight: Double
        var targetReps: Int
        var isWarmupSet: Bool
        var exerciseNumber: Int
        var totalExercises: Int
    }
    var workoutId: String
    var workoutName: String
    var startTime: Date
}
