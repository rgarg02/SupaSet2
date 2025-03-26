//
//  OnboardingView.swift
//  SupaSet
//
//  Created by Rishi Garg on 3/6/25.
//

import SwiftUI
import SwiftData


struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @State private var userProfileViewModel: UserProfileViewModel
    @Binding var isOnboardingComplete: Bool
    
    @State private var currentStep = 0
    @State private var showingSummary = false
    @State private var showingImportOptions = false
    @State private var connectToHealthKit = false
    
    @State private var gradientPhase: Double = 0    // User data
    @State private var name = ""
    @State private var age = 25
    @State private var gender: Gender = .preferNotToSay
    @State private var height = 170.0
    @State private var weight = 70.0
    @State private var bodyFatPercentage: Double? = nil
    @State private var fitnessGoal: FitnessGoal = .maintenance
    @State private var experienceLevel: ExperienceLevel = .beginner
    @State private var trainingDaysPerWeek = 3
    @State private var sessionDuration = 60
    @State private var selectedEquipment: [Equipment] = []
    @State private var notificationsEnabled = true
    private let totalSteps = 6
    
    init(isOnboardingComplete: Binding<Bool>, modelContext: ModelContext) {
        self._isOnboardingComplete = isOnboardingComplete
        self.userProfileViewModel = UserProfileViewModel(modelContext: modelContext)
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        .primaryThemeColorTwo,
                        .secondaryTheme,
                        .secondaryTheme.adjusted(by: 62.5)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Subtle accent gradient overlay
                RadialGradient(
                    gradient: Gradient(colors: [
                        .accent.opacity(0.1),
                        .primaryTheme.opacity(0.05),
                        Color.clear
                    ]),
                    center: .topTrailing,
                    startRadius: 100,
                    endRadius: 600
                )
                .ignoresSafeArea()
                
                VStack {
                    // Modern progress bar
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 6)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.theme.accent, Color.theme.accent.opacity(0.6)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(0, min(geo.size.width, geo.size.width * (CGFloat(max(0, currentStep)) / CGFloat(max(1, totalSteps - 1))))), height: 6)
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentStep)
                    }
                    
                    // Step indicator
                    HStack {
                        Text("Step \(currentStep + 1) of \(totalSteps)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.leading)
                        
                        Spacer()
                        
                        if currentStep > 0 && !showingSummary {
                            Button {
                                withAnimation {
                                    currentStep -= 1
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "chevron.left")
                                        .font(.caption)
                                    Text("Back")
                                }
                                .foregroundColor(Color.theme.accent)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.trailing)
                        }
                    }
                    .padding(.top, 8)
                    
                    if showingSummary {
                        ProfileSummaryView(
                            name: name,
                            age: age,
                            gender: gender,
                            height: height,
                            weight: weight,
                            bodyFatPercentage: bodyFatPercentage,
                            fitnessGoal: fitnessGoal,
                            experienceLevel: experienceLevel,
                            trainingDaysPerWeek: trainingDaysPerWeek,
                            sessionDuration: sessionDuration,
                            selectedEquipment: selectedEquipment,
                            connectToHealthKit: connectToHealthKit,
                            notificationsEnabled: notificationsEnabled,
                            onComplete: saveUserProfile,
                            onEdit: { showingSummary = false }
                        )
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    } else {
                        // Instead of a swipeable TabView, we use a conditional view.
                        Group {
                            switch currentStep {
                            case 0:
                                WelcomeView(name: $name)
                                    .scrollDisabled(true)
                            case 1:
                                PhysiologyView(
                                    age: $age,
                                    gender: $gender,
                                    height: $height,
                                    weight: $weight,
                                    bodyFatPercentage: $bodyFatPercentage,
                                    showingImportOptions: $showingImportOptions
                                )
                            case 2:
                                GoalsView(fitnessGoal: $fitnessGoal)
                            case 3:
                                PreferencesView(
                                    experienceLevel: $experienceLevel,
                                    trainingDaysPerWeek: $trainingDaysPerWeek,
                                    sessionDuration: $sessionDuration
                                )
                            case 4:
                                EquipmentView(selectedEquipment: $selectedEquipment)
                            case 5:
                                IntegrationsView(
                                    connectToHealthKit: $connectToHealthKit,
                                    notificationsEnabled: $notificationsEnabled
                                )
                            default:
                                EmptyView()
                            }
                        }
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentStep)
                        // Optionally, add a transition (e.g., .slide) if you want a visual effect when switching views.
                    }
                    
                    if !showingSummary {
                        GradientButton(label: buttonLabel, disabled: currentStep == 0 && name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
                            if currentStep < totalSteps - 1 {
                                withAnimation {
                                    currentStep += 1
                                }
                            } else {
                                withAnimation {
                                    showingSummary = true
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .ignoresSafeArea(.keyboard, edges: .all)
        }
        .sheet(isPresented: $showingImportOptions) {
            ImportDataView()
        }
    }
    
    private var buttonLabel: String {
        currentStep < totalSteps - 1 ? "Continue" : "Review Profile"
    }
    
    private func saveUserProfile() {
        do {
            try userProfileViewModel.createUserProfile(
                name: name,
                age: age,
                gender: gender,
                height: height,
                weight: weight,
                bodyFatPercentage: bodyFatPercentage,
                fitnessGoal: fitnessGoal,
                experienceLevel: experienceLevel,
                trainingDaysPerWeek: trainingDaysPerWeek,
                equipmentAccess: selectedEquipment
                //              healthKitEnabled: connectToHealthKit,
                //              notificationsEnabled: notificationsEnabled
            )
            
            // Configure notifications if enabled
            if notificationsEnabled {
                requestNotificationPermissions()
            }
            
            // Configure HealthKit if enabled
            if connectToHealthKit {
                connectToAppleHealth()
            }
            
            withAnimation {
                isOnboardingComplete = true
            }
        } catch {
            print("Error saving user profile: \(error)")
        }
    }
    
    private func requestNotificationPermissions() {
        // Request notification permissions here
        print("Requesting notification permissions")
    }
    
    private func connectToAppleHealth() {
        // Setup HealthKit integration here
        print("Setting up HealthKit integration")
    }
}

// MARK: - Individual Views

struct WelcomeView: View {
    @Binding var name: String
    @FocusState private var isNameFieldFocused: Bool
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 30) {
                    // App logo animation
                    LogoView()
                    WelcomeTextView()
                    
                    Text("Your personal fitness journey starts here")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("What should we call you?")
                            .font(.headline)
                        
                        TextField("", text: $name)
                            .placeholder(when: name.isEmpty) {
                                Text("Your Name").foregroundColor(.gray.opacity(0.8))
                            }
                            .font(.title3)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.05)))
                            )
                            .focused($isNameFieldFocused)
                            .submitLabel(.done)
                            .id("nameField")
                            .onChange(of: isNameFieldFocused) { _ , focused in
                                if focused {
                                    withAnimation {
                                        proxy.scrollTo("nameField", anchor: .center)
                                    }
                                }
                            }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 20)
                    
                    Text("We'll use this information to personalize your fitness plan and track your progress")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 320)
                        .padding()
                }
                .padding()
                .padding(.bottom, keyboardHeight)
            }
        }
        .onAppear {
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
                keyboardHeight = keyboardFrame.height
            }
            
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                keyboardHeight = 0
            }
        }
    }
}

