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
    let moving: Bool
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
                    .disabled(moving)
                    
                if !focused.wrappedValue && workout.notes.isEmpty {
                    Text("Add a note")
                        .foregroundColor(Color(uiColor: .placeholderText))
                        .padding(.top, 10)
                        .padding(.leading, 10)
                        .allowsHitTesting(false)
                }
            }
            .overlay{
                Color.clear
                    .onDrop(of: [UTType.exerciseTransfer], isTargeted: nil) { _, _ in
                                return false // Always reject drops
                            }
            }
            .cornerRadius(20)
        }
        .background(Color.theme.background)
        .foregroundColor(.theme.text)
    }
}

#Preview {
    let preview = PreviewContainer.preview
    WorkoutNotesSection(workout: preview.workout, moving: true, focused: FocusState<Bool>().projectedValue)
        .modelContainer(preview.container)
}
