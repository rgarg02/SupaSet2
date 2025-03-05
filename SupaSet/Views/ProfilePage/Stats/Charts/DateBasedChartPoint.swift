import SwiftUI
import Charts

// MARK: - Chart Data Protocol

/// Protocol for chart data points that are date-based
protocol DateBasedChartPoint: Identifiable, Equatable {
    var date: Date { get }
}

// MARK: - Reusable Progress Chart

struct WorkoutProgressChart<DataPoint: DateBasedChartPoint>: View {
    // Data and configuration
    let dataPoints: [DataPoint]
    let yValueProvider: (DataPoint) -> Double  // Using Double for simplicity
    let yAxisLabel: String
    let dateDomain: ClosedRange<Date>? // Optional for convenience, but handled internally
    let period: StatsPeriod
    
    // Selection state
    @Binding var rawSelectedDate: Date?
    let selectedDateProvider: (Date?) -> Date?
    
    // Styling and display options
    var showPoints: Bool = true
    var lineColor: Color = .blue
    var chartHeight: CGFloat = 200
    var showDaily: Bool = false
    var unit: Unit = .lbs
    
    // Animation
    var animate: Bool = true
    @State private var animationProgress: Double = 0
    
    // Show Average Toggle - using a State with a binding for proper update
    @Binding private var showAverageValue: Bool
    private var showAverageToggle: Bool
    
    // Initializer with optional binding for showAverage
    init(
        dataPoints: [DataPoint],
        yValueProvider: @escaping (DataPoint) -> Double,
        yAxisLabel: String,
        dateDomain: ClosedRange<Date>?,
        period: StatsPeriod,
        rawSelectedDate: Binding<Date?>,
        selectedDateProvider: @escaping (Date?) -> Date?,
        showPoints: Bool = true,
        lineColor: Color = .blue,
        chartHeight: CGFloat = 200,
        showDaily: Bool = false,
        unit: Unit = .lbs,
        animate: Bool = true,
        showAverage: Binding<Bool>? = nil
    ) {
        self.dataPoints = dataPoints
        self.yValueProvider = yValueProvider
        self.yAxisLabel = yAxisLabel
        self.dateDomain = dateDomain
        self.period = period
        self._rawSelectedDate = rawSelectedDate
        self.selectedDateProvider = selectedDateProvider
        self.showPoints = showPoints
        self.lineColor = lineColor
        self.chartHeight = chartHeight
        self.showDaily = showDaily
        self.unit = unit
        self.animate = animate
        
        // Handle the optional binding for showAverage
        if let showAverage = showAverage {
            self._showAverageValue = showAverage
            self.showAverageToggle = true
        } else {
            self._showAverageValue = .constant(false)
            self.showAverageToggle = false
        }
    }
    
    // Current data point based on selection
    var selectedDataPoint: DataPoint? {
        guard let date = selectedDateProvider(rawSelectedDate) else { return nil }
        return dataPoints.first(where: { $0.date == date })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with selection info and toggle if applicable
            HStack(spacing: 8) {
                Text("\(yAxisLabel) Progress")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                // Selection info
                if let dataPoint = selectedDataPoint {
                    VStack(alignment: .trailing) {
                        Text(formatDate(dataPoint.date))
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("\(Int(yValueProvider(dataPoint))) \(unit.rawValue)")
                            .font(.headline)
                            .foregroundColor(lineColor)
                    }
                }
            }
            // Only show the toggle for longer time periods when binding is provided
            if showAverageToggle && (period == .threeMonths || period == .year || period == .allTime) {
                HStack(spacing: 4) {
                    Text("Avg.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    Toggle("", isOn: $showAverageValue)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                        .labelsHidden()
                        .fixedSize()
                }
            }
            
            if dataPoints.isEmpty {
                Text("No data for this period")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: chartHeight)
            } else {
                Chart {
                    ForEach(dataPoints) { point in
                        // Line chart
                        LineMark(
                            x: .value("Date", point.date),
                            y: .value(yAxisLabel, animationProgress * yValueProvider(point))
                        )
                        .foregroundStyle(lineColor.gradient)
                        .interpolationMethod(.catmullRom)
                        .opacity(rawSelectedDate == nil || point.date == selectedDateProvider(rawSelectedDate) ? 1.0 : 0.4)
                        
                        // Area fill
                        AreaMark(
                            x: .value("Date", point.date),
                            y: .value(yAxisLabel, animationProgress * yValueProvider(point))
                        )
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [lineColor.opacity(0.3), Color.clear]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)
                        .opacity(rawSelectedDate == nil || point.date == selectedDateProvider(rawSelectedDate) ? 1.0 : 0.4)
                        
                        // Data points
                        if showPoints {
                            PointMark(
                                x: .value("Date", point.date),
                                y: .value(yAxisLabel, yValueProvider(point))
                            )
                            .foregroundStyle(lineColor)
                            .opacity(rawSelectedDate == nil || point.date == selectedDateProvider(rawSelectedDate) ? 1.0 : 0.4)
                            .symbolSize(point.date == selectedDateProvider(rawSelectedDate) ? 100 : 60)
                        }
                        
                        // Selection indicator
                        if let selected = selectedDateProvider(rawSelectedDate), point.date == selected {
                            RuleMark(
                                x: .value("Selected Date", selected)
                            )
                            .foregroundStyle(.gray.opacity(0.3))
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(preset: .aligned) {
                        AxisValueLabel()
                        AxisGridLine()
                    }
                }
                .chartXAxis {
                    AxisMarks(preset: .aligned) {
                        AxisValueLabel()
                        AxisGridLine()
                    }
                }
                // Only apply non-optional domain if one is provided
                .modifier(ChartDomainModifier(dateDomain: dateDomain))
                .chartXSelection(value: $rawSelectedDate)
                .frame(height: chartHeight)
                .animation(.easeInOut(duration: 1.0), value: animationProgress)
            }
        }
        .sensoryFeedback(.impact, trigger: selectedDataPoint)
        .onAppear {
            // Start animation when view appears if animation is enabled
            if animate {
                withAnimation(.easeInOut(duration: 1.0)) {
                    animationProgress = 1.0
                }
            } else {
                // Skip animation
                animationProgress = 1.0
            }
        }
    }
    
