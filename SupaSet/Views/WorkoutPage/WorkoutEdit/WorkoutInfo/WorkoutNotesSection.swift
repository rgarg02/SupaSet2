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
    @FocusState var focused: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Notes", systemImage: "note.text")
                    .font(.headline)
                
                Spacer()
            }
            ZStack(alignment: .topLeading) {
                TextEditor(text: $workout.notes)
                    .frame(minHeight: 50, maxHeight: 150)
                    .focused($focused)
                if workout.notes.isEmpty {
                    Text("Add a note")
                        .foregroundColor(Color(uiColor: .placeholderText))
                        .padding(.top, 10)
                        .padding(.leading, 10)
                        .allowsHitTesting(false)
                }
            }
            .cornerRadius(20)
        }
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
        .foregroundColor(.theme.text)
    }
}

#Preview {
    let preview = PreviewContainer.preview
    WorkoutNotesSection(workout: preview.workout)
        .modelContainer(preview.container)
}
