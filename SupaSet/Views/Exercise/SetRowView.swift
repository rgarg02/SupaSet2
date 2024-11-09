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
    var body: some View {
        HStack(spacing: 16) {
            // Set Number
            Text("\(setNumber)")
                .font(.headline)
                .foregroundColor(.theme.text)
                .frame(width: 30)
            
            // Weight Input
            HStack(spacing: 4) {
                TextField("0", value: $set.weight, format: .number)
                    .keyboardType(.decimalPad)
                    .focused($focused)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 50)
                    .onChange(of: focused, {
                        if focused {
                            DispatchQueue.main.async {
                                UIApplication.shared.sendAction(#selector(UIResponder.selectAll(_:)), to: nil, from: nil, for: nil)
                            }
                        }
                    })
                
                Text("kg")
                    .font(.caption)
                    .foregroundColor(.theme.text)
            }
            .frame(width: 80)
            
            // Reps Input
            HStack(spacing: 4) {
                TextField("0", value: $set.reps, format: .number)
                    .keyboardType(.numberPad)
                    .focused($focused)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 50)
                    .onChange(of: focused, {
                        if focused {
                            DispatchQueue.main.async {
                                UIApplication.shared.sendAction(#selector(UIResponder.selectAll(_:)), to: nil, from: nil, for: nil)
                            }
                        }
                    })
                Text("reps")
                    .font(.caption)
                    .foregroundColor(.theme.text)
            }
            .frame(width: 80)
            
            Spacer()
            
            // Done Checkbox
            Button(action: {
                set.isDone.toggle()
            }) {
                Image(systemName: set.isDone ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(set.isDone ? .theme.text : .gray)
            }
            .frame(width: 50)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(set.isDone ? Color.theme.accent : Color.theme.background)
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

