//
//  WorkoutInfoView.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/8/24.
//

import SwiftUI

struct WorkoutInfoView: View {
    @Bindable var workout: Workout
    @State private var isEditingName: Bool = false
    @State private var elapsedTime: TimeInterval = 0
    @FocusState private var isFocused: Bool

    private var formattedDate: String {
        Date().formatted(date: .abbreviated, time: .shortened)
    }
        
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                if isEditingName {
                    TextField("Workout Name", text: $workout.name)
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                        .focused($isFocused)
                        .onAppear{
                            isFocused = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                UIApplication.shared.sendAction(#selector(UIResponder.selectAll(_:)), to: nil, from: nil, for: nil)
                            }
                        }
                        .onSubmit {
                            withAnimation {
                                isEditingName = false
                            }
                        }
                } else {
                    Text(workout.name)
                        .font(.title2.bold())
                }
                
                Button(action: {
                    withAnimation {
                        isEditingName.toggle()
                    }
                }) {
                    Image(systemName: isEditingName ? "checkmark.circle.fill" : "pencil.circle")
                }
            }
            .padding(.horizontal)
            HStack {
                Label(formattedDate, systemImage: "calendar")
                Spacer()
                Image(systemName: "clock")
                    .foregroundStyle(Color.theme.accent)
                Text("00:00:00")
                    .hidden()
                    .overlay(alignment: .leading){
                        Text(workout.date, style: .timer)
                            .foregroundStyle(Color.theme.accent)
                    }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    let sampleWorkout = Workout(name: "Morning Workout")
    return WorkoutInfoView(workout: sampleWorkout)
        .padding()
}
