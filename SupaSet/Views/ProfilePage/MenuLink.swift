//
//  MenuLink.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/27/25.
//


import SwiftUI
struct MenuLink<Destination: View>: View {
    let title: String
    let icon: String
    let destination: Destination
    @Environment(\.isChildPresenting) private var isChildPresenting
    var body: some View {
        NavigationLink {
            destination
                .onAppear{
                    isChildPresenting.wrappedValue = true
                }
        } label: {
            HStack {
                Image(systemName: icon)
                    .frame(width: 24)
                    .foregroundColor(Color.theme.accent)
                
                Text(title)
                    .foregroundColor(.theme.text)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.theme.secondarySecond)
                    .shadow(radius: 2)
            )
        }
    }
}
#Preview {
    MenuLink(title: "Your Workouts", icon: "list.bullet", destination: AnyView(Text("Workouts")))
}
