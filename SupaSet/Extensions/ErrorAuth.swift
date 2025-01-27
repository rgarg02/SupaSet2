//
//  ErrorAuth.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/22/25.
//
import FirebaseAuth

extension Error {
    func firebaseAuthErrorMessage() -> String {
        if let authError = self as? AuthErrorCode {
            switch authError.code {
            // Authentication Errors
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
            case .userDisabled:
                return "This user account has been disabled."
            case .tooManyRequests:
                return "Too many unsuccessful login attempts. Please try again later."
            case .operationNotAllowed:
                return "This operation is not allowed. Contact support for assistance."
            
            // Network Related Errors
            case .networkError:
                return "A network error occurred. Please check your internet connection."
            case .invalidAPIKey:
                return "An error occurred while connecting to the server. Please try again."
            
            // Session/Token Errors
            case .invalidUserToken:
                return "Your session has expired. Please sign in again."
            case .userTokenExpired:
                return "Your session has expired. Please sign in again."
            case .requiresRecentLogin:
                return "This operation is sensitive and requires recent authentication. Please log in again."
            
            // Account Linking Errors
            case .credentialAlreadyInUse:
                return "This credential is already associated with a different user account."
            case .accountExistsWithDifferentCredential:
                return "An account already exists with the same email address but different sign-in credentials."
            case .providerAlreadyLinked:
                return "This account is already linked with another provider."
            
            // Multi-Factor Authentication
            case .secondFactorRequired:
                return "Two-factor authentication is required to complete this action."
            case .secondFactorAlreadyEnrolled:
                return "Two-factor authentication is already set up for this account."
            
            // Email Verification
            case .unverifiedEmail:
                return "Please verify your email address before proceeding."
            case .invalidActionCode:
                return "The verification code is invalid or has expired."
            
            // Rate Limiting
            case .quotaExceeded:
                return "The operation has been rate-limited. Please try again later."
            
            // Captcha
            case .captchaCheckFailed:
                return "Security check failed. Please try again."
            
            // Internal Errors
            case .internalError:
                return "An internal error has occurred. Please try again."
            
            // Default case for all other errors
            default:
                return "An unexpected error occurred. Please try again or contact support if the problem persists."
            }
        } else {
            // For non-Firebase Auth errors
            return self.localizedDescription
        }
    }
}
