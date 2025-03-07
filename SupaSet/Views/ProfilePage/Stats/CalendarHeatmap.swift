//
//  CalendarHeatmap.swift
//  SupaSet
//
//  Created by Rishi Garg on 3/2/25.
//

import SwiftUI

struct CalendarHeatmap: View {
    let workouts: [SupaSetSchemaV1.Workout]
    let selectedPeriod: StatsPeriod
    
    @State private var selectedDate: Date? = nil
    
    // Pre-compute workout dates and counts for better performance
    private var workoutDateCounts: [Date: Int] = [:]
    
    // Add colors for binary workout status (workout vs no workout)
    private let heatColors = [
        Color(.systemGray6),  // No workout
        Color.green.opacity(0.7)  // Workout completed
    ]
    
    // Cache values to improve performance
    @State private var daysToShow: Int = 0
    @State private var startDate: Date = Date()
    @State private var monthLabels: [(offset: CGFloat, label: String, isNewYear: Bool, year: String?)] = []
    
    init(workouts: [SupaSetSchemaV1.Workout], selectedPeriod: StatsPeriod) {
        self.workouts = workouts
        self.selectedPeriod = selectedPeriod
        
        // Pre-compute workout counts by date
        var counts: [Date: Int] = [:]
        for workout in workouts {
            let dayStart = Calendar.current.startOfDay(for: workout.date)
            counts[dayStart, default: 0] += 1
        }
        self.workoutDateCounts = counts
        
        // Initialize cached values
        let days = calculateDaysToShow(for: selectedPeriod, workouts: workouts)
        _daysToShow = State(initialValue: days)
        
        let start = calculateStartDate(for: days, period: selectedPeriod, workouts: workouts)
        _startDate = State(initialValue: start)
        
        let labels = calculateMonthLabels(days: days, startDate: start)
        _monthLabels = State(initialValue: labels)
    }
    
    // Lifecycle function to update cached values when period changes
    private func updateCachedValues() {
        let newDaysToShow = calculateDaysToShow(for: selectedPeriod, workouts: workouts)
        if daysToShow != newDaysToShow {
            daysToShow = newDaysToShow
            startDate = calculateStartDate(for: daysToShow, period: selectedPeriod, workouts: workouts)
            monthLabels = calculateMonthLabels(days: daysToShow, startDate: startDate)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Workout Commitment")
                .font(.title2)
                .fontWeight(.bold)
            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    
                    Text("Each square represents a day of activity")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .onAppear {
                    updateCachedValues()
                }
                .onChange(of: selectedPeriod) { _, _ in
                    updateCachedValues()
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 4) {
                        // Grid for weekday labels + heatmap cells
                        LazyHGrid(rows: Array(repeating: GridItem(.fixed(18), spacing: 3), count: 7), spacing: 3) {
                            // First column: weekday letters
                            ForEach(0..<7, id: \.self) { index in
                                Text(dayLetter(for: index))
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .frame(width: 18, height: 18)
                            }
                            
                            // Heatmap cells
                            ForEach(0..<daysToShow, id: \.self) { index in
                                if let date = Calendar.current.date(byAdding: .day, value: index, to: startDate) {
                                    let dayStart = Calendar.current.startOfDay(for: date)
                                    let count = workoutDateCounts[dayStart] ?? 0
                                    let isToday = Calendar.current.isDateInToday(date)
                                    
                                    Rectangle()
                                        .fill(count > 0 ? heatColors[1] : heatColors[0])
                                        .frame(width: 18, height: 18)
                                        .cornerRadius(3)
                                        .overlay(
                                            ZStack {
                                                if isToday {
                                                    RoundedRectangle(cornerRadius: 3)
                                                        .stroke(Color.primary, lineWidth: 1.5)
                                                } else {
                                                    RoundedRectangle(cornerRadius: 3)
                                                        .stroke(Color.gray.opacity(0.15), lineWidth: 0.5)
                                                }
                                            }
                                        )
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            if let selected = selectedDate, Calendar.current.isDate(selected, inSameDayAs: date) {
                                                selectedDate = nil
                                            } else {
                                                selectedDate = date
                                                // Add haptic feedback
                                                let generator = UIImpactFeedbackGenerator(style: .light)
                                                generator.impactOccurred()
                                            }
                                        }
                                }
                            }
                        }
                        .padding(.vertical, 6)
                        
                        // Month labels with proper offset and new year indicator
                        GeometryReader { _ in
                            ZStack(alignment: .topLeading) {
                                ForEach(monthLabels, id: \.offset) { labelInfo in
                                    VStack(alignment: .leading, spacing: 0) {
                                        // If this date is Jan 1, display the year above the month label.
                                        if labelInfo.isNewYear, let year = labelInfo.year {
                                            Text(year)
                                                .font(.system(size: 9, weight: .bold))
                                                .foregroundColor(.secondary)
                                        }
                                        Text(labelInfo.label)
                                            .font(.system(size: 9, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                    // Add an initial offset equal to the day-label column width plus spacing
                                    .frame(width: 40, alignment: .leading)
                                    .offset(x: labelInfo.offset + 21, y: 0)
                                }
                            }
                        }
                        .frame(height: 24)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                )
                // Legend
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Rectangle()
                            .fill(heatColors[0])
                            .frame(width: 12, height: 12)
                            .cornerRadius(2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 2)
                                    .stroke(Color.gray.opacity(0.15), lineWidth: 0.5)
                            )
                        
                        Text("No workout")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Rectangle()
                            .fill(heatColors[1])
                            .frame(width: 12, height: 12)
                            .cornerRadius(2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 2)
                                    .stroke(Color.gray.opacity(0.15), lineWidth: 0.5)
                            )
                        
                        Text("Workout completed")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 4)
                // Detail view for selected date
                if let selectedDate = selectedDate {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(formattedDate(selectedDate))
                                .font(.headline)
                            
                            let count = workoutDateCounts[Calendar.current.startOfDay(for: selectedDate)] ?? 0
                            if count > 0 {
                                Text("Workout completed")
                                    .font(.subheadline)
                                    .foregroundColor(.green)
                                    
                                    // Find workouts for this date and display their names if any
                                    let dayWorkouts = workouts.filter {
                                        Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
                                    }
                                    if !dayWorkouts.isEmpty {
                                        VStack(alignment: .leading, spacing: 4) {
                                            ForEach(dayWorkouts, id: \.id) { workout in
                                                Text(workout.name)
                                                    .font(.caption)
                                                    .foregroundColor(.primary)
                                            }
                                        }
                                        .padding(.top, 2)
                                    }
                            } else {
                                Text("No workouts")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            self.selectedDate = nil
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.secondarySystemBackground))
                    )
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    // Calculate days to show based on period - only called during initialization and period changes
    private func calculateDaysToShow(for period: StatsPeriod, workouts: [SupaSetSchemaV1.Workout]) -> Int {
        switch period {
        case .week: return 7
        case .month: return 31
        case .threeMonths: return 90
        case .year: return 365
        case .allTime:
            // Find the earliest workout date and calculate days between that and today
            if let earliestDate = workouts.map({ $0.date }).min() {
                let days = Calendar.current.dateComponents([.day], from: earliestDate, to: Date()).day ?? 365
                return max(days + 1, 30) // Ensure we have at least 30 days to display
            }
            return 365
        }
    }
    
