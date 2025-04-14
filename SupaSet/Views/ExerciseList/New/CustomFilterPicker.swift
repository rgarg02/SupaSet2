import SwiftUI

// T? becomes Hashable automatically if T is Hashable
struct CustomFilterPicker<T: RawRepresentable & CaseIterable & Hashable>: View where T.RawValue == String {
    let title: String
    @Binding var selection: T? // Binding to the optional selection
    let options: [T?]         // Accept an array of optionals (includes nil for "All")
    var backgroundColor: Color = Color(.systemGray6) // Default background
    var selectedTextColor: Color = .primary         // Default text color for selected items

    // Helper to get only the non-nil options for iteration
    private var nonNilOptions: [T] {
        options.compactMap { $0 }
    }

    // Determine background color based on selection (handles nil for "All")
    private func getBackgroundColor(for option: T?) -> Color {
        guard let concreteOption = option else {
             // Background for the "All" state label (when selection is nil)
             return Color.gray.opacity(0.15) // Example: slightly different gray
        }
        // Special background for selected Level
        if let level = concreteOption as? Level {
            return level.color.opacity(0.2)
        }
         // Default background for other selected items
        return backgroundColor // Use the default (e.g., systemGray6) or a custom one
    }

    // Determine text color based on selection (handles nil for "All")
    private func getTextColor(for option: T?) -> Color {
        guard let concreteOption = option else {
             // Text color for the "All" state label
             return .secondary // Example: gray color for "All" label text
        }
        // Special text color for selected Level
        if let level = concreteOption as? Level {
            return level.color
        }
         // Default text color for other selected items
        return selectedTextColor // Use .primary or a custom color
    }

     // Sort the actual enum cases (non-nil) for the menu options
    private var sortedOptions: [T] {
        let actualOptions = nonNilOptions
         // Keep predefined order for Level if necessary, otherwise sort alphabetically
         // This assumes Level's CaseIterable order is desired. Adjust if needed.
        if let _ = actualOptions.first as? Level {
            return actualOptions // Use the order from CaseIterable via nonNilOptions
        }
         // Default alphabetical sorting for other types based on rawValue
        return actualOptions.sorted(by: { $0.rawValue < $1.rawValue })
    }

    // Helper to get the display name (handles MuscleGroup description)
    private func displayName(for option: T) -> String {
        if let muscle = option as? MuscleGroup {
            return muscle.description // Use MuscleGroup's description property
        }
        return option.rawValue.capitalized // Default to capitalized rawValue
    }

    var body: some View {
        Menu {
            // --- Menu Items ---
            // 1. Explicit "All" button
            Button {
                selection = nil // Action: set binding to nil
            } label: {
                HStack {
                    Text("All \(title)")
                    // Show checkmark if selection is currently nil
                    if selection == nil {
                        Image(systemName: "checkmark")
                    }
                }
            }

            // 2. Buttons for each actual option (sorted)
            ForEach(sortedOptions, id: \.self) { option in
                Button {
                    selection = option // Action: set binding to the selected option
                } label: {
                    HStack {
                         Text(displayName(for: option)) // Use helper for display name
                        // Show checkmark if this option is the current selection
                        if selection == option {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            // --- Picker Label ---
            HStack {
                // Display name of selected option, or "All" if nil
                 let labelText = selection.map { displayName(for: $0) } ?? "All \(title)"

                Text(labelText)
                     .lineLimit(1) // Prevent wrapping
                    .font(.caption) // Smaller font for compact look
                    .foregroundStyle(getTextColor(for: selection)) // Dynamic text color

                Image(systemName: "chevron.down")
                    .imageScale(.small)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 10) // Adjusted padding
            .padding(.vertical, 5)   // Adjusted padding
            .background(getBackgroundColor(for: selection)) // Dynamic background
            .cornerRadius(15) // Adjusted corner radius
        }
    }
}

// MARK: - Preview (Requires sample enums)

// Define sample enums locally for the preview if they aren't globally accessible
#if DEBUG
enum PreviewLevel: String, CaseIterable, Hashable {
    case beginner, intermediate, expert
    var color: Color {
        switch self {
        case .beginner: .green
        case .intermediate: .orange
        case .expert: .red
        }
    }
}

enum PreviewMuscleGroup: String, CaseIterable, Hashable {
    case chest = "Chest" // Use descriptive raw values if needed elsewhere
    case back = "Back"
    case legs = "Legs"
    var description: String { self.rawValue } // Simple description for preview
}

struct CustomFilterPicker_Previews: PreviewProvider {
    // Provide sample options including nil
    static let sampleLevels: [PreviewLevel?] = [nil] + PreviewLevel.allCases
    static let sampleMuscles: [PreviewMuscleGroup?] = [nil] + PreviewMuscleGroup.allCases

    // State variables for the preview
    @State static var selectedLvl: PreviewLevel? = .intermediate
    @State static var selectedMus: PreviewMuscleGroup? = nil

    static var previews: some View {
        HStack {
             VStack {
                 Text("Level:")
                 CustomFilterPicker<PreviewLevel>(
                     title: "Level",
                     selection: $selectedLvl,
                     options: sampleLevels
                 )
             }
             VStack {
                 Text("Muscle:")
                 CustomFilterPicker<PreviewMuscleGroup>(
                     title: "Muscle",
                     selection: $selectedMus,
                     options: sampleMuscles
                 )
             }
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