struct PhysiologyView: View {
    @Binding var age: Int
    @Binding var gender: Gender
    @Binding var height: Double
    @Binding var weight: Double
    @Binding var bodyFatPercentage: Double?
    @Binding var showingImportOptions: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                Text("Your Physiology")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .padding(.top)
                
                Text("This helps us personalize your workout plan")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Button {
                    showingImportOptions = true
                } label: {
                    HStack {
                        Image(systemName: "arrow.down.doc.fill")
                            .foregroundColor(Color.theme.accent)
                        Text("Import from Health app or other services")
                            .font(.subheadline)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.theme.accent.opacity(0.1))
                    )
                }
                
                VStack(spacing: 25) {
                    // Age selection with modern UI
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Age")
                                .font(.headline)
                            Spacer()
                            Text("\(age) years")
                                .font(.headline)
                                .foregroundColor(Color.theme.accent)
                        }
                        
                        HStack {
                            Button { if age > 16 { age -= 1 } } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(age > 16 ? .gray : .gray.opacity(0.3))
                            }
                            .disabled(age <= 16)
                            
                            Slider(value: Binding(
                                get: { Double(age) },
                                set: { age = Int($0) }
                            ), in: 16...100, step: 1)
                            .accentColor(Color.theme.accent)
                            
                            Button { if age < 100 { age += 1 } } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(age < 100 ? .gray : .gray.opacity(0.3))
                            }
                            .disabled(age >= 100)
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.05)))
                    
                    // Gender selection with modern UI
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Gender")
                            .font(.headline)
                        
                        HStack(spacing: 10) {
                            ForEach(Gender.allCases, id: \.self) { genderOption in
                                GenderButton(
                                    gender: genderOption,
                                    isSelected: gender == genderOption,
                                    action: { gender = genderOption }
                                )
                            }
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.05)))
                    
                    // Height selection with modern UI
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Height")
                                .font(.headline)
                            Spacer()
                            Text("\(Int(height)) cm")
                                .font(.headline)
                                .foregroundColor(Color.theme.accent)
                        }
                        
                        HStack {
                            Text("120 cm")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Slider(value: $height, in: 120...220, step: 1)
                                .accentColor(Color.theme.accent)
                            
                            Text("220 cm")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.05)))
                    
                    // Weight selection with modern UI
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Weight")
                                .font(.headline)
                            Spacer()
                            Text("\(Int(weight)) kg")
                                .font(.headline)
                                .foregroundColor(Color.theme.accent)
                        }
                        
                        HStack {
                            Text("40 kg")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Slider(value: $weight, in: 40...200, step: 1)
                                .accentColor(Color.theme.accent)
                            
                            Text("200 kg")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.05)))
                    
                    // Body Fat percentage (Optional)
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Body Fat % (Optional)")
                                .font(.headline)
                            
                            Spacer()
                            
                            if bodyFatPercentage != nil {
                                Button(action: { bodyFatPercentage = nil }) {
                                    Text("Clear")
                                        .font(.caption)
                                        .foregroundColor(Color.theme.accent)
                                }
                            }
                        }
                        
                        if let bf = bodyFatPercentage {
                            HStack {
                                Text("\(Int(bf))%")
                                    .font(.headline)
                                    .foregroundColor(Color.theme.accent)
                                
                                Slider(value: Binding(
                                    get: { bf },
                                    set: { bodyFatPercentage = $0 }
                                ), in: 5...50, step: 1)
                                .accentColor(Color.theme.accent)
                            }
                            
                            // Body fat visualization and info
                            HStack(spacing: 15) {
                                ZStack {
                                    Circle()
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 10)
                                        .frame(width: 70, height: 70)
                                    
                                    Circle()
                                        .trim(from: 0, to: CGFloat(bf) / 100)
                                        .stroke(bodyFatColor(percentage: bf), lineWidth: 10)
                                        .frame(width: 70, height: 70)
                                        .rotationEffect(.degrees(-90))
                                    
                                    Text("\(Int(bf))%")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(bodyFatColor(percentage: bf))
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(bodyFatCategory(percentage: bf, gender: gender))
                                        .font(.subheadline)
                                        .foregroundColor(bodyFatColor(percentage: bf))
                                    
                                    Text(bodyFatDescription(percentage: bf, gender: gender))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 5)
                        } else {
                            Button {
                                bodyFatPercentage = gender == .female ? 25.0 : 20.0
                            } label: {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add Body Fat %")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.theme.accent.opacity(0.5), lineWidth: 1)
                                )
                            }
                            .foregroundColor(Color.theme.accent)
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.05)))
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 30)
        }
    }
    
    private func bodyFatColor(percentage: Double) -> Color {
        if gender == .female {
            if percentage < 15 { return .blue }  // Essential fat
            else if percentage < 24 { return .green }  // Athletic/Fitness
            else if percentage < 32 { return .orange }  // Average
            else { return .red }  // Obese
        } else {
            if percentage < 8 { return .blue }  // Essential fat
            else if percentage < 15 { return .green }  // Athletic/Fitness
            else if percentage < 25 { return .orange }  // Average
            else { return .red }  // Obese
        }
    }
    
    private func bodyFatCategory(percentage: Double, gender: Gender) -> String {
        if gender == .female {
            if percentage < 15 { return "Essential Fat" }
            else if percentage < 24 { return "Athletic/Fitness" }
            else if percentage < 32 { return "Average" }
            else { return "Obese" }
        } else {
            if percentage < 8 { return "Essential Fat" }
            else if percentage < 15 { return "Athletic/Fitness" }
            else if percentage < 25 { return "Average" }
            else { return "Obese" }
        }
    }
    
    private func bodyFatDescription(percentage: Double, gender: Gender) -> String {
        if gender == .female {
            if percentage < 15 { return "Minimum needed for basic health" }
            else if percentage < 24 { return "Lean and fit appearance" }
            else if percentage < 32 { return "Typical for many adults" }
            else { return "Higher health risk" }
        } else {
            if percentage < 8 { return "Minimum needed for basic health" }
            else if percentage < 15 { return "Lean and fit appearance" }
            else if percentage < 25 { return "Typical for many adults" }
            else { return "Higher health risk" }
        }
    }
}

