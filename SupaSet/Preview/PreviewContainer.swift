//
//  PreviewContainer.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/7/24.
//
import SwiftData
/// Creates a ModelContainer for preview purposes.
let previewContainer: ModelContainer = {
    let container = try! ModelContainer(for: Workout.self)
    return container
}()
