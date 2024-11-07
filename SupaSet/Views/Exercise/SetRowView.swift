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
                    .foregroundColor(set.isDone ? .accentColor : .gray)
            }
            .frame(width: 50)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(set.isWarmupSet ? Color.yellow.opacity(0.1) : Color.theme.background)
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

// Preview
//struct SetCardView_Previews: PreviewProvider {
//    @FocusState var focused : Bool
//    static var previews: some View {
//        let set = ExerciseSet(reps: 10, weight: 10)
//        VStack(spacing: 8) {
//            // Multiple sets for preview
//            SetRowView(setNumber: 1, set: set, focused: .constant(focused))
//        }
//        .padding()
//        .previewLayout(.sizeThatFits)
//        
//    }
//}
