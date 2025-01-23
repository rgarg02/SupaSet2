//
//  MenuButtons.swift
//  SupaSet
//
//  Created by Rishi Garg on 12/24/24.
//
import SwiftUI
import SwiftData
struct MenuButtons: View {
    @Binding var changeExercise: Bool
    @Binding var deleteExercise: Bool
    let exerciseID: String
    @Query private var exerciseDetails: [ExerciseDetail]
    init(exerciseID: String, changeExercise: Binding<Bool>, deleteExercise: Binding<Bool>) {
        self.exerciseID = exerciseID
        self._changeExercise = changeExercise
        self._deleteExercise = deleteExercise
        _exerciseDetails = Query(filter: #Predicate<ExerciseDetail> {
            $0.exerciseID == exerciseID
        })
    }
    @Environment(\.alertController) private var alertController
    @Environment(ExerciseViewModel.self) private var viewModel
    var body: some View {
        VStack {
            Button{
                withAnimation(.easeInOut(duration: 0.3)) {  // Added specific duration
                    changeExercise = true
                }
            } label: {
                HStack{
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .foregroundColor(.theme.accent)
                    Text("Change Exercise")
                        .bold()
                    Spacer()
                }
            }
            if let exerciseDetail = exerciseDetails.first{
                NavigationLink{
                    ChangeUnitView(exerciseDetail: exerciseDetail)
                }label: {
                    HStack{
                        Image(systemName: "scalemass")
                            .foregroundColor(.theme.accent)
                        Text("Change Units")
                            .bold()
                        Spacer()
                    }
                }
                .padding(.vertical, 5)
                NavigationLink {
                    RestTimerView(exerciseDetail: exerciseDetail)
                } label: {
                    HStack{
                        Image(systemName: "timer")
                            .foregroundColor(.theme.accent)
                        Text("Auto Rest Timer")
                            .bold()
                        Spacer()
                        RestTimerDisplay(exerciseDetail: exerciseDetail)
                        Image(systemName: "chevron.right")
                            .foregroundColor(.theme.accent)
                    }
                }
                .padding(.vertical, 5)
            }
            Button{
                deleteExercise.toggle()
            } label: {
                HStack{
                    Image(systemName: "trash")
                        .foregroundColor(.cancel)
                    Text("Delete Exercise")
                        .bold()
                    Spacer()
                }
            }
            Spacer()
        }
    }
}
