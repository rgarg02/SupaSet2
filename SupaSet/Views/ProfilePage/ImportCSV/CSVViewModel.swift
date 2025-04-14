//
//  CSVViewModel.swift
//  SupaSet
//
//  Created by Rishi Garg on 4/14/25.
//

import SwiftUI
import SwiftData
import Observation
import SwiftCSV // Ensure this library is correctly imported

@Observable
class CSVViewModel {
    // ... (Keep properties: content, errorMessage, modelContext, exerciseViewModel) ...
    var content: String = ""
    var errorMessage: String = ""
    private var modelContext: ModelContext
    private var exerciseViewModel: ExerciseViewModel

    // --- Date Formatters (As 'let' constants) ---
    private let hevyDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy, HH:mm" // Corrected year format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    private let strongDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    // --- Initializer ---
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.exerciseViewModel = ExerciseViewModel(modelContext: modelContext)
    }

    // --- File Handling (Keep as is) ---
    func handleFileImport(for result: Result<URL, Error>) {
         switch result {
         case .success(let url):
              Task { @MainActor in
                 if readFile(url) {
                     parseCSV(content: self.content)
                 }
             }
         case .failure(let error):
              Task { @MainActor in
                 errorMessage = "Error Importing CSV: \(error.localizedDescription)"
             }
         }
     }

    @MainActor
    @discardableResult
    private func readFile(_ url: URL) -> Bool {
         guard url.startAccessingSecurityScopedResource() else {
             errorMessage = "Error: Cannot access security-scoped resource."
             return false
         }
         defer { url.stopAccessingSecurityScopedResource() }

         do {
             let fileContent = try String(contentsOf: url, encoding: .utf8)
             self.content = fileContent
             self.errorMessage = ""
             print("Successfully read file: \(url.lastPathComponent)")
             return true
         } catch {
             errorMessage = "Error Reading CSV: \(error.localizedDescription)"
             self.content = ""
             return false
         }
     }
    // --- Date Parsing Helpers (Keep as is) ---
     private func parseHevyDate(_ dateString: String) -> Date? {
         return hevyDateFormatter.date(from: dateString)
     }

     private func parseStrongDate(_ dateString: String) -> Date? {
         return strongDateFormatter.date(from: dateString)
     }


    // --- CSV Parsing Main Function ---
    @MainActor
    func parseCSV(content: String) {
        guard !content.isEmpty else {
            errorMessage = "CSV content is empty."
            return
        }

        do {
            // *** Use NamedCSV variant ***
            let csv = try NamedCSV(string: content) // This loads header and allows row["Column"] access

            let header = csv.header // Get the header row

            // Detect CSV type based on headers
            if header.contains("start_time") && header.contains("exercise_title") {
                print("Detected Hevy CSV format.")
                // Pass the NamedCSV object directly
                parseHevyCSV(csv: csv)
            } else if header.contains("Workout Name") && header.contains("Exercise Name") {
                 print("Detected Strong CSV format.")
                 // Pass the NamedCSV object directly
                parseStrongCSV(csv: csv)
            } else {
                errorMessage = "Unknown CSV format. Headers do not match Hevy or Strong."
                print("Headers found: \(header)")
                return
            }

            try modelContext.save()
            print("CSV data parsed and saved successfully.")
            self.content = ""

        } catch let parseError as CSVParseError {
            errorMessage = "CSV Parsing Error: \(parseError)"
            print("CSV Parsing Error Details: \(parseError)")
        } catch {
            errorMessage = "Error processing CSV: \(error.localizedDescription)"
            print("Generic Processing Error: \(error)")
        }

        exerciseViewModel.addConfirmedExercisesToStore()
    }

    // --- Hevy CSV Parsing Logic (Using NamedCSV) ---
    @MainActor
    private func parseHevyCSV(csv: NamedCSV) { // <-- Takes NamedCSV
        var workouts: [String: Workout] = [:]
        for row in csv.rows {
            guard let title = row["title"], !title.isEmpty,
                  let startTimeStr = row["start_time"],
                  let exerciseTitle = row["exercise_title"], !exerciseTitle.isEmpty,
                  let setIndexStr = row["set_index"], let setIndex = Int(setIndexStr),
                  let setTypeStr = row["set_type"],
                  let weightStr = row["weight_lbs"],
                  let repsStr = row["reps"] else {
                print("Skipping Hevy row due to missing essential data: \(row)")
                continue
            }
            
            guard let startTime = parseHevyDate(startTimeStr) else {
                 print("Skipping Hevy row due to invalid start time format: \(startTimeStr)")
                 continue
             }
            // Use ?? "" before trimming/conversion for optional fields
            let endTime = parseHevyDate(row["end_time"] ?? "")
            let weight = Double(weightStr.trimmingCharacters(in: .whitespaces)) ?? 0.0
            let reps = Int(repsStr.trimmingCharacters(in: .whitespaces)) ?? 0
            let rpe = Double(row["rpe"]?.trimmingCharacters(in: .whitespaces) ?? "")
            let exerciseNotes = row["exercise_notes"]?.trimmingCharacters(in: .whitespaces)
            let workoutNotes = row["description"]?.trimmingCharacters(in: .whitespaces) ?? ""

            var exerciseSetType: SetType = .working
            switch setTypeStr.lowercased() {
                 case "normal": exerciseSetType = .working
                 case "warmup": exerciseSetType = .warmup
                 case "failure": exerciseSetType = .failure
                 case "dropset": exerciseSetType = .drop
                 default: break
             }

            let workoutKey = "\(title)-\(startTimeStr)"
            var currentWorkout: Workout

            if let existingWorkout = workouts[workoutKey] {
                 currentWorkout = existingWorkout
                 if let newEndTime = endTime, let currentEndTime = currentWorkout.endTime, newEndTime > currentEndTime {
                     currentWorkout.endTime = newEndTime
                 } else if currentWorkout.endTime == nil {
                     currentWorkout.endTime = endTime
                 }
                  if !workoutNotes.isEmpty && currentWorkout.notes.isEmpty {
                     currentWorkout.notes = workoutNotes
                 }
            } else {
                currentWorkout = Workout(name: title, date: startTime, endTime: endTime, isFinished: true, notes: workoutNotes)
                modelContext.insert(currentWorkout)
                print("Created new Hevy workout: \(title) - \(startTime)")
                workouts[workoutKey] = currentWorkout
            }
            
            let exerciseEntityId = exerciseViewModel.findOrCreateExerciseID(for: exerciseTitle)
            var currentWorkoutExercise: WorkoutExercise
            currentWorkoutExercise = WorkoutExercise(exerciseID: exerciseEntityId, order: currentWorkout.exercises.count, notes: exerciseNotes)
            currentWorkout.exercises.append(currentWorkoutExercise)
            print("Added exercise '\(exerciseTitle)' to workout '\(title)'")
            
            if !currentWorkoutExercise.sets.contains(where: { $0.order == setIndex }) {
                let exerciseSet = ExerciseSet(
                    reps: reps,
                    weight: weight,
                    type: exerciseSetType,
                    rpe: rpe,
                    notes: nil,
                    order: setIndex,
                    isDone: true
                )
                currentWorkoutExercise.sets.append(exerciseSet)
                print("Added set \(setIndex + 1) to exercise '\(exerciseTitle)'")
            } else {
                print("Skipping duplicate set index \(setIndex) for exercise '\(exerciseTitle)' in workout '\(title)'")
            }
            modelContext.insert(currentWorkout)
        }
    }

    // --- Strong CSV Parsing Logic (Using NamedCSV) ---
    @MainActor
    private func parseStrongCSV(csv: NamedCSV) { // <-- Takes NamedCSV
        var workouts: [String: Workout] = [:]
        var currentWorkoutExercises: [String: WorkoutExercise] = [:]

        // *** Iterate through rows using dictionary access ***
        for row in csv.rows {
             guard let dateStr = row["Date"],
                   let workoutName = row["Workout Name"], !workoutName.isEmpty,
                   let exerciseName = row["Exercise Name"], !exerciseName.isEmpty,
                   let setOrderStr = row["Set Order"], let setOrder = Int(setOrderStr),
                   let weightStr = row["Weight"],
                   let repsStr = row["Reps"] else {
                 print("Skipping Strong row due to missing essential data: \(row)")
                 continue
             }

             guard let workoutDate = parseStrongDate(dateStr) else {
                  print("Skipping Strong row due to invalid date format: \(dateStr)")
                  continue
              }
             let weight = Double(weightStr.trimmingCharacters(in: .whitespaces)) ?? 0.0
             let reps = Int(repsStr.trimmingCharacters(in: .whitespaces)) ?? 0
             let rpe = Double(row["RPE"]?.trimmingCharacters(in: .whitespaces) ?? "")
             let setNotes = row["Notes"]?.trimmingCharacters(in: .whitespaces)
             let workoutNotes = row["Workout Notes"]?.trimmingCharacters(in: .whitespaces) ?? ""
             let exerciseSetType: SetType = .working

             let workoutKey = "\(workoutName)-\(dateStr)"
             var currentWorkout: Workout

             if let existingWorkout = workouts[workoutKey] {
                 currentWorkout = existingWorkout
                  if !workoutNotes.isEmpty && currentWorkout.notes.isEmpty {
                     currentWorkout.notes = workoutNotes
                 }
             } else {
                 currentWorkoutExercises = [:] // Clear cache for new workout

                  let predicate = #Predicate<Workout> { $0.name == workoutName && $0.date == workoutDate }
                 let fetchDescriptor = FetchDescriptor<Workout>(predicate: predicate)
                 if let fetchedWorkout = try? modelContext.fetch(fetchDescriptor).first {
                     currentWorkout = fetchedWorkout
                     print("Found existing Strong workout in SwiftData: \(workoutName) - \(workoutDate)")
                     if !workoutNotes.isEmpty && currentWorkout.notes.isEmpty { currentWorkout.notes = workoutNotes }
                      fetchedWorkout.exercises.forEach { exercise in
                          currentWorkoutExercises[exercise.exerciseID] = exercise
                      }
                 } else {
                     currentWorkout = Workout(name: workoutName, date: workoutDate, isFinished: true, notes: workoutNotes)
                     modelContext.insert(currentWorkout)
                     print("Created new Strong workout: \(workoutName) - \(workoutDate)")
                 }
                 workouts[workoutKey] = currentWorkout
             }

            let exerciseEntityId = exerciseViewModel.findOrCreateExerciseID(for: exerciseName)
            var currentWorkoutExercise: WorkoutExercise

            if let existingWorkoutExercise = currentWorkoutExercises[exerciseEntityId] {
                 currentWorkoutExercise = existingWorkoutExercise
             } else {
                 currentWorkoutExercise = WorkoutExercise(exerciseID: exerciseEntityId, order: currentWorkout.exercises.count)
                 currentWorkout.exercises.append(currentWorkoutExercise)
                 currentWorkoutExercises[exerciseEntityId] = currentWorkoutExercise // Add to cache
                 print("Added exercise '\(exerciseName)' to workout '\(workoutName)'")
             }

             if !currentWorkoutExercise.sets.contains(where: { $0.order == setOrder - 1 }) {
                 let exerciseSet = ExerciseSet(
                     reps: reps,
                     weight: weight,
                     type: exerciseSetType,
                     rpe: rpe,
                     notes: (setNotes != nil && !setNotes!.isEmpty) ? setNotes : nil,
                     order: setOrder - 1, // Convert 1-based to 0-based
                     isDone: true
                 )
                 currentWorkoutExercise.sets.append(exerciseSet)
                 print("Added set \(setOrder) to exercise '\(exerciseName)'")
            } else {
                  print("Skipping duplicate set order \(setOrder) for exercise '\(exerciseName)' in workout '\(workoutName)'")
              }
        }
         workouts.values.forEach { workout in
             workout.exercises.forEach { $0.reorderSets() }
             // Optional: reorder exercises within workout if needed
         }
    }
}

// --- Keep the Collection safe subscript helper ---
extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// Make sure reorderSets() is defined in your WorkoutExercise model extension
// (Likely already in Model/SwiftDataModels/Extensions/Execise+.swift)