struct GenderButton: View {
    let gender: Gender
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: genderIcon(gender))
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .white : Color.theme.accent)
                
                Text(gender.rawValue.capitalized)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.theme.accent : Color.gray.opacity(0.1))
            )
            .animation(.spring(response: 0.3), value: isSelected)
        }
        .frame(height: 30)
    }
    
    private func genderIcon(_ gender: Gender) -> String {
        switch gender {
        case .male:
            return "figure.wave.circle.fill"
        case .female:
            return "figure.arms.open"
        case .preferNotToSay:
            return "questionmark.circle.fill"
        case .other:
            return "questionmark.circle.fill"
        }
    }
}

struct GoalsView: View {
    @Binding var fitnessGoal: FitnessGoal
    @State private var currentOffset: CGFloat = 0
    
    var body: some View {
        ScrollView{
            VStack(spacing: 20) {
                Text("Your Fitness Goals")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                
                Text("What do you primarily want to achieve?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 10)
                
                LazyVGrid(columns: .init(repeating: GridItem(.flexible()), count: 2),spacing: 8, content: {
                    ForEach(FitnessGoal.allCases, id: \.self) { goal in
                        GoalCardModern(
                            goal: goal,
                            isSelected: fitnessGoal == goal,
                            action: { fitnessGoal = goal }
                        )
                        //                    .padding(.horizontal, 15)
                        //                        .frame(width: 270)
                    }
                })
                // Goal cards carousel
                //            ScrollView(.horizontal, showsIndicators: false) {
                //                LazyHStack(spacing: 0) {
                //                    ForEach(FitnessGoal.allCases, id: \.self) { goal in
                //                        GoalCardModern(
                //                            goal: goal,
                //                            isSelected: fitnessGoal == goal,
                //                            action: { fitnessGoal = goal }
                //                        )
                //                        .padding(.horizontal, 15)
                ////                        .frame(width: 270)
                //                    }
                //                }
                //            }
                
                // Goal description
                VStack(alignment: .leading, spacing: 10) {
                    Text("Goal Details")
                        .font(.headline)
                    
                    Text(goalDescription(for: fitnessGoal))
                        .foregroundColor(.secondary)
                    
                    // Goal specific tips
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tips for \(fitnessGoal.rawValue.capitalized):")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .padding(.top, 5)
                        
                        ForEach(goalTips(for: fitnessGoal), id: \.self) { tip in
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color.theme.accent)
                                    .font(.caption)
                                    .padding(.top, 3)
                                
                                Text(tip)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.top, 5)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.05)))
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .scrollIndicators(.hidden)
        .padding()
    }
    
