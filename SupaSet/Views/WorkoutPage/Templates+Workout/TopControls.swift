//
//  WorkoutTopControls.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/8/24.
//

import SwiftUI

struct TopControls: View {
    @Environment(\.dismiss) var dismiss

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
    }
    
    let mode: Mode
    @Environment(\.modelContext) var modelContext
    @Binding var show: Bool
    @Binding var offset: CGFloat
    let isNew: Bool
    private let maxOffsetHide: CGFloat = 100
    
    // Initializers
    init(workout: Workout, show: Binding<Bool>, offset: Binding<CGFloat>) {
        self.mode = .workout(workout: workout)
        self._show = show
        self._offset = offset
        self.isNew = true
    }
    
    init(template: Template, isNew: Bool) {
        self.mode = .template(template: template)
        self._show = .constant(true)
        self._offset = .constant(0)
        self.isNew = isNew
    }
    
    var body: some View {
        VStack {
            HStack {
                if show {
                    Button(isNew ? "Cancel" : "Back") {
                        cancel()
                    }
                    .foregroundStyle(.red)
                    .background(.clear)
                    .buttonBorderShape(.capsule)
                    .font(.headline)
                    .opacity(max(0, CGFloat(1 - offset / maxOffsetHide)))
                }
                
                Spacer()
                
                Text(mode.name)
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.theme.text)
                    .transition(.opacity)
                
                Spacer()
                
                if show {
                    Button(isNew ? "Finish" : "Save") {
                        finish()
                    }
                    .foregroundStyle(Color.theme.secondary)
                    .background(.clear)
                    .buttonBorderShape(.capsule)
                    .font(.headline)
                    .opacity(max(0, CGFloat(1 - offset / maxOffsetHide)))
                }
            }
            .allowsHitTesting(show)
            
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
    
    private func finish() {
        if case .workout(let workout) = mode {
            workout.isFinished = true
            workout.endTime = Date()
            do {
                try modelContext.save()
                withAnimation {
                    show = false
                }
                WorkoutActivityManager.shared.endAllActivities()
            } catch {
                print("Error saving workout: \(error)")
            }
        } else if case .template(let template) = mode {
            if isNew{
                template.createdAt = Date()
                do {
                    modelContext.insert(template)
                    try modelContext.save()
                    withAnimation {
                        dismiss()
                    }
                } catch {
                    print("Error saving workout: \(error)")
                }
            } else {
                do {
                    try modelContext.save()
                    withAnimation {
                        dismiss()
                    }
                } catch {
                    print("Error saving template: \(error)")
                }
            }
        }
    }
    
    private func cancel() {
        switch mode {
        case .workout(let workout):
            if isNew {
                modelContext.delete(workout)
                WorkoutActivityManager.shared.endAllActivities()
            }
        case .template:
            dismiss()
        }
        withAnimation {
            show = false
        }
    }
}

// Preview
#Preview {
    let previewContainer = PreviewContainer.preview
    
    Group {
        // Workout preview
        TopControls(
            workout: previewContainer.workout,
            show: .constant(true),
            offset: .constant(0)
        )
        
        // Template preview
        TopControls(
            template: Template(name: "Template", order: 0),
            isNew: true
        )
    }
    .modelContainer(previewContainer.container)
    .environment(previewContainer.viewModel)
}
