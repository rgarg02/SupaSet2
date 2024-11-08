//
//  SwipeAction.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/7/24.
//

import SwiftUI

/// A SwiftUI view component that enables swipeable actions similar to native iOS list swipe actions.
///
/// `SwipeAction` allows you to add swipeable actions to any content view, supporting both leading
/// and trailing swipe directions with customizable actions.
///
/// Example usage:
/// ```swift
/// SwipeAction {
///     Text("Swipeable Content")
/// } actions: {
///     Action(tint: .red, icon: "trash") {
///         // Delete action
///     }
///     Action(tint: .blue, icon: "star") {
///         // Star action
///     }
/// }
/// .cornerRadius(10)
/// .direction(.trailing)
/// ```
struct SwipeAction<Content: View>: View {
    /// The corner radius applied to the swipe container.
    var cornerRadius: CGFloat = 0
    
    /// The direction in which the swipe gesture should be performed.
    var direction: SwipeDirection = .trailing
    
    /// The content view that will be swipeable.
    @ViewBuilder var content: Content
    
    /// The array of actions that will be revealed when swiping.
    @ActionBuilder var actions: [Action]
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                     content
                        .containerRelativeFrame(.horizontal)
                }
                .scrollTargetLayout()
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
        }
    }
}

/// Defines the possible directions for swipe actions.
///
/// Use this enumeration to specify whether the swipe actions should appear
/// from the leading (left) or trailing (right) edge of the content.
enum SwipeDirection {
    /// Actions appear from the leading (left) edge when swiping right.
    case leading
    
    /// Actions appear from the trailing (right) edge when swiping left.
    case trailing
    
    /// Returns the corresponding `Alignment` value for the swipe direction.
    var alignment: Alignment {
        switch self {
            case .leading: return .leading
            case .trailing: return .trailing
        }
    }
}

/// Represents a single swipe action with customizable appearance and behavior.
///
/// Use this struct to define individual actions that appear when the user swipes
/// the content view. Each action can have its own icon, color, and behavior.
///
/// Example:
/// ```swift
/// Action(tint: .red, icon: "trash", iconFont: .title2) {
///     // Handle action
/// }
/// ```
struct Action: Identifiable {
    /// A unique identifier for the action.
    private(set) var id: UUID = .init()
    
    /// The background color of the action button.
    var tint: Color
    
    /// The SF Symbol name for the action's icon.
    var icon: String
    
    /// The font size of the icon. Defaults to `.title`.
    var iconFont: Font = .title
    
    /// The color of the icon. Defaults to white.
    var iconTint: Color = .white
    
    /// Whether the action is currently enabled. Defaults to true.
    var isEnabled: Bool = true
    
    /// The closure to execute when the action is triggered.
    var action: () -> ()
}

/// A result builder for creating arrays of actions declaratively.
///
/// This result builder enables a more natural, declarative syntax for specifying
/// multiple actions within the `SwipeAction` view.
///
/// Example:
/// ```swift
/// @ActionBuilder var actions: [Action] {
///     Action(tint: .red, icon: "trash") { }
///     Action(tint: .blue, icon: "star") { }
/// }
/// ```
@resultBuilder
struct ActionBuilder {
    /// Builds an array of actions from the provided components.
    ///
    /// - Parameter components: The individual `Action` instances to combine.
    /// - Returns: An array containing all the provided actions.
    static func buildBlock(_ components: Action...) -> [Action] {
        return components
    }
}
