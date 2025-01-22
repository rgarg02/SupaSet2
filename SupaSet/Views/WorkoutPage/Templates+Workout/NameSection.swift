//
//  WorkoutNameSection.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/21/24.
//
import SwiftUI

// MARK: - NameSection
// First, update the protocol to use AnyObject to ensure reference types
protocol Nameable: Observable, AnyObject {
    var name: String { get set }
    var notes: String {get set}
    func insertExercise(_ exerciseID: String)
}
// Make both Workout and Template conform to Nameable
extension Workout: Nameable {}
extension Template: Nameable {} // Assuming Template is your template model
// Create a generic NameSection view with @Bindable
struct NameSection<T: Nameable>: View {
    @Bindable var item: T
    @State private var isEditingName: Bool = false
    var font: Font = .title2
    
    var body: some View {
        HStack {
            if isEditingName {
                NameEditor(
                    item: item,
                    isEditingName: $isEditingName
                )
            } else {
                Text(item.name)
                    .font(font.bold())
            }
            
            EditButton(isEditing: isEditingName) {
                withAnimation {
                    isEditingName.toggle()
                }
            }
        }
    }
}

// Update NameEditor to use @Bindable
struct NameEditor<T: Nameable>: View {
    @Bindable var item: T
    @Binding var isEditingName: Bool
    @FocusState private var isFocused: Bool
    
    var body: some View {
        TextField("Name", text: $item.name)
            .font(.title2)
            .textFieldStyle(.plain)
            .focused($isFocused)
            .onAppear {
                isFocused = true
            }
            .onSubmit {
                if !item.name.isEmpty {
                    withAnimation {
                        isEditingName = false
                    }
                }
            }
            .submitLabel(.done)
    }
}

