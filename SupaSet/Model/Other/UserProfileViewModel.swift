//
//  UserProfileViewModel.swift
//  SupaSet
//
//  Created by Rishi Garg on 3/6/25.
//


import SwiftUI
import SwiftData

@Observable
class UserProfileViewModel {
    private var modelContext: ModelContext
    private(set) var userProfile: UserProfile?
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        Task {
            try? await loadUserProfile()
        }
    }
    
    @MainActor
    func loadUserProfile() async throws {
        var descriptor = FetchDescriptor<UserProfile>(sortBy: [SortDescriptor(\.updatedAt, order: .reverse)])
        descriptor.fetchLimit = 1
        
        let profiles = try modelContext.fetch(descriptor)
        self.userProfile = profiles.first
    }
    
    @MainActor
    func createUserProfile(
        name: String,
        age: Int,
        gender: Gender,
        height: Double,
        weight: Double,
        bodyFatPercentage: Double?,
        fitnessGoal: FitnessGoal,
        experienceLevel: ExperienceLevel,
        trainingDaysPerWeek: Int,
        equipmentAccess: [Equipment]
    ) throws {
        let profile = UserProfile(
            name: name,
            age: age,
            gender: gender,
            height: height,
            weight: weight,
            bodyFatPercentage: bodyFatPercentage,
            fitnessGoal: fitnessGoal,
            experienceLevel: experienceLevel,
            trainingDaysPerWeek: trainingDaysPerWeek,
            equipmentAccess: equipmentAccess
        )
        
        modelContext.insert(profile)
        userProfile = profile
        try modelContext.save()
    }
    
    @MainActor
    func updateUserProfile(
        name: String? = nil,
        age: Int? = nil,
        gender: Gender? = nil,
        height: Double? = nil,
        weight: Double? = nil,
        bodyFatPercentage: Double? = nil,
        fitnessGoal: FitnessGoal? = nil,
        experienceLevel: ExperienceLevel? = nil,
        trainingDaysPerWeek: Int? = nil,
        sessionDuration: Int? = nil,
        equipmentAccess: [Equipment]? = nil
    ) throws {
        if let profile = userProfile {
            // Update existing profile
            if let name = name { profile.name = name }
            if let age = age { profile.age = age }
            if let gender = gender { profile.gender = gender }
            if let height = height { profile.height = height }
            if let weight = weight { profile.weight = weight }
            if let bodyFatPercentage = bodyFatPercentage { profile.bodyFatPercentage = bodyFatPercentage }
            if let fitnessGoal = fitnessGoal { profile.fitnessGoal = fitnessGoal }
            if let experienceLevel = experienceLevel { profile.experienceLevel = experienceLevel }
            if let trainingDaysPerWeek = trainingDaysPerWeek { profile.trainingDaysPerWeek = trainingDaysPerWeek }
            if let equipmentAccess = equipmentAccess { profile.equipmentAccess = equipmentAccess }
            
            profile.updatedAt = Date()
            
            try modelContext.save()
        }
    }
    
    func hasCompletedOnboarding() -> Bool {
        return userProfile != nil
    }
}
