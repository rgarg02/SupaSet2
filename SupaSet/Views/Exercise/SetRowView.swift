//
//  SetRowView.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/7/24.
//

import SwiftUI

struct SetRowView: View {
    let setNumber: Int
    @Bindable var set: ExerciseSet
    @FocusState.Binding var focused: Bool
    private let columns = [
            GridItem(.fixed(40)), // Smaller column for set number
            GridItem(.flexible()), // Flexible for weight
            GridItem(.flexible()), // Flexible for reps
            GridItem(.fixed(80))  // Smaller column for checkbox
        ]
    var body: some View {
        LazyVGrid(columns: columns, alignment: .center) {
            // Set Number
            Text("\(setNumber)")
                .font(.headline)
            
            // Weight Input
            HStack(spacing: 4) {
                TextField("0", value: $set.weight, format: .number)
                    .keyboardType(.decimalPad)
                    .focused($focused)
                    .multilineTextAlignment(.trailing)
                    .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                            // Click to select all the text.
                            if let textField = obj.object as? UITextField {
                                textField.selectAll(nil)
                            }
                        }
                    .onChange(of: focused, {
                        if focused {
                            DispatchQueue.main.async {
                                UIApplication.shared.sendAction(#selector(UIResponder.selectAll(_:)), to: nil, from: nil, for: nil)
                            }
                        }
                    })
                    .frame(maxWidth: .infinity)
                
                Text("lbs")
                    .font(.caption)
            }
            
            // Reps Input
            HStack(spacing: 4) {
                TextField("0", value: $set.reps, format: .number)
                    .keyboardType(.numberPad)
                    .focused($focused)
                    .multilineTextAlignment(.trailing)
                    .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                            // Click to select all the text.
                            if let textField = obj.object as? UITextField {
                                textField.selectAll(nil)
                            }
                        }
                    .onChange(of: focused, {
                        if focused {
                            DispatchQueue.main.async {
                                UIApplication.shared.sendAction(#selector(UIResponder.selectAll(_:)), to: nil, from: nil, for: nil)
                            }
                        }
                    })
                    .frame(maxWidth: .infinity)
                Text("reps")
                    .font(.caption)
            }
            
            // Done Checkbox
            Button(action: {
                set.isDone.toggle()
            }) {
                Image(systemName: set.isDone ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(set.isDone ? .theme.secondary : .gray)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .foregroundStyle(set.isDone ? Color.theme.textOpposite : Color.theme.text)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(set.isDone ? Color.theme.primary : Color.theme.background)
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

// Preview Container to manage FocusState
struct SetRowPreviewContainer: View {
    @FocusState private var focused: Bool
    let set: ExerciseSet
    let setNumber: Int
    
    var body: some View {
        SetRowView(
            setNumber: setNumber,
            set: set,
            focused: $focused
        )
    }
}

#Preview("Default Set") {
    VStack(spacing: 16) {
        SetRowPreviewContainer(
            set: ExerciseSet(reps: 10, weight: 20),
            setNumber: 1
        )
        
        SetRowPreviewContainer(
            set: ExerciseSet(reps: 8, weight: 25, isDone: true),
            setNumber: 2
        )
        
        SetRowPreviewContainer(
            set: ExerciseSet(reps: 12, weight: 15, isWarmupSet: true),
            setNumber: 3
        )
    }
    .padding()
}

