//
//  SetRowViewCombined.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/23/25.
//

import SwiftUI
import SwiftData

// create custom view modifier for the textfield
struct SetRowFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: 55)  // Set minimum width to 50
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial)  // Add background color
            .cornerRadius(6)  // Add corner radius
            .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                if let textField = obj.object as? UITextField {
                    textField.selectAll(nil)
                }
            }
                        
    }
}
struct SetRowViewCombined: View {
    let order: Int
    let isTemplate: Bool
    @Binding var weight: Double
    @Binding var reps: Int
    @Binding var isDone: Bool
    @Binding var type: SetType
    @FocusState private var focused: Bool
    // Add this parameter to handle moving to next row
    var moveToNextRow: (() -> Void)?
    
    // Add exerciseID parameter to access exercise details
    var exerciseID: String
    @Environment(\.modelContext) private var modelContext
    @State private var exerciseDetail: SupaSetSchemaV1.ExerciseDetail?
    
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
    
    // Query for exercise detail when view appears
    private func fetchExerciseDetail() {
        let descriptor = FetchDescriptor<SupaSetSchemaV1.ExerciseDetail>(
            predicate: #Predicate { $0.exerciseID == exerciseID }
        )
        
        do {
            let details = try modelContext.fetch(descriptor)
            exerciseDetail = details.first
        } catch {
            print("Error fetching exercise detail: \(error.localizedDescription)")
        }
    }
    
    var body: some View {
        LazyVGrid(columns: columns, alignment: .center) {
            // Set Number
            SetTypeButton(type: $type, order: order)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 30)
                .padding(.horizontal, 4)
            
            // Weight Input
            TextField("0", value: $weight, format: .number)
                .frame(maxWidth: .infinity, alignment: .leading)
                .modifier(SetRowFieldModifier())
                .focused($focused)
            
            // Reps Input
            TextField("0", value: $reps, format: .number)
                .frame(maxWidth: .infinity, alignment: .center)
                .modifier(SetRowFieldModifier())
                .focused($focused)
            
            if !isTemplate {
                // Done Checkbox
                Button(action: {
                    isDone.toggle()
                    
                    if isDone {
                        // Start rest timer if enabled
                        if let detail = exerciseDetail, detail.autoRestTimer > 0 {
                            RestTimerManager.shared.startTimer(
                                duration: detail.autoRestTimer,
                                for: exerciseID
                            )
                        }
                        
                        // Move to next row
                        if let moveToNextRow = moveToNextRow {
                            // Use a slight delay to let the animation complete
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                moveToNextRow()
                            }
                        }
                    }
                }) {
                    Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                        .resizable()
                        .contentTransition(.symbolEffect(.replace, options: .speed(1.5)))
                        .frame(width: 24, height: 24)
                        .foregroundColor(isDone ? .primaryThemeColorTwo.tint(50) : .gray)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .foregroundStyle(isDone ? Color.primaryThemeColorTwo.shade(25).bestTextColor() : Color.text)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
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
                .fill(isDone ? Color.primaryThemeColorTwo : Color.background)
                .shadow(
                    color: Color.black.opacity(0.05),
                    radius: 2,
                    x: 0,
                    y: 1
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isDone ? Color.primaryThemeColorTwo.shade(25) : Color.gray , lineWidth: 2)
        )
        .onAppear {
            fetchExerciseDetail()
        }
    }
}//#Preview {
//    @Previewable @State var weight: Double = 100
//    @Previewable @State var reps: Int = 10
//    @Previewable @State var isDone: Bool = false
//    @Previewable @State var type: SetType = .working
//    VStack{
//        VStack{
//            SetColumnNamesView(exerciseID: "Exercise", isTemplate: false)
//            SetRowViewCombined(
//                order: 0,
//                isTemplate: false,
//                weight: $weight,
//                reps: $reps,
//                isDone: $isDone,
//                type: $type, focusNextRow: () -> return
//            )
//        }
//        VStack{
//            SetColumnNamesView(exerciseID: "Exercise", isTemplate: false)
//            SetRowViewCombined(
//                order: 0,
//                isTemplate: false,
//                weight: $weight,
//                reps: $reps,
//                isDone: $isDone,
//                type: $type
//            )
//        }
//        .colorScheme(.dark)
//    }
//    .padding()
//    .modelContainer(PreviewContainer.preview.container)
//}
