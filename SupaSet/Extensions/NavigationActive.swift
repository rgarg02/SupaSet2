import SwiftUI

// 1. Create a custom environment key for tracking presentation state
private struct IsChildPresentingKey: EnvironmentKey {
    static let defaultValue: Binding<Bool> = .constant(false)
}

// 2. Extend EnvironmentValues to include our custom key
extension EnvironmentValues {
    var isChildPresenting: Binding<Bool> {
        get { self[IsChildPresentingKey.self] }
        set { self[IsChildPresentingKey.self] = newValue }
    }
}
