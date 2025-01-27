//
//  PageTitle.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/26/25.
//

import SwiftUI

struct PageTitle: View {
    var title: String
    var body: some View {
        Text(title)
            .font(.largeTitle)
            .fontWeight(.bold)
            .padding()
    }
}
