//
//  TemplateExerciseSetRow.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/22/25.
//

import SwiftUI
import SwiftData
struct TemplateExerciseSetRow: View {
    @Bindable var set: TemplateExerciseSet
    @FocusState var focused: Bool
    let columns = [
        GridItem(.fixed(40)), // Smaller column for set number
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    @Query var exerciseDetails: [ExerciseDetail]
    init(set: TemplateExerciseSet, exerciseID: String) {
        self._set = Bindable(set)
        _exerciseDetails = Query(filter: #Predicate { $0.exerciseID == exerciseID })
    }
    var body: some View {
        LazyVGrid(columns: columns, alignment: .center) {
            // Set Number
            Text("\(set.order+1)")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Weight Input
            HStack(spacing: 4) {
                TextField("0", value: $set.weight, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .focused($focused)
                    .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                            // Click to select all the text.
                            if let textField = obj.object as? UITextField {
                                textField.selectAll(nil)
                            }
                        }
                
                Text(exerciseDetails.first?.unit.rawValue ?? "lbs")
                    .font(.caption)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            
            // Reps Input
            HStack(spacing: 4) {
                TextField("0", value: $set.reps, format: .number)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .focused($focused)
                    .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                            // Click to select all the text.
                            if let textField = obj.object as? UITextField {
                                textField.selectAll(nil)
                            }
                        }
                Text("reps")
                    .font(.caption)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .toolbar {
            if focused{
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focused = false
                    }
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.theme.background)
                .shadow(
                    color: Color.black.opacity(0.05),
                    radius: 2,
                    x: 0,
                    y: 1
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.theme.accent, lineWidth: 1)
        )
    }
}
