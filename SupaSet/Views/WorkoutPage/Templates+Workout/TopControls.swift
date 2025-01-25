//
//  WorkoutTopControls.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/8/24.
//

import SwiftUI

struct TopControls: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @Environment(\.alertController) var alertController
    
    enum Mode {
        case workout(workout: Workout)
        case template(template: Template)
        
        var name: String {
            switch self {
            case .workout(let workout): return workout.name
            case .template(let template): return template.name
            }
        }
        
        var isWorkout: Bool {
            switch self {
            case .workout: return true
            case .template: return false
            }
        }
        var getWorkout: Workout? {
            if case .workout(let workout) = self {
                return workout
            }
            return nil
        }
        var getTemplate: Template? {
            if case .template(let template) = self {
                return template
            }
            return nil
        }
    }
    
    let mode: Mode
    
    @Binding var show: Bool
    @Binding var offset: CGFloat
    // Initializers
    init(workout: Workout, show: Binding<Bool>, offset: Binding<CGFloat>) {
        self.mode = .workout(workout: workout)
        self._show = show
        self._offset = offset
    }
    
    init(template: Template, show: Binding<Bool>, isNew: Bool) {
        self.mode = .template(template: template)
        self._show = show
        self._offset = .constant(0)
    }
    
    var body: some View {
        VStack {
            HStack {
                if !mode.isWorkout {
                    Button("Go Back") {
                        show.toggle()
                    }
                }
                Spacer()
                Text(mode.name)
                    .font(.headline)
                    .bold()
                    .transition(.opacity)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
                if !mode.isWorkout {
                    Button("Go Back") {
                        withAnimation {
                            dismiss()
                        }
                    }
                    .hidden()
                }
                
            }
            
            if case .workout(let workout) = mode {
                WorkoutTimer(workout: workout)
            }
        }
        .onTapGesture {
            if !show {
                withAnimation(.spring()) {
                    show = true
                    offset = 0
                }
            }
        }
        .padding(.horizontal)
    }
}
