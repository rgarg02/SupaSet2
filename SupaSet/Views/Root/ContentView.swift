import SwiftUI
import SwiftData
struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(AuthenticationViewModel.self) var authViewModel
    // Add state for controlling the workout overlay
    @State private var showWorkoutOverlay: Bool = false
    @State private var hideWorkoutOverlay: Bool = false
    @State private var currentWorkout: Workout?
    @State private var showFAB: Bool = false
    @Query(filter: #Predicate<Workout>{$0.isFinished == false}) private var ongoingWorkout: [Workout]
    init() {
        let appearance = UITabBarAppearance()
        
        // Configure the shadow (separator) above the tab bar
        appearance.shadowColor = .gray
        
        // You can also set the background color if needed
        appearance.backgroundColor = UIColor(Color.theme.background)
        
        // Apply the appearance to both standard and scrollEdge appearances
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background
                TabView {
                    WorkoutPageView()
                        .tabItem({
                            Image(systemName: "dumbbell")
                            Text("Workout")
                        })
                        .safeAreaPadding(.bottom, 55)
                    WorkoutHistoryView()
                        .tabItem {
                            Image(systemName: "calendar")
                            Text("History")
                        }
                        .safeAreaPadding(.bottom, 55)
                    ProfilePageView()
                        .tabItem {
                            Image(systemName: "person")
                            Text("Profile")
                        }
                        .safeAreaPadding(.bottom, 55)
                }
                .overlay(alignment: .bottom, content: {
                    if showWorkoutOverlay {
                        if let workout = currentWorkout {
                            ExpandableWorkout(show: $showWorkoutOverlay, workout: workout)
                        }
                    }
                    if showFAB {
                        NewWorkoutFAB(
                            currentWorkout: $currentWorkout
                        )
                    }
                })
                .onChange(of: ongoingWorkout) { oldValue, newValue in
                    if newValue.isEmpty {
                        // No active workout
                        showWorkoutOverlay = false
                        currentWorkout = nil
                        showFAB = true
                    } else {
                        // Has active workout
                        showWorkoutOverlay = true
                        showFAB = false
                        currentWorkout = newValue.first
                    }
                }
                .onAppear {
                    
                    // Initial state setup
                    if !ongoingWorkout.isEmpty {
                        showWorkoutOverlay = true
                        showFAB = false
                        currentWorkout = ongoingWorkout.first
                    } else {
                        showWorkoutOverlay = false
                        showFAB = true
                        currentWorkout = nil
                    }
                }
            }
        }
    }
}
//#Preview {
//    let previewContainer = PreviewContainer.preview
//    ContentView()
//        .modelContainer(previewContainer.container)
//}