    // Calculate start date - only called during initialization and period changes
    private func calculateStartDate(for days: Int, period: StatsPeriod, workouts: [SupaSetSchemaV1.Workout]) -> Date {
        if period == .allTime, let earliestDate = workouts.map({ $0.date }).min() {
            // For allTime, start from the earliest workout date
            return Calendar.current.startOfDay(for: earliestDate)
        } else {
            // For other periods, count back from today
            return Calendar.current.date(byAdding: .day, value: -days + 1, to: Date()) ?? Date()
        }
    }
    
    private func dayLetter(for index: Int) -> String {
        let days = ["M", "T", "W", "T", "F", "S", "S"]
        return days[index]
    }
    
    // Pre-compute month labels - only called during initialization and period changes
    private func calculateMonthLabels(days: Int, startDate: Date) -> [(offset: CGFloat, label: String, isNewYear: Bool, year: String?)] {
        var results: [(CGFloat, String, Bool, String?)] = []
        var lastMonth: Int? = nil
        
        // Use a DateFormatter outside the loop for better performance
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        
        // Process in batches to improve performance
        let batchSize = 30 // Process 30 days at a time
        for batchStart in stride(from: 0, to: days, by: batchSize) {
            let batchEnd = min(batchStart + batchSize, days)
            
            for day in batchStart..<batchEnd {
                if let date = Calendar.current.date(byAdding: .day, value: day, to: startDate) {
                    let month = Calendar.current.component(.month, from: date)
                    let dayOfMonth = Calendar.current.component(.day, from: date)
                    
                    if month != lastMonth && dayOfMonth <= 7 {
                        let column = CGFloat(day / 7)
                        let label = formatter.string(from: date)
                        let isNewYear = (month == 1 && dayOfMonth == 1)
                        let yearString = isNewYear ? String(Calendar.current.component(.year, from: date)) : nil
                        results.append((offset: column * 21, label: label, isNewYear: isNewYear, year: yearString))
                        lastMonth = month
                    }
                }
            }
        }
        
        return results
    }
    
    // Remove unused helper methods
    private func colorForCount(_ count: Int) -> Color {
        return count > 0 ? heatColors[1] : heatColors[0]
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
