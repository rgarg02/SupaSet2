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
//    init() {
//        let appearance = UITabBarAppearance()
//        
//        // Configure the shadow (separator) above the tab bar
//        appearance.shadowColor = .gray
//        
//        // You can also set the background color if needed
//        appearance.backgroundColor = UIColor(Color.theme.background)
//        
//        // Apply the appearance to both standard and scrollEdge appearances
//        UITabBar.appearance().standardAppearance = appearance
//        UITabBar.appearance().scrollEdgeAppearance = appearance
//    }
    
    var body: some View {
        NavigationStack{
            ZStack {
                TabView {
                    FeedView()
                        .tabItem {
                            Image(systemName: "house")
                            Text("Feed")
                        }
                    WorkoutPageView()
                        .tabItem({
                            Image(systemName: "dumbbell")
                            Text("Workout")
                        })
                    WorkoutHistoryView()
                        .tabItem {
                            Image(systemName: "calendar")
                            Text("History")
                        }
                    ProfilePageView()
                        .tabItem {
                            Image(systemName: "person")
                            Text("Profile")
                        }
                }
                .overlay(alignment: .bottom, content: {
                    if showWorkoutOverlay {
                        if let workout = currentWorkout {
                            NavigationStack {
                                ExpandableWorkout(show: $showWorkoutOverlay, workout: workout)
                            }
                            .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom).animation(.easeInOut(duration: 0.5))))
                            .background(.clear)
                        }
                    }
                    if showFAB {
                        NewWorkoutFAB(
                            currentWorkout: $currentWorkout
                        )
                        .background(.clear)
                    }
                })
                .animation(.easeInOut(duration: 0.5), value: showWorkoutOverlay)
                .animation(.smooth, value: currentWorkout)
                .animation(.smooth, value: showFAB)
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
#Preview {
    let previewContainer = PreviewContainer.preview
    ContentView()
        .modelContainer(previewContainer.container)
        .environment(previewContainer.viewModel)
        .environment(previewContainer.authViewModel)
}
struct BackgroundGradientView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color("PrimaryThemeColor").shade(50),    // Dark blue
                    Color("SecondaryThemeColor").shade(50)   // Deep purple
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Very subtle overlay to add minimal texture
            // This enhances the glass effect without being distracting
            ZStack {
                Rectangle()
                    .fill(Color.white.opacity(0.03))
                    .blendMode(.overlay)
            }
            .ignoresSafeArea()
            
        }
    }
}
#Preview {
    BackgroundGradientView()
}
