import SwiftUI
import Charts
// MARK: - Volume Chart Subview

struct VolumeChartSection: View {
    let dataPoints: [VolumeData]
    let dateDomain: ClosedRange<Date>
    let selectedPeriod: StatsPeriod
    @State private var rawSelectedDate: Date?
    
    // Animation state variables
    @State private var animateChart = false
    @State private var animateLine = false
    @State private var animateArea = false
    @State private var animatePoints = false
    @State private var animateScale = false
    
    var selectedDate: Date? {
        guard let rawSelectedDate = rawSelectedDate, !dataPoints.isEmpty else {
            return nil
        }
        
        // First, find all dates that match the desired granularity
        let calendar = Calendar.current
        let matchingDates = dataPoints.filter { dataPoint in
            switch selectedPeriod {
            case .week, .month:
                return calendar.isDate(rawSelectedDate, equalTo: dataPoint.date, toGranularity: .day)
            case .threeMonths:
                return calendar.isDate(rawSelectedDate, equalTo: dataPoint.date, toGranularity: .weekOfYear)
            case .year, .allTime:
                return calendar.isDate(rawSelectedDate, equalTo: dataPoint.date, toGranularity: .month)
            }
        }
        
        // If we found matching dates, use the first one
        if let firstMatch = matchingDates.first {
            return firstMatch.date
        }
        
        // If no match at the desired granularity, find the closest date in our dataset
        return dataPoints.min(by: { abs($0.date.timeIntervalSince(rawSelectedDate)) < abs($1.date.timeIntervalSince(rawSelectedDate)) })?.date
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Volume Progress")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                
                // Show selected date info if available
                if let date = selectedDate, let dataPoint = dataPoints.first(where: { $0.date == date }) {
                    VStack(alignment: .trailing) {
                        Text(formatDate(date))
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("\(Int(dataPoint.totalVolume)) kg")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            if dataPoints.isEmpty {
                Text("No workout data for this period")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 200)
            } else {
                Chart {
                    ForEach(dataPoints) { data in
                        LineMark(
                            x: .value("Date", data.date),
                            y: .value("Volume", animateLine ? data.totalVolume : 0)
                        )
                        .opacity(rawSelectedDate == nil || data.date == selectedDate ? 1.0 : 0.4)
                        .foregroundStyle(.blue.gradient)
                        .interpolationMethod(.catmullRom)
                        
                        AreaMark(
                            x: .value("Date", data.date),
                            y: .value("Volume", animateArea ? data.totalVolume: 0)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.clear]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .opacity(rawSelectedDate == nil || data.date == selectedDate ? 1.0 : 0.4)
                        .interpolationMethod(.catmullRom)
                        
                        PointMark(
                            x: .value("Date", data.date),
                            y: .value("Volume", data.totalVolume)
                        )
                        .opacity((rawSelectedDate == nil || data.date == selectedDate) && animatePoints ? 1.0 : 0.0)
                        .foregroundStyle(.blue)
                        .symbolSize(animatePoints ? 100 : 0)
                        
                        // Add ruler mark for selected date
                        if let selected = selectedDate, data.date == selected {
                            RuleMark(
                                x: .value("Selected Date", selected)
                            )
                            .foregroundStyle(.gray.opacity(0.3))
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                        }
                    }
                }
                .frame(height: 200)
                .chartXScale(domain: dateDomain)
                .chartYAxis { AxisMarks {
                    AxisValueLabel()
                    AxisGridLine()
                }
                }
                .chartXAxis {
                    AxisMarks(preset: .aligned) {
                        AxisValueLabel(format: dateAxisFormat)
                        AxisGridLine()
                    }
                }
                .chartXSelection(value: $rawSelectedDate)
                .sensoryFeedback(.impact, trigger: selectedDate)
                .animation(.easeInOut, value: dataPoints)
                .scaleEffect(animateScale ? 1 : 0.8)
                .opacity(animateChart ? 1 : 0)
                .rotation3DEffect(
                    .degrees(animateScale ? 0 : -10),
                    axis: (x: 1, y: 0, z: 0),
                    anchor: .center
                )
                .accessibilityLabel("Volume Progress Chart")
                .onChange(of: selectedPeriod) { _, _ in
                    resetAnimation()
                    startAnimation()
                }
                .onAppear {
                    startAnimation()
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    private func resetAnimation() {
        animateChart = false
        animateLine = false
        animateArea = false
        animatePoints = false
        animateScale = false
    }
    
    private func startAnimation() {
        // Sequence the animations with delays
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            animateChart = true
        }
        
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            animateScale = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 1.2, dampingFraction: 0.7)) {
                animateLine = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
                animateArea = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                animatePoints = true
            }
        }
    }
    
    // Date axis format that varies based on selected period
    private var dateAxisFormat: Date.FormatStyle {
        switch selectedPeriod {
        case .week:
            return .dateTime.weekday(.abbreviated)
        case .month, .threeMonths:
            return .dateTime.day().month(.abbreviated)
        case .year, .allTime:
            return .dateTime.month(.abbreviated)
        }
    }
    
    // Format the selected date with appropriate granularity
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        
        switch selectedPeriod {
        case .week:
            formatter.dateFormat = "E, d MMM"
        case .month, .threeMonths:
            formatter.dateFormat = "d MMM"
        case .year, .allTime:
            formatter.dateFormat = "MMM yyyy"
        }
        
        return formatter.string(from: date)
    }
    
    private func getXAxisMarksCount() -> Int {
        switch selectedPeriod {
        case .week:
            return 7
        case .month, .threeMonths, .year, .allTime:
            return 6
        }
    }
    
    private func getMinimalDateLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        switch selectedPeriod {
        case .week, .month, .threeMonths:
            formatter.dateFormat = "d MMM"
            return formatter.string(from: date)
        case .year, .allTime:
            formatter.dateFormat = "MMM"
            return formatter.string(from: date)
        }
    }
}
