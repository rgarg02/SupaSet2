//
//  ExerciseDetailView.swift
//  SupaSetGRDB
//
//  Created by Rishi Garg on 4/13/25.
//

import SwiftUI


struct ExerciseDetailView: View {
    let exerciseId: String
    // You'd likely have a @StateObject ViewModel here too to fetch full details
    @State private var exercise: Exercise? // Load the full Exercise model here
    @State private var isLoading = false
    let dbManager = GRDBManager.shared
    @State private var selectedImageIndex = 0
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else if let exercise = exercise {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header with name and category
                        VStack(alignment: .leading, spacing: 8) {
                            Text(exercise.name)
                                .font(.largeTitle)
                                .bold()
                            
                            HStack {
                                if let equipment = exercise.equipment {
                                    equipment.image
                                        .font(.title2)
                                }
                                Text(exercise.category.rawValue.capitalized)
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .onAppear{
                            print(exercise.equipment?.rawValue)
                        }
                        .padding(.horizontal)
                        // Images carousel
                        if !exercise.images.isEmpty {
                            TabView(selection: $selectedImageIndex) {
                                ForEach(Array(exercise.images.enumerated()), id: \.element) { index, imageUrl in
                                    ExerciseImageView(imagePath: imageUrl)
                                        .tag(index)
                                }
                            }
                            .frame(height: 250)
                            .tabViewStyle(PageTabViewStyle())
                        }
                        
                        // Exercise details
                        VStack(alignment: .leading, spacing: 16) {
                            // Level indicator
                            HStack {
                                Text("Level:")
                                    .font(.headline)
                                Text(exercise.level.rawValue.capitalized)
                                    .foregroundColor(exercise.level.color)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(exercise.level.color.opacity(0.2))
                                    )
                            }
                            
                            // Mechanics and Force
                            if let mechanic = exercise.mechanic {
                                DetailRow(title: "Mechanic", value: mechanic.rawValue.capitalized)
                            }
                            
                            if let force = exercise.force {
                                DetailRow(title: "Force", value: force.rawValue.capitalized)
                            }
                            
                            // Muscles involved
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Primary Muscles")
                                    .font(.headline)
                                MuscleTagsView(muscles: exercise.primaryMuscles)
                                
                                if !exercise.secondaryMuscles.isEmpty {
                                    Text("Secondary Muscles")
                                        .font(.headline)
                                        .padding(.top, 8)
                                    MuscleTagsView(muscles: exercise.secondaryMuscles)
                                }
                            }
                            
                            // Instructions
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Instructions")
                                    .font(.headline)
                                
                                ForEach(Array(exercise.instructions.enumerated()), id: \.offset) { index, instruction in
                                    HStack(alignment: .top, spacing: 8) {
                                        Text("\(index + 1).")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Text(instruction)
                                            .font(.subheadline)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                        .padding()
                    }
                }
                
            } else {
                Text("Exercise not found.")
            }
        }
        .task { await loadExerciseDetails() } // Load details when the view appears
    }
    
    private func loadExerciseDetails() async {
        guard exercise == nil else { return } // Don't reload if already loaded
        isLoading = true
        do {
            exercise = try await dbManager.fetchFullExercise(id: exerciseId)
        } catch {
            print("Error loading exercise details: \(error)")
            // Handle error state in the UI
        }
        isLoading = false
    }
}
