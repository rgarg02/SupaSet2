//
//  WorkoutModel.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/5/24.
//

import SwiftUI
import SwiftData

// MARK: - Enums
enum Force: String, Codable {
    case none
    case `static`
    case pull
    case push
}

enum Level: String, Codable, CaseIterable, Hashable {
    case beginner
    case intermediate
    case expert
    var color: Color {
        switch self {
        case .beginner: return .green
        case .intermediate: return .orange
        case .expert: return .red
        }
    }
}

enum Mechanic: String, Codable {
    case isolation
    case compound
    case none
}

// Update the enums in WorkoutModel.swift to conform to CaseIterable
enum Category: String, Codable, CaseIterable, Hashable {
    case powerlifting
    case strength
    case stretching
    case cardio
    case olympicWeightlifting = "olympic weightlifting"
    case strongman
    case plyometrics
}

enum Equipment: String, Codable, CaseIterable, Hashable {
    case none
    case medicineBall = "medicine ball"
    case dumbbell
    case bodyOnly = "body only"
    case bands
    case kettlebells
    case foamRoll = "foam roll"
    case cable
    case machine
    case barbell
    case exerciseBall = "exercise ball"
    case ezCurlBar = "e-z curl bar"
    case other
}

enum MuscleGroup: String, Codable, CaseIterable, Hashable {
    case abdominals
    case abductors
    case adductors
    case biceps
    case calves
    case chest
    case forearms
    case glutes
    case hamstrings
    case lats
    case lowerBack = "lower back"
    case middleBack = "middle back"
    case neck
    case quadriceps
    case shoulders
    case traps
    case triceps
}


// MARK: - Exercise Model
struct Exercise: Codable, Identifiable, Equatable, Hashable {
    var id: String
    var name: String
    var force: Force?
    var level: Level
    var mechanic: Mechanic?
    var equipment: Equipment?
    var primaryMuscles: [MuscleGroup]
    var secondaryMuscles: [MuscleGroup]
    var instructions: [String]
    var category: Category
    var images: [String]
    var frequency : Int?
    static func == (lhs: Exercise, rhs: Exercise) -> Bool {
        return lhs.id == rhs.id
    }
}

enum Unit: String, Codable, CaseIterable {
    case lbs
    case kgs
    // return string representation of the unit
}
