//
//  StatsPeriod.swift
//  SupaSet
//
//  Created by Rishi Garg on 3/2/25.
//

import Foundation
/// Enum representing different time periods for stats filtering
enum StatsPeriod: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"
    case threeMonths = "3 Months"
    case year = "Year"
    case allTime = "All Time"
    
    var id: String { self.rawValue }
    
    var daysBack: Int? {
        switch self {
        case .week: return 7
        case .month: return 30
        case .threeMonths: return 90
        case .year: return 365
        case .allTime: return nil
        }
    }
}

/// Model for chart data
struct VolumeData: Identifiable {
    let id = UUID()
    let date: Date
    let totalVolume: Double
    let formattedDate: String
    
    init(date: Date, totalVolume: Double) {
        self.date = date
        self.totalVolume = totalVolume
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        self.formattedDate = formatter.string(from: date)
    }
}

struct MuscleGroupData: Identifiable {
    let id = UUID()
    let muscleGroup: String
    let totalVolume: Double
}
