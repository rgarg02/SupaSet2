//
//  to.swift
//  SupaSet
//
//  Created by Rishi Garg on 4/10/25.
//
import Foundation

/// Manager class to handle "What's New" functionality
class WhatsNewManager {
    // UserDefaults key for storing the last seen build number
    private static let lastSeenBuildNumberKey = "lastSeenBuildNumber"
    
    /// Get the current app version
    static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    /// Get the current build number
    static var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
    
    /// Get the last seen build number
    static var lastSeenBuildNumber: String {
        UserDefaults.standard.string(forKey: lastSeenBuildNumberKey) ?? ""
    }
    
    /// Save the current build number as the last seen one
    static func saveCurrentBuildNumber() {
        UserDefaults.standard.set(buildNumber, forKey: lastSeenBuildNumberKey)
    }
    
    /// Check if the app has been updated since last launch
    static var hasNewUpdate: Bool {
        // If there's no last seen build number, this might be a first installation
        if lastSeenBuildNumber.isEmpty {
            return true
        }
        
        // Compare the current build number with the last seen one
        return buildNumber != lastSeenBuildNumber
    }
}