    private func goalDescription(for goal: FitnessGoal) -> String {
        switch goal {
        case .weightLoss:
            return "Focus on reducing body fat while preserving muscle mass. We'll create a plan that combines strength training and cardio with a calorie deficit to help you shed weight in a sustainable way."
        case .muscleGain:
            return "Prioritize building lean muscle through progressive resistance training. Your plan will focus on hypertrophy with adequate recovery and a nutrition approach to support muscle growth."
        case .maintenance:
            return "Keep your current physique while improving overall fitness. This balanced approach helps maintain your body composition while still making progress in strength and endurance."
        case .strength:
            return "Develop maximum power and strength with a focus on compound movements and low-to-medium rep ranges. We'll structure your program to optimize for strength gains."
        case .endurance:
            return "Enhance your cardiovascular health and stamina with a mix of cardio and conditioning work. Your plan will help you build the ability to exercise for longer periods with less fatigue."
        case .athleticPerformance:
            return "Improve specific athletic capacities like speed, agility, and power. Your plan will be tailored to enhance the physical attributes most relevant to your sport or activity."
        }
    }
    
    private func goalTips(for goal: FitnessGoal) -> [String] {
        switch goal {
        case .weightLoss:
            return [
                "Aim for a moderate calorie deficit of 300-500 calories per day",
                "Prioritize protein intake to preserve muscle mass",
                "Include both strength training and cardio in your routine",
                "Stay consistent with your workout schedule",
                "Track your progress with measurements beyond just weight"
            ]
        case .muscleGain:
            return [
                "Maintain a small calorie surplus of 200-300 calories per day",
                "Consume 1.6-2.2g of protein per kg of bodyweight",
                "Focus on progressive overload in your training",
                "Ensure adequate sleep for optimal recovery",
                "Be patient - muscle growth is a gradual process"
            ]
        case .maintenance:
            return [
                "Eat at your maintenance calorie level",
                "Balance your training between strength and conditioning",
                "Focus on performance improvements rather than body composition",
                "Periodically reassess to ensure you're still at maintenance",
                "Use this phase to perfect your technique on exercises"
            ]
        case .strength:
            return [
                "Focus on compound movements like squats, deadlifts, and presses",
                "Train in lower rep ranges (1-6) with heavier weights",
                "Allow for adequate recovery between strength sessions",
                "Ensure sufficient calorie and protein intake",
                "Track your lifts to ensure progressive overload"
            ]
        case .endurance:
            return [
                "Gradually increase duration and intensity of cardio sessions",
                "Incorporate interval training for improved cardiovascular capacity",
                "Don't neglect strength training, as it supports endurance",
                "Pay attention to pre and post-workout nutrition",
                "Include recovery sessions in your routine"
            ]
        case .athleticPerformance:
            return [
                "Incorporate sport-specific movements in your training",
                "Balance strength, power, and conditioning work",
                "Include plyometrics and speed drills as appropriate",
                "Time your nutrition around training for optimal performance",
                "Plan deload weeks to prevent overtraining"
            ]
        }
    }
}

struct GoalCardModern: View {
    let goal: FitnessGoal
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 15) {
                // Icon for the goal
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.theme.accent : Color.gray.opacity(0.1))
                        .frame(width: 20, height: 20)
                    
                    Image(systemName: iconForGoal(goal))
                        .font(.system(size: 15))
                        .foregroundColor(isSelected ? .white : .gray)
                }
                
                Text(goal.rawValue.capitalized)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? Color.theme.accent : .primary)
                
                Text(shortDescription(for: goal))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                
                if isSelected {
                    HStack {
                        Spacer()
                        Text("Selected")
                            .font(.caption)
                            .foregroundColor(Color.theme.accent)
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color.theme.accent)
                    }
                }
            }
            .padding()
            .frame(height: 200)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        isSelected ?
                        Color.theme.accent.opacity(0.1) :
                            Color.gray.opacity(0.05)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? Color.theme.accent : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func iconForGoal(_ goal: FitnessGoal) -> String {
        switch goal {
        case .weightLoss: return "scalemass.fill"
        case .muscleGain: return "figure.arms.open"
        case .maintenance: return "arrow.left.and.right.circle.fill"
        case .strength: return "dumbbell.fill"
        case .endurance: return "figure.run"
        case .athleticPerformance: return "trophy.fill"
        }
    }
    
    private func shortDescription(for goal: FitnessGoal) -> String {
        switch goal {
        case .weightLoss:
            return "Reduce body fat while preserving muscle mass"
        case .muscleGain:
            return "Build lean muscle and increase size"
        case .maintenance:
            return "Maintain current physique and fitness level"
        case .strength:
            return "Maximize strength and power output"
        case .endurance:
            return "Improve cardiovascular capacity and stamina"
        case .athleticPerformance:
            return "Enhance sport-specific physical abilities"
        }
    }
}

struct PreferencesView: View {
    @Binding var experienceLevel: ExperienceLevel
    @Binding var trainingDaysPerWeek: Int
    @Binding var sessionDuration: Int
    @State private var showingCalendarView = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                Text("Training Preferences")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                
                Text("Configure your ideal workout schedule")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Experience level
                VStack(alignment: .leading, spacing: 15) {
                    Text("Experience Level")
                        .font(.headline)
                    
                    VStack(spacing: 12) {
                        ForEach(ExperienceLevel.allCases, id: \.self) { level in
                            ExperienceLevelRow(
                                level: level,
                                isSelected: experienceLevel == level,
                                action: { experienceLevel = level }
                            )
                        }
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.gray.opacity(0.05)))
                .padding(.horizontal)
                
