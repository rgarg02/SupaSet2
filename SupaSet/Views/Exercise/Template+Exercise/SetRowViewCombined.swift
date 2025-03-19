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
    @Binding var type: SetType
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
                }) {
                    Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                        .resizable()
                        .contentTransition(.symbolEffect(.replace, options: .speed(1.5)))
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
                .stroke(isDone ? Color.theme.accent : typeColor, lineWidth: 1)
        )
    }
    
    private var typeColor: Color {
        switch type {
        case .working:
            return .blue.opacity(0.3)
        case .warmup:
            return .orange.opacity(0.3)
        case .drop:
            return .purple.opacity(0.3)
        case .failure:
            return .red.opacity(0.3)
        }
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
            isDone: .constant(false),
            type: .constant(.working)
        )
    }
    .modelContainer(PreviewContainer.preview.container)
}
