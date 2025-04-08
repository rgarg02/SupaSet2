//
//  ProfileSignOutButton.swift
//  SupaSet
//
//  Created by Rishi Garg on 4/2/25.
//


import SwiftUI

// Assuming AlertButton and AlertController are defined/available
// If not, you might need to adjust how the alert is presented
// For simplicity, this example uses a direct .alert modifier.
// Adapt if using a custom alertController environment object.

struct ProfileSignOutButton: View {
    // If using your custom AlertController Environment Object:
    // @Environment(\.alertController) private var alertController

    // Using standard SwiftUI alert for this example:
    @State private var showSignOutConfirm = false

    let signOutAction: () -> Void // Action provided by the parent

    var body: some View {
        Button {
            // If using custom controller:
            // let buttons = [
            //     AlertButton(title: "Sign Out", role: .destructive, action: signOutAction),
            //     AlertButton(.cancel)
            // ]
            // alertController.present(.alert, title: "Sign Out?", message: "Are you sure?", buttons: buttons)

            // Using standard alert:
            showSignOutConfirm = true

        } label: {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("Sign Out")
            }
            .foregroundColor(.red) // Use standard red
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.red.opacity(0.5), lineWidth: 1) // Use standard red
            )
        }
        .padding(.top)
        // Standard SwiftUI alert modifier
        .alert("Sign Out?", isPresented: $showSignOutConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                signOutAction() // Call the passed-in action
            }
        } message: {
            Text("Are you sure you want to sign out? All local data will be cleared.") // Added data clearing info
        }
    }
}

// Preview for the Sign Out Button
#Preview {
    ProfileSignOutButton(signOutAction: { print("Sign Out Tapped") })
        .padding()
        .background(Color.gray.opacity(0.1))
}