                // Training days per week
                VStack(alignment: .leading, spacing: 15) {
                    Text("How many days can you train per week?")
                        .font(.headline)
                    
                    HStack(spacing: 8) {
                        ForEach(1...7, id: \.self) { day in
                            DayButton(
                                day: day,
                                isSelected: trainingDaysPerWeek == day,
                                action: { trainingDaysPerWeek = day }
                            )
                        }
                    }
                    
                    Button {
                        showingCalendarView = true
                    } label: {
                        HStack {
                            Image(systemName: "calendar")
                            Text("Set preferred training days")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(.primary)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.gray.opacity(0.05)))
                .padding(.horizontal)
                
                // Session duration
                VStack(alignment: .leading, spacing: 15) {
                    Text("How long do you want to work out per session?")
                        .font(.headline)
                    
                    HStack {
                        Text("\(sessionDuration) minutes")
                            .font(.headline)
                            .foregroundColor(Color.theme.accent)
                        
                        Spacer()
                    }
                    
                    VStack(spacing: 15) {
                        Slider(value: Binding(
                            get: { Double(sessionDuration) },
                            set: { sessionDuration = Int($0) }
                        ), in: 15...120, step: 15)
                        .accentColor(Color.theme.accent)
                        
                        HStack {
                            Text("15 min")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("120 min")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Duration visualization
                    HStack(spacing: 0) {
                        ForEach([15, 30, 45, 60, 75, 90, 105, 120], id: \.self) { mins in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(mins <= sessionDuration ? Color.theme.accent : Color.gray.opacity(0.2))
                                .frame(height: 8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.vertical, 5)
                    
                    // Time recommendation
                    InfoBox(
                        title: "Recommendation",
                        text: recommendationText(),
                        icon: "info.circle.fill"
                    )
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.gray.opacity(0.05)))
                .padding(.horizontal)
                
                // Preview of weekly time commitment
                VStack(alignment: .leading, spacing: 10) {
                    Text("Weekly Time Commitment")
                        .font(.headline)
                    
                    HStack(spacing: 15) {
                        ZStack {
                            Circle()
                                .fill(Color.theme.accent.opacity(0.2))
                                .frame(width: 80, height: 80)
                            
                            VStack(spacing: 3) {
                                Text("\(trainingDaysPerWeek * sessionDuration)")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(Color.theme.accent)
                                
                                Text("minutes")
                                    .font(.caption)
                                    .foregroundColor(Color.theme.accent)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("\(trainingDaysPerWeek) days × \(sessionDuration) minutes")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Text(commitmentDescription())
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.gray.opacity(0.05)))
                .padding(.horizontal)
            }
            .padding(.bottom, 30)
        }
        .sheet(isPresented: $showingCalendarView) {
            WeeklyScheduleView(trainingDays: $trainingDaysPerWeek)
        }
    }
    
    private func recommendationText() -> String {
        switch experienceLevel {
        case .beginner:
            return "For beginners, 30-45 minute sessions are ideal to build consistency without overwhelming yourself."
        case .intermediate:
            return "As an intermediate, 45-60 minute focused sessions provide enough volume while maintaining intensity."
        case .advanced:
            return "Advanced lifters often benefit from longer 60-90 minute sessions to accommodate higher training volume."
        }
    }
    
    private func commitmentDescription() -> String {
        let minutes = trainingDaysPerWeek * sessionDuration
        
        if minutes < 90 {
            return "This is a very light commitment that may limit progress. Consider adding more time if possible."
        } else if minutes < 180 {
            return "This is a light commitment suitable for maintaining fitness or slow progress."
        } else if minutes < 300 {
            return "This is a moderate commitment that works well for most fitness goals."
        } else if minutes < 420 {
            return "This is a serious commitment that should yield good results for most goals."
        } else {
            return "This is a high commitment level similar to what dedicated athletes maintain."
        }
    }
}

struct ExperienceLevelRow: View {
    let level: ExperienceLevel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.theme.accent : Color.gray.opacity(0.2))
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 10, height: 10)
                    }
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(level.rawValue.capitalized)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(levelDescription(level))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.theme.accent.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func levelDescription(_ level: ExperienceLevel) -> String {
        switch level {
        case .beginner:
            return "New to fitness or returning after a long break (0-1 year experience)"
        case .intermediate:
            return "Consistent training with good form and basic knowledge (1-3 years)"
        case .advanced:
            return "Experienced with various training methods and nutrition (3+ years)"
        }
    }
}

struct DayButton: View {
    let day: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(isSelected ? Color.theme.accent : Color.gray.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Text("\(day)")
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .primary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct InfoBox: View {
    let title: String
    let text: String
    let icon: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Color.theme.accent)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(text)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.theme.accent.opacity(0.1))
        )
    }
}

