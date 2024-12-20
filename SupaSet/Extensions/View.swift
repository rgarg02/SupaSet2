//
//  View.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/7/24.
//

import SwiftUI
import UIKit

extension View {
    func dismissKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                         to: nil,
                                         from: nil,
                                         for: nil)
        }
    }
}
extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
struct KeyboardDismissModifier: ViewModifier {
    @FocusState private var focusedField: Bool
    
    func body(content: Content) -> some View {
        content
            .focused($focusedField)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focusedField = false
                    }
                }
            }
    }
}

// Extension to make it easier to use
extension View {
    func dismissibleKeyboard() -> some View {
        modifier(KeyboardDismissModifier())
    }
}
