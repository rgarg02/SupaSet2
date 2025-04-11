//
//  Build15.swift
//  DynamicIslandAnimation
//
//  Created by Rishi Garg on 4/11/25.
//

import SwiftUI

struct DynamicIslandHeader: View {
    let size: CGSize
    @State private var isExpandable: Bool = false

    var body: some View {
        VStack(spacing: 0) { // Reduce default spacing if needed
            HStack(alignment: .top, spacing: 15) { // Use HStack for icon + text
                Image(systemName: "iphone.gen3") // SF Symbol relevant to Lock Screen/Dynamic Island
                    .font(.title) // Adjust size as needed
                    .foregroundColor(Color.accentColor) // Use accent color
                    .frame(width: 30, alignment: .top) // Align icon top
                
                VStack(alignment: .leading, spacing: 3) { // VStack for title & description
                    Text("Live Activity Tracking")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Track and control your current set right from the Lock Screen or Dynamic Island.")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .lineLimit(3) // Allow wrapping but keep it concise
                }
                Spacer() // Push content to the left
            }
            .padding(.horizontal)
        }
        // --- Overall View Styling & Animation ---
        .padding(.horizontal, 5) // Reduced overall horizontal padding slightly
        .padding(.vertical, 0) // Manage vertical padding internally
        .foregroundStyle(.white) // Default text color for content
        .frame(width: isExpandable ? size.width - 22 : 126, height: isExpandable ? 175 : 37) // Adjusted expanded height
        .blur(radius: isExpandable ? 0 : 30)
        .opacity(isExpandable ? 1 : 0)
        .scaleEffect(isExpandable ? 1 : 0.5, anchor: .top)
        .background {
            RoundedRectangle(cornerRadius: isExpandable ? 45 : 30, style: .continuous) // Adjusted corner radius
                .fill(.black)
        }
        .clipped()
        .offset(y: 11)
        .onAppear {
            isExpandable = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 2)) {
                    isExpandable = true
                }
            }
        }
        // Apply overall animation for expand/collapse
        .animation(.snappy(duration: 0.35, extraBounce: 0), value: isExpandable)
    }
 
}

struct Build15: View {
    @State private var currentPage: Int = 0
    @State private var isExpandable = false
    @Environment(\.dismiss) private var dismiss
    let update = WhatsNewUpdate(version: "1.0", build: "15", pages: [WhatsNewPage(features: [Feature(title: "Rest Timer Notifications", description: "Get notified when your rest timer is up!", systemName: "timer"), Feature(title: "Performance Improvement", description: "Snappier animations and bug fixes", systemName: "bolt")])])
    let pages = 2
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
                VStack(spacing: 16){
                    VStack(spacing: 10) {
                        Text("What's New")
                            .font(.title.bold())
                        
                        Text("Version 1.0 Build 15")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, geometry.safeAreaInsets.top + 60)
                    Spacer()
                    TabView(selection: $currentPage) {
                        DynamicIslandHeader(size: size)
                            .tag(0)
                        VStack(alignment: .leading, spacing: 5) { // VStack for title & description
                            Text("Try It Out!") // Action-oriented title
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Text("Adjust sets, weight & reps directly via Lock Screen or Dynamic Island.") // Highlights actions
                                .font(.subheadline)
                                .foregroundColor(.text.opacity(0.85)) // Slightly dimmer than title
                                .lineLimit(3)
                        }
                        .tag(1)
                        ForEach(update.pages) {page in
                            WhatsNewPageView(page: page)
                                .tag(2)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    Spacer()
                    CustomButton(
                        icon: currentPage < 2 ? "chevron.right" : nil,
                        title: "\(currentPage < 2 ? "Next" : "Continue")",
                        size: .small,
                        style: .filled(
                            background: .accent,
                            foreground: Color.text
                        ),
                        action: {
                            if currentPage < 2 {
                                currentPage += 1
                            } else {
                                WhatsNewManager.saveCurrentBuildNumber()
                                dismiss()
                            }
                        }
                    )
                    .frame(maxHeight: .infinity, alignment: .trailing)
                    .padding(.horizontal)
                }
            .animation(.snappy(duration: 0.5, extraBounce: 0), value: isExpandable)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onChange(of: currentPage, { oldValue, newValue in
                if newValue != 1 {
                    isExpandable = false
                } else {
                    isExpandable = true
                }
            })
            .statusBarHidden(isExpandable)
            .overlay {
                IslandView(size: size, isExpandable: $isExpandable)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .offset(y: 11)
            }
            .background(.regularMaterial)
        }
        .ignoresSafeArea()
    }
}
struct IslandView: View {
    let size: CGSize
    @Binding var isExpandable: Bool

    // --- States for values ---
    @State private var currentWeight = 60
    @State private var currentReps = 10
    @State private var currentSet = 3
    let maxSets = 4 // Define max sets
    // --- Animation Duration (for numeric changes) ---
    let valueChangeDuration = 0.3

