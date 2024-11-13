//
//  SwipeAction.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/7/24.
//

//
//  SwipeAction.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/7/24.
//

import SwiftUI

/// A SwiftUI view component that enables swipeable actions similar to native iOS list swipe actions.
/// Code adapted from Kavsoft's Youtube Video: https://www.youtube.com/watch?v=K8VnH2eEnK4&t=492s
///
/// `SwipeAction` provides a customizable swipe-to-action interface with smooth animations and interactive feedback.
/// The component supports both leading and trailing swipe directions with multiple action buttons.
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
    
    /// A unique identifier for the content view to enable programmatic scrolling.
    let viewID = "CONTENTVIEW"
    
    /// Controls whether the swipe actions are currently interactive.
    @State var isEnabled: Bool = true
    
    /// Tracks the current scroll offset for animation purposes.
    @State private var scrollOffset: CGFloat = .zero
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    content
                        .rotationEffect(.init(degrees: direction == .leading ? -180 : 0))
                        .containerRelativeFrame(.horizontal)
                        .background{
                            if let firstAction = actions.first {
                                Rectangle()
                                    .fill(firstAction.tint)
                                    .opacity(scrollOffset == .zero ? 0 : 1)
                            }
                        }
                        .id(viewID)
                        .transition(.identity)
                        .overlay{
                            GeometryReader {
                                let minX = $0.frame(in: .scrollView(axis: .horizontal)).minX
                                Color.clear
                                    .preference(key: OffsetKey.self, value: minX)
                                    .onPreferenceChange(OffsetKey.self) {
                                        scrollOffset = $0
                                    }
                            }
                        }
                    ActionButtons {
                        withAnimation(.snappy) {
                            proxy.scrollTo(viewID, anchor: direction == .trailing ? .topLeading : .topTrailing)
                        }
                    }
                    .opacity(scrollOffset == .zero ? 0 : 1)
                }
                .scrollTargetLayout()
                .visualEffect { content, geometryProxy in
                    /// Calculates the scroll offset for the visual effect.
                    content
                        .offset(x: {
                            let minX = geometryProxy.frame(in: .scrollView(axis: .horizontal)).minX
                            return (minX > 0 ? -minX : 0)
                        }())
                }
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .background{
                if let lastAction = actions.last {
                    Rectangle()
                        .fill(lastAction.tint)
                        .opacity(scrollOffset == .zero ? 0 : 1)
                }
            }
            .clipShape(.rect(cornerRadius: cornerRadius))
            .rotationEffect(.init(degrees: direction == .leading ? 180 : 0))
        }
        .allowsHitTesting(isEnabled)
        .transition(CustomTransition())
    }
    
    /// Creates the action buttons view with reset functionality.
    /// - Parameter resetPosition: A closure that resets the swipe position.
    /// - Returns: A view containing the action buttons.
    @ViewBuilder
    func ActionButtons(resetPosition: @escaping() -> ()) -> some View {
        /// Each Button has a width of 100
        Rectangle()
            .fill(.clear)
            .frame(width: CGFloat(actions.count)*100)
            .overlay(alignment: direction.alignment) {
                HStack(spacing: 0){
                    ForEach(actions) {button in
                        Button(action:{
                            Task {
                                isEnabled = false
                                resetPosition()
                                button.action()
                                try? await Task.sleep(for: .seconds(0.1))
                                isEnabled = true
                            }
                        }, label: {
                            Image(systemName: button.icon)
                                .font(button.iconFont)
                                .foregroundStyle(button.iconTint)
                                .frame(width: 100)
                                .frame(maxWidth: .infinity)
                                .contentShape(.rect)
                        })
                        .buttonStyle(.plain)
                        .background(button.tint)
                        .rotationEffect(.init(degrees: direction == .leading ? -180 : 0))
                    }
                }
            }
    }
}

/// A custom transition for smooth appearance and disappearance animations.
///
/// Provides a sliding mask transition effect for the swipe action view.
struct CustomTransition: Transition {
    /// Applies the transition effect to the content.
    /// - Parameters:
    ///   - content: The view content to transition.
    ///   - phase: The current phase of the transition.
    /// - Returns: The modified view with the transition effect applied.
    func body(content: Content, phase: TransitionPhase) -> some View {
        content
            .mask {
                GeometryReader { proxy in
                    let size = proxy.size
                    Rectangle()
                        .offset(y: phase == .identity ? 0 : -size.height)
                }
                .containerRelativeFrame(.horizontal)
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
/// the content view. Each action is displayed as a button with an icon and custom styling.
///
/// Example:
/// ```swift
/// Action(tint: .red, icon: "trash", iconFont: .title2) {
///     // Handle deletion
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
///     Action(tint: .red, icon: "trash") {
///         print("Delete tapped")
///     }
///     Action(tint: .blue, icon: "star") {
///         print("Favorite tapped")
///     }
/// }
/// ```
@resultBuilder
struct ActionBuilder {
    /// Builds an array of actions from the provided components.
    /// - Parameter components: The individual `Action` instances to combine.
    /// - Returns: An array containing all the provided actions.
    static func buildBlock(_ components: Action...) -> [Action] {
        return components
    }
}
