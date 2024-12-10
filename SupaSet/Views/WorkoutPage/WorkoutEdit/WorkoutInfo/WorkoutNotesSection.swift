//
//  WorkoutInfoView 2.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/21/24.
//

import SwiftUI
import UniformTypeIdentifiers

// MARK: - WorkoutNotesSection
struct WorkoutNotesSection: View {
    @Bindable var workout: Workout
    @State private var isEditingNotes: Bool = false
    var focused: FocusState<Bool>.Binding
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Notes", systemImage: "note.text")
                    .font(.headline)
                
                Spacer()
            }
            ZStack(alignment: .topLeading) {
                TextEditor(text: $workout.notes)
                    .focused(focused)
                    .frame(minHeight: 50, maxHeight: 150)
                    
                if !focused.wrappedValue && workout.notes.isEmpty {
                    Text("Add a note")
                        .foregroundColor(Color(uiColor: .placeholderText))
                        .padding(.top, 10)
                        .padding(.leading, 10)
                        .allowsHitTesting(false)
                }
            }
            .cornerRadius(20)
        }
        .foregroundColor(.theme.text)
    }
}

#Preview {
    let preview = PreviewContainer.preview
    WorkoutNotesSection(workout: preview.workout, focused: FocusState<Bool>().projectedValue)
        .modelContainer(preview.container)
}
