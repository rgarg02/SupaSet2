//
//  ErrorAuth.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/22/25.
//
import FirebaseAuth

// Define an extension on the Error type
extension Error {
    // Function to handle Firebase authentication errors
    func firebaseAuthErrorMessage() -> String {
        // Check if the error can be cast to AuthErrorCode
        if let authError = self as? AuthErrorCode {
            // Switch on the error code to provide specific error messages
            switch authError.code {
            case .invalidEmail:
                return "The email address is invalid."
            case .emailAlreadyInUse:
                return "The email address is already in use by another account."
            case .weakPassword:
                return "The password must be 6 characters long or more."
            case .wrongPassword:
                return "The password is invalid or the user does not have a password."
            case .userNotFound:
                return "There is no user record corresponding to this identifier. The user may have been deleted."
            default:
                return self.localizedDescription
            }
        } else {
            // If the error is not a Firebase Auth error, return the localized description
            return self.localizedDescription
        }
    }
}
