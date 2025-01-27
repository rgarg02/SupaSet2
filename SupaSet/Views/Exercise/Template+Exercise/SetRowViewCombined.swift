//
//  SetRowViewCombined.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/23/25.
//
import SwiftUI

// create custom view modifier for the textfield
struct SetRowFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
            .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                    // Click to select all the text.
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
    @FocusState private var focused: Bool
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
        LazyVGrid(columns: columns, alignment: .center) {
            // Set Number
            Text("\(order+1)")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
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
                }) {
                    Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(isDone ? .theme.secondarySecond : .gray)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            
        }
        .foregroundStyle(isDone ? Color.theme.textOpposite : Color.theme.text)
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
                .fill(isDone ? Color.theme.secondary : Color.theme.background)
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

#Preview {
    VStack{
        SetColumnNamesView(exerciseID: "Exercise", isTemplate: false)
        SetRowViewCombined(
            order: 0,
            isTemplate: false,
            weight: .constant(999),
            reps: .constant(99),
            isDone: .constant(false)
        )
    }
    .modelContainer(PreviewContainer.preview.container)
}
