//
//  SetColumnNamesView.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/23/25.
//

import SwiftUI
import SwiftData
struct SetColumnNamesView: View {
    @Query var exerciseDetails: [ExerciseDetail]
    let isTemplate: Bool
    init(exerciseID: String, isTemplate: Bool) {
        // Create a predicate filter for the specific exerciseID
        _exerciseDetails = Query(filter: #Predicate<ExerciseDetail>{$0.exerciseID == exerciseID})
        self.isTemplate = isTemplate
    }
    private var columns: [GridItem] {
        if isTemplate {
            return [
                GridItem(.flexible()),    // Smaller column for set number
                GridItem(.flexible()),    // Flexible for weight
                GridItem(.flexible())     // Flexible for reps
            ]
        } else {
            return [
                GridItem(.flexible()),    // Smaller column for set number
                GridItem(.flexible()),    // Flexible for weight
                GridItem(.flexible()),     // Flexible for reps
                GridItem(.flexible())    // Smaller column for checkbox
            ]
        }
    }
    var body: some View {
        LazyVGrid(columns: columns) {
            Text("Set")
                .font(.caption)
                .foregroundColor(.theme.text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            //                    .frame(width: 20)
            
            Text(exerciseDetails.first?.unit.rawValue ?? "Lbs")
                .font(.caption)
                .foregroundColor(.theme.text)
                .frame(maxWidth: .infinity, alignment: .center)
            //                    .frame(width: 100)
            
            Text("Reps")
                .font(.caption)
                .foregroundColor(.theme.text)
                .frame(maxWidth: .infinity, alignment: isTemplate ? .center : .center)
                .padding(isTemplate ? .trailing : .horizontal)
            //                    .frame(width: 100)
            if !isTemplate{
                Text("Done")
                    .font(.caption)
                    .foregroundColor(.theme.text)
                    .frame(maxWidth: .infinity, alignment: isTemplate ? .center : .trailing)
                    .padding(.trailing)
                //                    .frame(width: 40)
            }
        }
    }
}
#Preview {
    VStack{
        SetColumnNamesView(exerciseID: "Exercise", isTemplate: true)
        SetRowViewCombined(
            order: 0,
            isTemplate: true,
            weight: .constant(999),
            reps: .constant(99),
            isDone: .constant(false), type: .constant(.warmup)
        )
    }
    .modelContainer(PreviewContainer.preview.container)
}
