//
//  Toolbar+Title.swift
//  SupaSet
//
//  Created by Rishi Garg on 3/19/25.
//

import SwiftUI

// Custom toolbar title view extension
extension View {
    func customNavBarTitle(_ title: String) -> some View {
        toolbar {
            ToolbarItem(placement: .principal) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(colors: [Color.primaryTheme, Color.primarySecond], startPoint: .leading, endPoint: .trailing)
                    )
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
