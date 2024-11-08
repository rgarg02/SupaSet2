import SwiftUI

struct ContentView: View {
    @State private var exerciseViewModel = ExerciseViewModel()
    @Environment(\.modelContext) var modelContext
    var body: some View {
        ZStack {
            Color.theme.background
                .ignoresSafeArea()
            TabView {
                HomePageView()
                    .tabItem { Image(systemName: "house") }
                WorkoutPageView()
                    .tabItem { Image(systemName: "dumbbell") }
                ProfilePageView()
                    .tabItem { Image(systemName: "person") }
                WorkoutHistoryView()
                    .tabItem {Image(systemName: "clock.arrow.circlepath")}
            }
            .environment(exerciseViewModel)
        }
        .onAppear{
            print(modelContext.sqliteCommand)
        }
    }
}

#Preview {
    let previewContainer = PreviewContainer.preview
    ContentView()
        .modelContainer(previewContainer.container)
}
