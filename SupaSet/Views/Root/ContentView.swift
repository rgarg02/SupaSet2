import SwiftUI
struct ContentView: View {
    @Environment(\.modelContext) var modelContext
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
//                HomePageView()
//                    .tabItem { Image(systemName: "house") }
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
        }
    }
}
//#Preview {
//    let previewContainer = PreviewContainer.preview
//    ContentView()
//        .modelContainer(previewContainer.container)
//}
