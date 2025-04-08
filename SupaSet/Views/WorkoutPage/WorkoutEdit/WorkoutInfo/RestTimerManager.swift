//
//  RestTimerManager.swift
//  SupaSet
//
//  Created by Rishi Garg on 3/31/25.
//


//
//  RestTimerView.swift
//  SupaSet
//
//  Created by Rishi Garg on 3/31/25.
//

import SwiftUI
import SwiftData
import UserNotifications

class RestTimerManager: ObservableObject {
    static let shared = RestTimerManager()
    
    @Published var isTimerActive = false
    @Published var timeRemaining: TimeInterval = 0
    @Published var totalTime: TimeInterval = 0
    @Published var exerciseID: String = ""
    
    private var timer: Timer?
    private var expirationDate: Date?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    init() {
        // Request notification permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
        
        // Add observers for app state changes
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appMovedToBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appMovedToForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func startTimer(duration: TimeInterval, for exerciseID: String) {
        // Cancel any existing timer
        stopTimer()
        
        // Set up new timer
        self.totalTime = duration
        self.timeRemaining = duration
        self.exerciseID = exerciseID
        self.isTimerActive = true
        
        // Store expiration date
        self.expirationDate = Date().addingTimeInterval(duration)
        
        // Create timer that updates every second
        startForegroundTimer()
        
        // Schedule a local notification for when the timer completes
        scheduleTimerCompletionNotification()
    }
    
    func stopTimer() {
        invalidateTimer()
        cancelBackgroundTask()
        cancelNotification()
        
        isTimerActive = false
        timeRemaining = 0
        expirationDate = nil
    }
    
    private func startForegroundTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.updateTimeRemaining()
        }
    }
    
    private func updateTimeRemaining() {
        guard let expirationDate = expirationDate else { return }
        
        let newTimeRemaining = max(0, expirationDate.timeIntervalSinceNow)
        DispatchQueue.main.async {
            self.timeRemaining = newTimeRemaining
            
            if newTimeRemaining <= 0 {
                self.timerCompleted()
            }
        }
    }
    
    private func timerCompleted() {
        stopTimer()
    }
    
    // MARK: - Background handling
    
    @objc private func appMovedToBackground() {
        invalidateTimer() // Stop the foreground timer
        
        // Start background task to keep app running a bit longer
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.cancelBackgroundTask()
        }
        
        // We don't need to start another timer in the background
        // The app will use the expiration date to calculate remaining time when it returns to foreground
    }
    
    @objc private func appMovedToForeground() {
        cancelBackgroundTask()
        
        if isTimerActive {
            updateTimeRemaining() // Update the time remaining based on actual elapsed time
            if timeRemaining > 0 {
                startForegroundTimer() // Restart the timer
            } else {
                stopTimer() // Timer completed while in background
            }
        }
    }
    
    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func cancelBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
    
    // MARK: - Notifications
    
    private func scheduleTimerCompletionNotification() {
        guard let expirationDate = expirationDate else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Rest Timer Complete"
        content.body = "Time to start your next set!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeRemaining, repeats: false)
        let request = UNNotificationRequest(identifier: "RestTimer-\(exerciseID)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func cancelNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["RestTimer-\(exerciseID)"])
    }
    
    // MARK: - Helper methods
    
    // Format time as MM:SS
    func formattedTime() -> String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%01d:%02d", minutes, seconds)
    }
    
    // Calculate progress value (0.0 to 1.0)
    func progress() -> Double {
        if totalTime == 0 { return 0 }
        return 1.0 - (timeRemaining / totalTime)
    }
}
struct AutoRestTimerView: View {
    @ObservedObject private var timerManager = RestTimerManager.shared
    @State private var animatedProgress: Double = 0
    var body: some View {
        if timerManager.isTimerActive {
            ZStack {
                // Background and progress overlay (moved to bottom of ZStack)
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background material
                        Rectangle()
                            .fill(.thickMaterial)
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                        
                        // Fill progress bar
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.primaryThemeColorTwo.adjusted(by: -20), Color.primaryThemeColorTwo],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * animatedProgress)
                    }
                }
                
                // Timer text (now on top of the ZStack)
                Text(timerManager.formattedTime())
                    .monospacedDigit()
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .foregroundStyle(.text)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
            }
            .fixedSize()
            .clipShape(Capsule())
            .onAppear {
                // Start with zero progress
                animatedProgress = 0
                
                // Animate to actual progress
                withAnimation(.easeInOut(duration: 0.8)) {
                    animatedProgress = timerManager.progress()
                }
            }
            .onChange(of: timerManager.timeRemaining) { oldValue, newValue in
                // Animate when progress changes
                withAnimation(.linear(duration: 0.3)) {
                    animatedProgress = timerManager.progress()
                }
            }
        }
    }
}
