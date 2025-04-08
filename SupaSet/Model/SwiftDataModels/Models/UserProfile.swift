//
//  UserProfile.swift
//  SupaSet
//
//  Created by Rishi Garg on 3/6/25.
//


import SwiftData
import Foundation


@Model
final class UserProfile {
    var id: UUID
    var name: String
    var age: Int
    var gender: Gender
    var height: Double  // in cm
    var weight: Double  // in kg
    var bodyFatPercentage: Double?
    var fitnessGoal: FitnessGoal
    var experienceLevel: ExperienceLevel
    var trainingDaysPerWeek: Int
    var equipmentAccess: [Equipment]
    var createdAt: Date
    var updatedAt: Date
    
    // Computed property for BMI
    var bmi: Double {
        let heightInMeters = height / 100
        return weight / (heightInMeters * heightInMeters)
    }
    
    init(
        name: String,
        age: Int,
        gender: Gender,
        height: Double,
        weight: Double,
        bodyFatPercentage: Double? = nil,
        fitnessGoal: FitnessGoal,
        experienceLevel: ExperienceLevel,
        trainingDaysPerWeek: Int,
        equipmentAccess: [Equipment],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = UUID()
        self.name = name
        self.age = age
        self.gender = gender
        self.height = height
        self.weight = weight
        self.bodyFatPercentage = bodyFatPercentage
        self.fitnessGoal = fitnessGoal
        self.experienceLevel = experienceLevel
        self.trainingDaysPerWeek = trainingDaysPerWeek
        self.equipmentAccess = equipmentAccess
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

enum Gender: String, Codable, CaseIterable {
    case male
    case female
    case other
    case preferNotToSay = "prefer not to say"
}

enum FitnessGoal: String, Codable, CaseIterable {
    case weightLoss = "weight loss"
    case muscleGain = "muscle gain"
    case maintenance
    case strength
    case endurance
    case athleticPerformance = "athletic performance"
}

enum ExperienceLevel: String, Codable, CaseIterable {
    case beginner
    case intermediate
    case advanced
}
