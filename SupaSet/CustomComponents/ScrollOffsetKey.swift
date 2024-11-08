//
//  ScrollOffsetKey.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/8/24.
//

import SwiftUI

/// A preference key for tracking scroll offset changes.
///
/// Used internally by SwipeAction to monitor and respond to horizontal scrolling.
struct OffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
