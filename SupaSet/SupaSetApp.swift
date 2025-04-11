//
//  SupaSetApp.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/5/24.
//

import SwiftUI
import SwiftData
import Firebase
import GoogleSignIn

@main
struct SupaSetApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let container: ModelContainer
    @State private var authenticationViewModel = AuthenticationViewModel()
    @State private var exerciseViewModel : ExerciseViewModel
    @State private var userManager = UserManager()
    init() {
        let schema = Schema([
            Workout.self,
            WorkoutExercise.self,
            ExerciseSet.self,
            ExerciseDetail.self,
            Template.self,
            TemplateExercise.self,
            TemplateExerciseSet.self,
            ExerciseEntity.self,
            UserProfile.self
        ])
        do {
            let storeURL = URL.documentsDirectory.appending(path: "SupaSet.sqlite")
            let config = ModelConfiguration(url: storeURL)
            container = try ModelContainer(for: schema, configurations: config)
            container.mainContext.undoManager = UndoManager()
            self.exerciseViewModel = ExerciseViewModel(modelContext: container.mainContext)
            WorkoutActivityManager.shared.setModelContext(container.mainContext)
        } catch {
            fatalError("Failed to configure SwiftData container.")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .onAppear {
                    authenticationViewModel.listenToAuthChanges()
                    AppContainer.shared.container = container
                }
                .modelContainer(container)
                .environment(exerciseViewModel)
                .environment(authenticationViewModel)
                .environment(userManager)
                .usesAlertController()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}