struct EquipmentView: View {
    @Binding var selectedEquipment: [Equipment]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Equipment Access")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                
                Text("What equipment do you have available?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Quick selection buttons
                VStack(alignment: .leading, spacing: 10) {
                    Text("Quick Select")
                        .font(.headline)
                    
                    HStack {
                        QuickSelectButton(
                            title: "Home Basics",
                            isActive: isHomeBasicsSelected(),
                            action: toggleHomeBasics
                        )
                        
                        QuickSelectButton(
                            title: "Full Gym",
                            isActive: isFullGymSelected(),
                            action: toggleFullGym
                        )
                        
                        QuickSelectButton(
                            title: "No Equipment",
                            isActive: selectedEquipment.isEmpty,
                            action: { selectedEquipment = [] }
                        )
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.gray.opacity(0.05)))
                .padding(.horizontal)
                
                // Equipment grid
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100, maximum: 120))], spacing: 15) {
                    ForEach(Equipment.allCases, id: \.self) { equipment in
                        EquipmentCardModern(
                            equipment: equipment,
                            isSelected: selectedEquipment.contains(equipment),
                            action: {
                                toggleEquipment(equipment)
                            }
                        )
                    }
                }
                .padding(.horizontal)
                
                // Selected counter
                HStack {
                    Text("\(selectedEquipment.count) items selected")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if !selectedEquipment.isEmpty {
                        Button("Clear All") {
                            selectedEquipment = []
                        }
                        .font(.subheadline)
                        .foregroundColor(Color.theme.accent)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.gray.opacity(0.05)))
                .padding(.horizontal)
                
                // Recommendation based on selection
                if !selectedEquipment.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Equipment Summary")
                            .font(.headline)
                        
                        Text(equipmentRecommendation())
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.gray.opacity(0.05)))
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, 30)
        }
    }
    
    private func toggleEquipment(_ equipment: Equipment) {
        if selectedEquipment.contains(equipment) {
            selectedEquipment.removeAll { $0 == equipment }
        } else {
            selectedEquipment.append(equipment)
        }
    }
    
    private func isHomeBasicsSelected() -> Bool {
        let homeBasics: [Equipment] = [.dumbbell, .bands]
        return homeBasics.allSatisfy { selectedEquipment.contains($0) }
    }
    
    private func isFullGymSelected() -> Bool {
        let gymEquipment: [Equipment] = [.barbell, .cable, .dumbbell, .machine]
        return gymEquipment.allSatisfy { selectedEquipment.contains($0) }
    }
    
    private func toggleHomeBasics() {
        let homeBasics: [Equipment] = [.dumbbell, .bands]
        
        if isHomeBasicsSelected() {
            selectedEquipment.removeAll { homeBasics.contains($0) }
        } else {
            for equipment in homeBasics {
                if !selectedEquipment.contains(equipment) {
                    selectedEquipment.append(equipment)
                }
            }
        }
    }
    
    private func toggleFullGym() {
        let gymEquipment: [Equipment] = [.barbell, .cable, .dumbbell, .machine]
        
        if isFullGymSelected() {
            selectedEquipment.removeAll { gymEquipment.contains($0) }
        } else {
            for equipment in gymEquipment {
                if !selectedEquipment.contains(equipment) {
                    selectedEquipment.append(equipment)
                }
            }
        }
    }

    
    private func equipmentRecommendation() -> String {
        if selectedEquipment.isEmpty {
            return "You've selected no equipment. We'll create a bodyweight-focused program for you."
        } else if selectedEquipment.count < 3 {
            return "With minimal equipment, we'll design a creative program that maximizes your available tools."
        } else if selectedEquipment.contains(.barbell) {
            return "You have access to comprehensive strength equipment. We'll create a well-rounded program with focus on compound movements."
        } else if selectedEquipment.contains(.dumbbell) && !selectedEquipment.contains(.barbell) {
            return "With dumbbells as your primary equipment, we'll focus on balanced development with varied exercises."
        } else {
            return "Based on your selection, we'll create a customized program that makes the most of your available equipment."
        }
    }
}

struct EquipmentCardModern: View {
    let equipment: Equipment
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    
                    equipment.image
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 50, maxHeight: 50)
                        .foregroundColor(isSelected ? Color.theme.accent : .primary)
                }
                
                Text(equipment.rawValue.capitalized)
                    .font(.caption)
                    .foregroundColor(isSelected ? Color.theme.accent : .primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(height: 30)
            }
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.theme.accent.opacity(0.1) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.theme.accent : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct QuickSelectButton: View {
    let title: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isActive ? .white : Color.theme.accent)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isActive ? Color.theme.accent : Color.theme.accent.opacity(0.1))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct IntegrationsView: View {
    @Binding var connectToHealthKit: Bool
    @Binding var notificationsEnabled: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                Text("Final Setup")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                
                Text("Enhance your experience with these integrations")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // HealthKit integration
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                            .font(.title2)
                        
                        Text("Apple Health Integration")
                            .font(.headline)
                        
                        Spacer()
                        
                        Toggle("", isOn: $connectToHealthKit)
                            .labelsHidden()
                    }
                    
                    Text("Sync your workout data with Apple Health to keep all your fitness information in one place. This allows SupaSet to read activity data and write workout results.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if connectToHealthKit {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("We'll sync:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            ForEach(["Active Energy", "Workout Data", "Weight", "Steps"], id: \.self) { item in
                                HStack(spacing: 10) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.caption)
                                    
                                    Text(item)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.gray.opacity(0.05)))
                .padding(.horizontal)
                
                // Notifications setup
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.orange)
                            .font(.title2)
                        
                        Text("Workout Reminders")
                            .font(.headline)
                        
                        Spacer()
                        
                        Toggle("", isOn: $notificationsEnabled)
                            .labelsHidden()
                    }
                    
                    Text("Get timely reminders for your scheduled workouts and updates on your progress towards goals.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if notificationsEnabled {
                        NotificationPreferencesView()
                            .padding(.top, 5)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.gray.opacity(0.05)))
                .padding(.horizontal)
                
                // Privacy information
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                        
                        Text("Privacy & Data")
                            .font(.headline)
                    }
                    
                    Text("Your data stays on your device. We don't collect personal information and any synced data is only used to provide app functionality.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button {
                        // Action for privacy policy
                    } label: {
                        Text("View Privacy Policy")
                            .font(.caption)
                            .foregroundColor(Color.theme.accent)
                            .padding(.top, 5)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.gray.opacity(0.05)))
                .padding(.horizontal)
                
                // Almost there message
                VStack(spacing: 15) {
                    Image(systemName: "party.popper.fill")
                        .font(.largeTitle)
                        .foregroundColor(Color.theme.accent)
                    
                    Text("You're Almost There!")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text("On the next screen, you'll see a summary of your profile before we finalize your setup.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.theme.accent.opacity(0.1))
                )
                .padding(.horizontal)
            }
            .padding(.bottom, 30)
        }
    }
}

