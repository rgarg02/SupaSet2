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
