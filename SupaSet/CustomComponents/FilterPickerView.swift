//
//  FilterPickerView.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/6/24.
//
import SwiftUI
struct CustomFilterPicker<T: RawRepresentable & CaseIterable & Hashable>: View where T.RawValue == String {
    let title: String
    let selection: Binding<T?>
    let options: [T]
    var backgroundColor: Color = Color(.systemGray6)
    var selectedTextColor: Color = .primary
    private func getBackgroundColor(for option: T?) -> Color {
        guard let option = option else { return Color(.systemGray6) }
        if let level = option as? Level {
            return level.color.opacity(0.2)
        }
        return backgroundColor
    }
    
    private func getTextColor(for option: T?) -> Color {
        guard let option = option else { return .secondary }
        if let level = option as? Level {
            return level.color
        }
        return selectedTextColor
    }
    private var sortedOptions: [T] {
        // Special handling for Level enum
        if let firstOption = options.first as? Level {
            return options // Keep original order for levels
        }
        // Default alphabetical sorting for other types
        return options.sorted(by: { $0.rawValue < $1.rawValue })
    }
    var body: some View {
        Menu {
            Button {
                selection.wrappedValue = nil
            } label: {
                HStack {
                    Text("All \(title)s")
                    if selection.wrappedValue == nil {
                        Image(systemName: "checkmark")
                    }
                }
            }
            
            ForEach(sortedOptions, id: \.self) { option in
                Button {
                    selection.wrappedValue = option
                } label: {
                    HStack {
                        Text(option.rawValue.capitalized)
                        if selection.wrappedValue == option {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack {
                Text(selection.wrappedValue?.rawValue.capitalized ?? "All \(title)s")
                    .foregroundStyle(getTextColor(for: selection.wrappedValue))
                Image(systemName: "chevron.down")
                    .imageScale(.small)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(getBackgroundColor(for: selection.wrappedValue))
            .cornerRadius(20)
        }
    }
}
