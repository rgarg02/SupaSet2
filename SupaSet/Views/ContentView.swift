import SwiftUI

struct ContentView: View {
    @State private var exerciseViewModel = ExerciseViewModel()
    
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
            }
            .environment(exerciseViewModel)
        }
    }
}

#Preview {
    ContentView()
}
