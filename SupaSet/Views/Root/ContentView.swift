import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    var body: some View {
        ZStack {
            Color.theme.background
                .ignoresSafeArea()
            TabView {
//                HomePageView()
//                    .tabItem { Image(systemName: "house") }
                WorkoutPageView()
                    .tabItem { Image(systemName: "dumbbell") }
                WorkoutHistoryView()
                    .tabItem {Image(systemName: "clock.arrow.circlepath")}
                ProfilePageView()
                    .tabItem { Image(systemName: "person") }
            }
        }
    }
}
//#Preview {
//    let previewContainer = PreviewContainer.preview
//    ContentView()
//        .modelContainer(previewContainer.container)
//}