struct NotificationPreferencesView: View {
    @State private var workoutReminders = true
    @State private var progressUpdates = true
    @State private var inactivityAlerts = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Toggle("Workout reminders", isOn: $workoutReminders)
                .font(.subheadline)
            
            Toggle("Weekly progress updates", isOn: $progressUpdates)
                .font(.subheadline)
            
            Toggle("Inactivity alerts", isOn: $inactivityAlerts)
                .font(.subheadline)
        }
    }
}

struct ProfileSummaryView: View {
    let name: String
    let age: Int
    let gender: Gender
    let height: Double
    let weight: Double
    let bodyFatPercentage: Double?
    let fitnessGoal: FitnessGoal
    let experienceLevel: ExperienceLevel
    let trainingDaysPerWeek: Int
    let sessionDuration: Int
    let selectedEquipment: [Equipment]
    let connectToHealthKit: Bool
    let notificationsEnabled: Bool
    let onComplete: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color.theme.accent)
                    
                    Text("Profile Summary")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Here's your personalized fitness profile")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Basic info
                SummarySection(title: "Personal Info", icon: "person.fill") {
                    SummaryRow(label: "Name", value: name)
                    SummaryRow(label: "Age", value: "\(age) years")
                    SummaryRow(label: "Gender", value: gender.rawValue.capitalized)
                }
                
                // Physiology
                SummarySection(title: "Physiology", icon: "waveform.path.ecg") {
                    SummaryRow(label: "Height", value: "\(Int(height)) cm")
                    SummaryRow(label: "Weight", value: "\(Int(weight)) kg")
                    SummaryRow(label: "BMI", value: String(format: "%.1f", weight / (height/100 * height/100)))
                    
                    if let bodyFat = bodyFatPercentage {
                        SummaryRow(label: "Body Fat", value: "\(Int(bodyFat))%")
                    }
                }
                
                // Training
                SummarySection(title: "Training Profile", icon: "figure.strengthtraining.traditional") {
                    SummaryRow(label: "Fitness Goal", value: fitnessGoal.rawValue.capitalized)
                    SummaryRow(label: "Experience", value: experienceLevel.rawValue.capitalized)
                    SummaryRow(label: "Training Days", value: "\(trainingDaysPerWeek) days per week")
                    SummaryRow(label: "Session Duration", value: "\(sessionDuration) minutes")
                    SummaryRow(label: "Weekly Volume", value: "\(trainingDaysPerWeek * sessionDuration) minutes")
                }
                
                // Equipment
                SummarySection(title: "Equipment Access", icon: "dumbbell.fill") {
                    if selectedEquipment.isEmpty {
                        Text("No equipment selected (bodyweight only)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 10) {
                            ForEach(selectedEquipment, id: \.self) { equipment in
                                VStack {
                                    equipment.image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 24)
                                        .foregroundColor(Color.theme.accent)
                                    
                                    Text(equipment.rawValue.capitalized)
                                        .font(.caption)
                                        .lineLimit(1)
                                }
                                .padding(.vertical, 5)
                            }
                        }
                    }
                }
                
                // Integrations
                SummarySection(title: "Integrations", icon: "link") {
                    Toggle("Apple Health Integration", isOn: .constant(connectToHealthKit))
                        .disabled(true)
                    
                    Toggle("Workout Reminders", isOn: .constant(notificationsEnabled))
                        .disabled(true)
                }
                
                // Recommendations preview
                VStack(alignment: .leading, spacing: 15) {
                    Text("Recommendations Preview")
                        .font(.headline)
                    
                    Text("Based on your profile, we've created:")
                        .font(.subheadline)
                    
                    VStack(spacing: 12) {
                        RecommendationRow(
                            icon: "calendar",
                            title: "Training Split",
                            description: generateTrainingSplitRecommendation()
                        )
                        
                        RecommendationRow(
                            icon: "chart.bar.fill",
                            title: "Volume Guide",
                            description: generateVolumeRecommendation()
                        )
                        
                        RecommendationRow(
                            icon: "trophy.fill",
                            title: "Goal Tracking",
                            description: "We'll track key metrics aligned with your \(fitnessGoal.rawValue) goal"
                        )
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.theme.accent.opacity(0.1))
                    )
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.gray.opacity(0.05)))
                .padding(.horizontal)
                
                // Action buttons
                HStack(spacing: 15) {
                    Button(action: onEdit) {
                        HStack {
                            Image(systemName: "pencil")
                            Text("Edit")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.theme.accent, lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(Color.theme.accent)
                    
                    GradientButton(label: "Complete Setup", disabled: false) {
                        onComplete()
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
            }
            .padding(.bottom, 30)
        }
        .transition(.move(edge: .trailing))
    }
    
    private func generateTrainingSplitRecommendation() -> String {
        switch (trainingDaysPerWeek, experienceLevel) {
        case (1...2, _):
            return "Full body workouts to maximize training efficiency"
        case (3, .beginner):
            return "3-day full body split for balanced development"
        case (3, _):
            return "Push/Pull/Legs split focusing on major movement patterns"
        case (4, .beginner):
            return "Upper/Lower split repeated twice weekly"
        case (4, _):
            return "Upper/Lower or 4-day muscle group split"
        case (5, .beginner):
            return "Full body workout 3x and focused workouts 2x"
        case (5, _):
            return "5-day muscle group split with specialization days"
        case (6...7, .beginner):
            return "Push/Pull/Legs split repeated twice weekly"
        case (6...7, _):
            return "6-day specialized split with dedicated focus days"
        default:
            return "Customized split based on your availability"
        }
    }
    
    private func generateVolumeRecommendation() -> String {
        switch experienceLevel {
        case .beginner:
            return "10-12 sets per muscle group weekly with moderate intensity"
        case .intermediate:
            return "13-16 sets per muscle group weekly with progressive overload"
        case .advanced:
            return "16-20+ sets per muscle group with periodized intensity"
        }
    }
}

