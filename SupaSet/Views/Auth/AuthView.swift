//
//  AuthView.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/12/25.
//

import SwiftUI

struct AuthView: View {
    var body: some View {
        NavigationStack{
            VStack{
                SignInOptionsView()
            }
            .navigationTitle("Sign In")
        }
    }
}

#Preview {
    NavigationStack {
        AuthView()
    }
}
