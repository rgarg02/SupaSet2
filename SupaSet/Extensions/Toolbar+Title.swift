//
//  Toolbar+Title.swift
//  SupaSet
//
//  Created by Rishi Garg on 3/19/25.
//

import SwiftUI

// Custom toolbar title view extension
struct CustomNavBarTitle: View {
    let title: String
    var body: some View {
        
        HStack(alignment: .center){
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(
                    LinearGradient(colors: [Color.primaryTheme, Color.accent], startPoint: .leading, endPoint: .trailing)
                )
        }
        .background(Color.background)
        .frame(maxWidth: .infinity)
    }
}
