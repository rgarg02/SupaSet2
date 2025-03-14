import SwiftUI
import SwiftData
struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    
    // Add state for controlling the workout overlay
    @State private var showWorkoutOverlay: Bool = false
    @State private var hideWorkoutOverlay: Bool = false
    @State private var currentWorkout: Workout?
    @State private var hasActiveWorkout: Bool = false
    @State private var mainWindow: UIWindow?
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
        ZStack {
            Color.theme.background
            TabView {
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
            .universalOverlay(show: .constant(ongoingWorkout.isEmpty == false)) {
                NewWorkoutFAB(
                    showWorkoutOverlay: $showWorkoutOverlay,
                    currentWorkout: $currentWorkout
                )
            }
            .universalOverlay(show: $showWorkoutOverlay) {
                if let workout = currentWorkout {
                    ExpandableWorkout(show: $showWorkoutOverlay, workout: workout, mainWindow: $mainWindow)
                }
            }
            .onChange(of: showWorkoutOverlay) { oldValue, newValue in
                if !newValue {
                    // Reset mainWindow when workout is finished
                    if let mainWindow = mainWindow?.subviews.first {
                        UIView.animate(withDuration: 0.3) {
                            mainWindow.layer.cornerRadius = 0
                            mainWindow.transform = .identity
                        }
                    }
                }
            }
            .onAppear {
                if let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow {
                    mainWindow = window
                }
                
                if ongoingWorkout.isEmpty == false {
                    hasActiveWorkout = true
                    showWorkoutOverlay = true
                    currentWorkout = ongoingWorkout.first
                } else {
                    showWorkoutOverlay = false
                    hasActiveWorkout = false
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