    // Format date based on selected period
    private func formatDate(_ date: Date) -> String {
        if showDaily {
            let formatter = DateFormatter()
            formatter.dateFormat = "E, d MMM"
            return formatter.string(from: date)
        }
        return PeriodDateFormatter.format(date: date, for: period)
    }
}

// MARK: - Date Selection Manager

struct ChartSelectionManager<DataPoint: DateBasedChartPoint> {
    let dataPoints: [DataPoint]
    
    func findClosestDate(to rawDate: Date?) -> Date? {
        guard let rawDate = rawDate, !dataPoints.isEmpty else {
            return nil
        }
        // Find the closest data point to the selected date
        return dataPoints.min(by: {
            abs($0.date.timeIntervalSince(rawDate)) < abs($1.date.timeIntervalSince(rawDate))
        })?.date
    }
}

// MARK: - Period Date Formatter

struct PeriodDateFormatter {
    static func format(date: Date, for period: StatsPeriod) -> String {
        let formatter = DateFormatter()
        switch period {
        case .week:
            formatter.dateFormat = "E, d MMM"
        case .month:
            formatter.dateFormat = "d MMM"
        case .threeMonths:
            // For 3-month period, show "X weeks ago" instead of the date
            let calendar = Calendar.current
            let now = Date()
            let components = calendar.dateComponents([.weekOfYear], from: date, to: now)
            if let weeks = components.weekOfYear {
                if weeks == 0 {
                    return "This week"
                } else if weeks == 1 {
                    return "1 week ago"
                } else {
                    return "\(weeks) weeks ago"
                }
            } else {
                formatter.dateFormat = "d MMM"
                return formatter.string(from: date)
            }
        case .year, .allTime:
            formatter.dateFormat = "MMM yyyy"
        }
        return formatter.string(from: date)
    }
}

// MARK: - Chart Domain Modifier
// Helper to conditionally apply chartXScale when domain is not nil
struct ChartDomainModifier: ViewModifier {
    let dateDomain: ClosedRange<Date>?
    
    func body(content: Content) -> some View {
        if let domain = dateDomain {
            content.chartXScale(domain: domain)
        } else {
            content
        }
    }
}

// MARK: - Chart Container

struct ChartContainer<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
    }
}

// MARK: - Chart Animation Controller

class ChartAnimationController: ObservableObject {
    @Published var animateChart = false
    @Published var animateLine = false
    @Published var animateArea = false
    @Published var animatePoints = false
    @Published var animateScale = false
    
    func resetAnimation() {
        animateChart = false
        animateLine = false
        animateArea = false
        animatePoints = false
        animateScale = false
    }
    
    func startAnimation() {
        // Sequence the animations with delays
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            animateChart = true
        }
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            animateScale = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 1.2, dampingFraction: 0.7)) {
                self.animateLine = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
                self.animateArea = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                self.animatePoints = true
            }
        }
    }
}
