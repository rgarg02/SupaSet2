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
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private var formattedDate: String {
        Date().formatted(date: .abbreviated, time: .shortened)
    }
    
    private var formattedElapsedTime: String {
        let hours = Int(elapsedTime) / 3600
        let minutes = Int(elapsedTime) / 60 % 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
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
                Label(formattedElapsedTime, systemImage: "timer")
                    .foregroundColor(.theme.accent)
            }
            .padding(.horizontal)
        }
        .onReceive(timer) { _ in
            elapsedTime = Date().timeIntervalSince(workout.date)
        }
    }
}

#Preview {
    let sampleWorkout = Workout(name: "Morning Workout")
    return WorkoutInfoView(workout: sampleWorkout)
        .padding()
}
