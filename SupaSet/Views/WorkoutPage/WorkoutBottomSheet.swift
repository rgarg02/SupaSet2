//
//  WorkoutBottomSheet.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/4/25.
//

import SwiftUI

struct WorkoutBottomSheet: View{
    var body: some View {
        ZStack{
            Rectangle()
                .fill(Color.theme.primary)
        }
        .frame(height: 70)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.theme.accent)
                .frame(height: 1)
                .offset(y: -10)
                
        }
        .offset(y: -49)
    }
}