struct SummarySection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(Color.theme.accent)
                
                Text(title)
                    .font(.headline)
            }
            
            content
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.gray.opacity(0.05)))
        .padding(.horizontal)
    }
}

struct SummaryRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

struct RecommendationRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(Color.theme.accent)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Supporting Views

struct ImportDataView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Import From Health Apps")) {
                    ImportOptionRow(title: "Apple Health", icon: "heart.fill", iconColor: .red)
                    ImportOptionRow(title: "Fitbit", icon: "figure.walk", iconColor: .blue)
                    ImportOptionRow(title: "Garmin Connect", icon: "speedometer", iconColor: .green)
                }
                
                Section(header: Text("Import From File")) {
                    ImportOptionRow(title: "CSV Upload", icon: "doc.text", iconColor: .orange)
                    ImportOptionRow(title: "Scan Document", icon: "doc.viewfinder", iconColor: .purple)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Import Data")
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct ImportOptionRow: View {
    let title: String
    let icon: String
    let iconColor: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .font(.title3)
                .frame(width: 30)
            
            Text(title)
                .font(.body)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 5)
    }
}

struct WeeklyScheduleView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var trainingDays: Int
    @State private var selectedDays: [Weekday] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Select your preferred training days")
                    .font(.headline)
                
                ForEach(Weekday.allCases, id: \.self) { day in
                    WeekdayRow(
                        day: day,
                        isSelected: selectedDays.contains(day),
                        action: {
                            toggleDay(day)
                        }
                    )
                }
                
                Spacer()
                
                GradientButton(label: "Save Schedule", disabled: false) {
                    trainingDays = selectedDays.count
                    presentationMode.wrappedValue.dismiss()
                }
                .padding()
            }
            .padding()
            .navigationTitle("Weekly Schedule")
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                initializeSelectedDays()
            }
        }
    }
    
    private func initializeSelectedDays() {
        let defaultDays: [Weekday] = trainingDays == 3 ? [.monday, .wednesday, .friday] :
        trainingDays == 4 ? [.monday, .tuesday, .thursday, .friday] :
        trainingDays == 5 ? [.monday, .tuesday, .wednesday, .thursday, .friday] :
        Array(Weekday.allCases.prefix(trainingDays))
        
        selectedDays = defaultDays
    }
    
    private func toggleDay(_ day: Weekday) {
        if selectedDays.contains(day) {
            selectedDays.removeAll { $0 == day }
        } else {
            selectedDays.append(day)
        }
    }
}

struct WeekdayRow: View {
    let day: Weekday
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(day.rawValue)
                    .font(.body)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.theme.accent)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.theme.accent.opacity(0.1) : Color.gray.opacity(0.05))
            )
        }
        .buttonStyle(PlainButtonStyle())
        .foregroundColor(.primary)
    }
}

enum Weekday: String, CaseIterable {
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    case sunday = "Sunday"
}

enum EquipmentCategory: String, CaseIterable {
    case strength = "Strength"
    case cardio = "Cardio"
    case accessories = "Accessories"
    case machines = "Machines"
}

// MARK: - Supporting Components

struct GradientButton: View {
    let label: String
    let disabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    Group {
                        if disabled {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray)
                        } else {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    Color.theme.accent.gradient
                                )
                        }
                    }
                )
        }
        .disabled(disabled)
    }
}

// MARK: - Helper Extensions and Components

struct LottieView: View {
    let animationName: String
    
    var body: some View {
        // This is a placeholder for a Lottie animation
        // In a real app, you would integrate with Lottie
        ZStack {
            Circle()
                .fill(Color.theme.accent.opacity(0.1))
                .frame(width: 160, height: 160)
            
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 70))
                .foregroundColor(Color.theme.accent)
        }
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
            
            ZStack(alignment: alignment) {
                placeholder().opacity(shouldShow ? 1 : 0)
                self
            }
        }
}

