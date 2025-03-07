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
    var image: Image {
        switch self {
        case .none:
            return Image(systemName: "questionmark")
        case .medicineBall:
            return Image(systemName: "circle.fill")
        case .dumbbell:
            return Image(systemName: "dumbbell.fill")
        case .bodyOnly:
            return Image(systemName: "figure.stand")
        case .bands:
            return Image("band") // Custom image in Assets
        case .kettlebells:
            return Image("kettlebell") // Custom image in Assets
        case .foamRoll:
            return Image(systemName: "cylinder.fill")
        case .cable:
            return Image(systemName: "arrow.up.and.down")
        case .machine:
            return Image(systemName: "gearshape.fill")
        case .barbell:
            return Image("barbell")
        case .exerciseBall:
            return Image(systemName: "circle")
        case .ezCurlBar:
            return Image("ez-bar")
        case .other:
            return Image(systemName: "questionmark.circle")
        }
        
    }
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
    var description: String {
        switch self {
        case .lats: return "Lats"
        case .middleBack: return "Middle Back"
        case .lowerBack: return "Lower Back"
        case .traps: return "Traps"
        case .chest: return "Chest"
        case .abdominals: return "Abdominals"
        case .shoulders: return "Shoulders"
        case .biceps: return "Biceps"
        case .triceps: return "Triceps"
        case .forearms: return "Forearms"
        case .quadriceps: return "Quadriceps"
        case .hamstrings: return "Hamstrings"
        case .calves: return "Calves"
        case .glutes: return "Glutes"
        case .abductors: return "Abductors"
        case .adductors: return "Adductors"
        case .neck: return "Neck"
        }
    }
}
struct Instruction: Codable, Hashable {
    var text: String
}
struct ImageString: Codable, Hashable{
    var url: String
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