    var body: some View {
        VStack(spacing: 0) { // Reduce default spacing if needed
            // Top Row (Dumbbell & Time)
            HStack{
                Image(systemName: "dumbbell.fill")
                    .font(.callout.bold())
                Spacer()
                Text("12:00")
                    .font(.callout.bold().monospacedDigit())
            }
            .padding(.horizontal, 30) // Adjust padding
            .padding(.top, 15) // Adjust padding
            .frame(height: 20) // Give consistent height

            // Middle Row (Weight, Title, Reps)
            HStack{
                // Weight Text with Shine
                Text("\(currentWeight) lbs")
                    .font(.headline.monospacedDigit())
                    .frame(width: 70, alignment: .center) // Wider frame
                    .contentTransition(.numericText(countsDown: currentWeight.description.count > String(currentWeight - 5).count)) // Animate number changes

                Spacer()

                Text("Push Day")
                    .font(.title3.bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.8) // Allow text to shrink slightly if needed

                Spacer()

                // Reps Text with Shine
                Text("\(currentReps) reps")
                    .font(.headline.monospacedDigit())
                    .frame(width: 70, alignment: .center) // Wider frame
                    .contentTransition(.numericText(countsDown: currentReps.description.count > String(currentReps - 1).count)) // Animate number changes
            }
            .padding(.horizontal, 20)
            .padding(.top, 10) // Adjust padding

            // Controls Row (Minus/Plus, Set Info)
            HStack(spacing: 10) {
                controlButton(systemName: "minus") { decreaseWeight() }
                controlButton(systemName: "plus") { increaseWeight() }

                Spacer()

                // Set Text with Shine
                Text("Set \(currentSet)/\(maxSets)")
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .foregroundStyle(.white.opacity(0.9))
                    .background(Color.primaryThemeColorTwo.opacity(0.6)) // Adjusted opacity
                    .clipShape(Capsule())
                    .contentTransition(.numericText(countsDown: false)) // Animate number changes in Set

                Spacer()

                controlButton(systemName: "minus") { decreaseReps() }
                controlButton(systemName: "plus") { increaseReps() }
            }
            .foregroundStyle(.black)
            .frame(height: 35) // Give the control row a defined height
            .padding(.horizontal, 15) // Adjust padding
            .padding(.top, 5) // Adjust padding

            // Complete Set Button
            Button {
                completeCurrentSet()
            } label: {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Complete Set")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.primaryThemeColorTwo)
                .clipShape(.capsule)
                .foregroundStyle(Color.white)
            }
            .buttonStyle(.plain) // Ensure background and foreground work as expected
            .padding(.horizontal, 15) // Add horizontal padding
            .padding(.top, 10) // Add spacing above button
            .padding(.bottom, 10) // Add bottom padding

           // Removed Spacer() to let content determine height more naturally within frame
        }
        .onChange(of: isExpandable, { oldValue, newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    increaseWeight()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        increaseReps()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            completeCurrentSet()
                        }
                    }
                    
                }
            }
        })
        // --- Overall View Styling & Animation ---
        .padding(.horizontal, 5) // Reduced overall horizontal padding slightly
        .padding(.vertical, 0) // Manage vertical padding internally
        .foregroundStyle(.white) // Default text color for content
        .frame(width: isExpandable ? size.width - 22 : 126, height: isExpandable ? 175 : 37) // Adjusted expanded height
        .blur(radius: isExpandable ? 0 : 30)
        .opacity(isExpandable ? 1 : 0)
        .scaleEffect(isExpandable ? 1 : 0.5, anchor: .top)
        .background {
            RoundedRectangle(cornerRadius: isExpandable ? 45 : 30, style: .continuous) // Adjusted corner radius
                .fill(.black)
        }
        .clipped()
        .offset(y: 0)
        // Apply overall animation for expand/collapse
        .animation(.snappy(duration: 0.35, extraBounce: 0), value: isExpandable)
        // Add explicit animation for value changes within buttons (affects contentTransition)
        .animation(.easeInOut(duration: valueChangeDuration), value: currentWeight)
        .animation(.easeInOut(duration: valueChangeDuration), value: currentReps)
        .animation(.easeInOut(duration: valueChangeDuration), value: currentSet)
    }

    // MARK: - Button Actions

    func increaseWeight() {
        withAnimation(.easeInOut(duration: valueChangeDuration)) {
            currentWeight += 5
        }
    }

    func decreaseWeight() {
        guard currentWeight >= 5 else { return } // Prevent going below zero or min
        withAnimation(.easeInOut(duration: valueChangeDuration)) {
            currentWeight -= 5
        }
    }

    func increaseReps() {
        withAnimation(.easeInOut(duration: valueChangeDuration)) {
            currentReps += 1
        }
    }

    func decreaseReps() {
        guard currentReps >= 1 else { return } // Prevent going below zero or min
        withAnimation(.easeInOut(duration: valueChangeDuration)) {
            currentReps -= 1
        }
    }

    func completeCurrentSet() {
        guard currentSet < maxSets else { return } // Don't increase if already at max
        withAnimation(.easeInOut(duration: valueChangeDuration)) {
            currentSet += 1
        }
    }


    // MARK: - Control Button Helper

    @ViewBuilder
    func controlButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.body.weight(.medium))
                .padding(8) // Slightly larger padding for tap area
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundStyle(.black) // Icon color
                .background(Color.accent.opacity(0.8)) // Button background
                .clipShape(.circle)
        }
        .buttonStyle(.plain) // Allows custom styling
        .frame(width: 35, height: 35) // Define button size
    }
}

#Preview(body: {
    Build15()
})
#Preview {
    GeometryReader {geometry in
        let size = geometry.size
        DynamicIslandHeader(size: size)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    
}
