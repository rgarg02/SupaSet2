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
    var font: Font = .title
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(alignment: .center) {
            NameEditor()
        }
        .frame(maxWidth: .infinity)
    }
    @ViewBuilder
    func NameEditor() -> some View{
        TextField("New Workout", text: $item.name)
            .multilineTextAlignment(.center)
            .font(font.bold())
            .textFieldStyle(.plain)
            .focused($isFocused)
            .submitLabel(.done)
    }
}

