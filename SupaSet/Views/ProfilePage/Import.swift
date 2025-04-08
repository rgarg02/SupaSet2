//
//  Import.swift
//  SupaSet
//
//  Created by Rishi Garg on 3/1/25.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

enum ImportStage: Equatable {
    case readingFile
    case parsingCSV
    case processingWorkouts(current: Int, total: Int)
    case savingData
}

extension String {
    /// Converts a duration string in format "Xh Ym Zs" to TimeInterval (seconds)
    /// - Returns: TimeInterval in seconds, or nil if parsing fails
    func toTimeInterval() -> TimeInterval? {
        // Handle empty string
        guard !self.isEmpty else { return nil }
        
        // Extract hours, minutes, and seconds using regular expressions
        var totalSeconds: TimeInterval = 0
        
        // Extract hours
        if let hourRange = self.range(of: #"(\d+)\s*h"#, options: .regularExpression) {
            let hourString = self[hourRange].replacingOccurrences(of: "h", with: "").trimmingCharacters(in: .whitespaces)
            if let hours = Double(hourString) {
                totalSeconds += hours * 3600
            }
        }
        
        // Extract minutes
        if let minuteRange = self.range(of: #"(\d+)\s*m"#, options: .regularExpression) {
            let minuteString = self[minuteRange].replacingOccurrences(of: "m", with: "").trimmingCharacters(in: .whitespaces)
            if let minutes = Double(minuteString) {
                totalSeconds += minutes * 60
            }
        }
        
        // Extract seconds
        if let secondRange = self.range(of: #"(\d+)\s*s"#, options: .regularExpression) {
            let secondString = self[secondRange].replacingOccurrences(of: "s", with: "").trimmingCharacters(in: .whitespaces)
            if let seconds = Double(secondString) {
                totalSeconds += seconds
            }
        }
        
        // If no time components were found, try parsing as a plain number
        if totalSeconds == 0 && !self.contains("h") && !self.contains("m") && !self.contains("s") {
            if let seconds = Double(self.trimmingCharacters(in: .whitespaces)) {
                totalSeconds = seconds
            }
        }
        
        return totalSeconds > 0 ? totalSeconds : nil
    }
}

enum ImportStatus: Equatable {
    case notStarted
    case importing(progress: Double, stage: ImportStage)
    case mappingExercises
    case completed
    case failed(error: String)
    
    var description: String {
        switch self {
        case .notStarted:
            return ""
        case .importing(_, let stage):
            switch stage {
            case .readingFile:
                return "Reading file..."
            case .parsingCSV:
                return "Parsing CSV data..."
            case .processingWorkouts(let current, let total):
                return "Processing workout \(current) of \(total)..."
            case .savingData:
                return "Saving workouts..."
            }
        case .mappingExercises:
            return "Review new exercises"
        case .completed:
            return "Import completed"
        case .failed(let error):
            return error
        }
    }
}

extension ImportStatus {
    var isInProgress: Bool {
        switch self {
        case .importing, .mappingExercises:
            return true
        default:
            return false
        }
    }
}
// Strong CSV Row Structure
struct StrongCSVRow {
    let date: Date
    let workoutName: String
    let duration: String
    let exerciseName: String
    let setOrder: Int
    let weight: Double
    let reps: Int
    let notes: String?
    let workoutNotes: String?
    let rpe: Double?
}

// Hevy CSV Row Structure
struct HevyCSVRow {
    let title: String
    let startTime: Date
    let endTime: Date
    let description: String?
    let exerciseTitle: String
    let exerciseNotes: String?
    let setIndex: Int
    let setType: String
    let weightLbs: Double
    let reps: Int
    let rpe: Double?
}

enum DataFrom {
    case strong
    case hevy
}

@MainActor
struct CSVImportView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ExerciseViewModel.self) private var exerciseViewModel
    @State private var showingPicker = false
    @State private var importStatus: ImportStatus = .notStarted
    @State private var dataFrom: DataFrom = .strong
    @State private var showExerciseMappingView: Bool = false
    private let quotesCharacterSet = CharacterSet(charactersIn: "\"'")
    
    // Date formatters
    private let strongDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    private let hevyDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy, HH:mm"
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Button("Import Workout Data from Strong") {
                showingPicker = true
                dataFrom = .strong
            }
            .buttonStyle(.plain)
            .disabled(importStatus.isInProgress)
            
            Button("Import Workout Data from Hevy") {
                showingPicker = true
                dataFrom = .hevy
            }
            .buttonStyle(.plain)
            .disabled(importStatus.isInProgress)
            
            statusView
        }
        .padding()
        .animation(.smooth, value: importStatus)
        .fileImporter(
            isPresented: $showingPicker,
            allowedContentTypes: [.commaSeparatedText]
        ) { result in
            Task {
                await handleFileImport(result)
            }
        }
        .sheet(isPresented: $showExerciseMappingView) {
               ExerciseMappingView(onComplete: {
                   importStatus = .completed
               })
           }
    }
    
    @ViewBuilder
    private var statusView: some View {
        switch importStatus {
        case .notStarted:
            EmptyView()
            
        case .importing(let progress, _):
            VStack(spacing: 10) {
                ProgressView(value: progress)
                    .progressViewStyle(.linear)
                    .animation(.smooth, value: progress)
                
                Text(importStatus.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .transition(.opacity)
            
        case .mappingExercises:
            if !exerciseViewModel.newExercises.isEmpty {
                Button("Review \(exerciseViewModel.newExercises.count) New Exercises") {
                    showExerciseMappingView = true
                }
                .buttonStyle(.borderedProminent)
                .transition(.scale.combined(with: .opacity))
            } else {
                Label("Import completed", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .transition(.scale.combined(with: .opacity))
                    .onAppear {
                        // Reset status after a brief moment
                        Task { @MainActor in
                            try? await Task.sleep(for: .seconds(2))
                            importStatus = .notStarted
                        }
                    }
            }
            
        case .completed:
            Label("Import completed", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .transition(.scale.combined(with: .opacity))
                .onAppear {
                    // Reset status after a brief moment
                    Task { @MainActor in
                        try? await Task.sleep(for: .seconds(2))
                        importStatus = .notStarted
                    }
                }
            
        case .failed(let error):
            Label(error, systemImage: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
                .transition(.scale.combined(with: .opacity))
        }
    }
    
    private func handleFileImport(_ result: Result<URL, Error>) async {
        switch result {
        case .success(let file):
            await importCSV(from: file)
        case .failure(let error):
            importStatus = .failed(error: "Failed to import file: \(error.localizedDescription)")
        }
    }
    
    private func importCSV(from file: URL) async {
        guard file.startAccessingSecurityScopedResource() else {
            importStatus = .failed(error: "Cannot access file")
            return
        }
        defer { file.stopAccessingSecurityScopedResource() }
        
        do {
            importStatus = .importing(progress: 0.1, stage: .readingFile)
            let content = try Data(contentsOf: file)
            let contentString = String(decoding: content, as: UTF8.self)
            
            importStatus = .importing(progress: 0.2, stage: .parsingCSV)
            
            // Check which type of file we're processing based on headers
            let firstLine = contentString.components(separatedBy: .newlines).first ?? ""
            let isHevyFile = firstLine.contains("title") && firstLine.contains("start_time") ||
            firstLine.contains("exercise_title") && firstLine.contains("set_index")
            
            if isHevyFile && dataFrom == .strong {
                // User selected Strong but the file is Hevy format
                dataFrom = .hevy
            } else if !isHevyFile && dataFrom == .hevy {
                // User selected Hevy but the file is Strong format
                dataFrom = .strong
            }
            
            switch dataFrom {
            case .strong:
                let rows = await parseCSVFromStrong(contentString)
                await processStrongWorkouts(from: rows)
            case .hevy:
                let rows = await parseCSVFromHevy(contentString)
                await processHevyWorkouts(from: rows)
            }
            
            importStatus = .importing(progress: 0.95, stage: .savingData)
            
            try modelContext.save()
            
            // Instead of adding new exercises automatically, go to the mapping stage
            importStatus = .mappingExercises
            
        } catch {
            importStatus = .failed(error: "Error processing file: \(error.localizedDescription)")
        }
    }
    // MARK: - Strong CSV Parsing
    
    private func parseCSVFromStrong(_ content: String) async -> [StrongCSVRow] {
        await withTaskGroup(of: [StrongCSVRow].self) { group in
            let lines = content.components(separatedBy: .newlines)
                .filter { !$0.isEmpty }
            
            guard lines.count > 1 else { return [] }
            
            // Get column indices from header
            let headerFields = parseCSVLine(lines[0])
            let dateIndex = headerFields.firstIndex(of: "Date") ?? 0
            let workoutNameIndex = headerFields.firstIndex(of: "Workout Name") ?? 1
            let durationIndex = headerFields.firstIndex(of: "Duration") ?? 2
            let exerciseNameIndex = headerFields.firstIndex(of: "Exercise Name") ?? 3
            let setOrderIndex = headerFields.firstIndex(of: "Set Order") ?? 4
            let weightIndex = headerFields.firstIndex(of: "Weight") ?? 5
            let repsIndex = headerFields.firstIndex(of: "Reps") ?? 6
            let notesIndex = headerFields.firstIndex(of: "Notes") ?? 9
            let workoutNotesIndex = headerFields.firstIndex(of: "Workout Notes") ?? 10
            let rpeIndex = min(headerFields.count - 1, headerFields.firstIndex(of: "RPE") ?? 11)
            
            // Process lines in chunks
            let chunkSize = 500
            let chunks = stride(from: 1, to: lines.count, by: chunkSize).map {
                Array(lines[$0..<min($0 + chunkSize, lines.count)])
            }
            
            for chunk in chunks {
                group.addTask {
                    return chunk.compactMap { line -> StrongCSVRow? in
                        let fields = parseCSVLine(line)
                        guard fields.count >= max(dateIndex, workoutNameIndex, durationIndex, exerciseNameIndex, setOrderIndex, weightIndex, repsIndex) + 1 else {
                            return nil
                        }
                        
                        // Parse date
                        guard let date = strongDateFormatter.date(from: fields[dateIndex]) else { return nil }
                        
                        // Parse numeric values
                        guard let setOrder = Int(fields[setOrderIndex]),
                              let weight = Double(fields[weightIndex].isEmpty ? "0" : fields[weightIndex]),
                              let reps = Int(fields[repsIndex].isEmpty ? "0" : fields[repsIndex]) else {
                            return nil
                        }
                        
                        // Parse optional RPE
                        let rpe: Double?
                        if fields.count > rpeIndex, !fields[rpeIndex].isEmpty {
                            rpe = Double(fields[rpeIndex])
                        } else {
                            rpe = nil
                        }
                        
                        return StrongCSVRow(
                            date: date,
                            workoutName: fields[workoutNameIndex],
                            duration: fields[durationIndex],
                            exerciseName: fields[exerciseNameIndex],
                            setOrder: setOrder,
                            weight: weight,
                            reps: reps,
                            notes: fields.count > notesIndex && !fields[notesIndex].isEmpty ? fields[notesIndex] : nil,
                            workoutNotes: fields.count > workoutNotesIndex && !fields[workoutNotesIndex].isEmpty ? fields[workoutNotesIndex] : nil,
                            rpe: rpe
                        )
                    }
                }
            }
            
            var allRows: [StrongCSVRow] = []
            for await rows in group {
                allRows.append(contentsOf: rows)
            }
            
            return allRows
        }
    }
    
    // MARK: - Hevy CSV Parsing
    
    private func parseCSVFromHevy(_ content: String) async -> [HevyCSVRow] {
        await withTaskGroup(of: [HevyCSVRow].self) { group in
            let lines = content.components(separatedBy: .newlines)
                .filter { !$0.isEmpty }
            
            guard lines.count > 1 else { return [] }
            
            // Get column indices from header
            let headerFields = parseCSVLine(lines[0])
            let titleIndex = headerFields.firstIndex(of: "title") ?? 0
            let startTimeIndex = headerFields.firstIndex(of: "start_time") ?? 1
            let endTimeIndex = headerFields.firstIndex(of: "end_time") ?? 2
            let descriptionIndex = headerFields.firstIndex(of: "description") ?? 3
            let exerciseTitleIndex = headerFields.firstIndex(of: "exercise_title") ?? 4
            let exerciseNotesIndex = headerFields.firstIndex(of: "exercise_notes") ?? 6
            let setIndexIndex = headerFields.firstIndex(of: "set_index") ?? 7
            let setTypeIndex = headerFields.firstIndex(of: "set_type") ?? 8
            let weightIndex = headerFields.firstIndex(of: "weight_lbs") ?? 9
            let repsIndex = headerFields.firstIndex(of: "reps") ?? 10
            let rpeIndex = headerFields.firstIndex(of: "rpe") ?? 13
            
            // Process lines in chunks
            let chunkSize = 500
            let chunks = stride(from: 1, to: lines.count, by: chunkSize).map {
                Array(lines[$0..<min($0 + chunkSize, lines.count)])
            }
            
            for chunk in chunks {
                group.addTask {
                    return chunk.compactMap { line -> HevyCSVRow? in
                        let fields = parseCSVLine(line)
                        
                        // Check if we have enough fields
                        guard fields.count >= max(titleIndex, startTimeIndex, exerciseTitleIndex, setIndexIndex, weightIndex, repsIndex) + 1 else {
                            return nil
                        }
                        
                        // Parse dates with fallback
                        guard let startTime = parseHevyDate(fields[startTimeIndex]) else { return nil }
                        let endTime = fields.count > endTimeIndex ? parseHevyDate(fields[endTimeIndex]) ?? startTime : startTime
                        
                        // Parse numeric values
                        guard let setIndex = Int(fields[setIndexIndex]),
                              let weight = Double(fields.count > weightIndex && !fields[weightIndex].isEmpty ? fields[weightIndex] : "0"),
                              let reps = Int(fields.count > repsIndex && !fields[repsIndex].isEmpty ? fields[repsIndex] : "0") else {
                            return nil
                        }
                        
                        // Get set type with default
                        let setType = fields.count > setTypeIndex ? fields[setTypeIndex] : "normal"
                        
                        // Parse optional RPE
                        let rpe: Double?
                        if fields.count > rpeIndex, !fields[rpeIndex].isEmpty, fields[rpeIndex] != "null" {
                            rpe = Double(Double(fields[rpeIndex]) ?? 0)
                        } else {
                            rpe = nil
                        }
                        
                        return HevyCSVRow(
                            title: fields[titleIndex],
                            startTime: startTime,
                            endTime: endTime,
                            description: fields.count > descriptionIndex && !fields[descriptionIndex].isEmpty && fields[descriptionIndex] != "null" ? fields[descriptionIndex] : nil,
                            exerciseTitle: fields[exerciseTitleIndex],
                            exerciseNotes: fields.count > exerciseNotesIndex && !fields[exerciseNotesIndex].isEmpty && fields[exerciseNotesIndex] != "null" ? fields[exerciseNotesIndex] : nil,
                            setIndex: setIndex,
                            setType: setType,
                            weightLbs: weight,
                            reps: reps,
                            rpe: rpe
                        )
                    }
                }
            }
            
            var allRows: [HevyCSVRow] = []
            for await rows in group {
                allRows.append(contentsOf: rows)
            }
            
            return allRows
        }
    }
    
    // MARK: - Process Strong Workouts
    
    private func processStrongWorkouts(from rows: [StrongCSVRow]) async {
        let workoutGroups = Dictionary(grouping: rows) { row in
            return "\(row.date)|\(row.workoutName)"
        }
        
        let totalWorkouts = workoutGroups.count
        var processedWorkouts = 0
        
        for (_, workoutRows) in workoutGroups {
            guard let firstRow = workoutRows.first else { continue }
            
            processedWorkouts += 1
            importStatus = .importing(
                progress: 0.3 + (0.7 * (Double(processedWorkouts) / Double(totalWorkouts))),
                stage: .processingWorkouts(current: processedWorkouts, total: totalWorkouts)
            )
            
            await createSingleStrongWorkout(from: firstRow, rows: workoutRows)
            await Task.yield()
        }
        
        importStatus = .importing(progress: 0.95, stage: .savingData)
        do {
            try modelContext.save()
        } catch {
            importStatus = .failed(error: "Failed to save workouts: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Process Hevy Workouts
    
    private func processHevyWorkouts(from rows: [HevyCSVRow]) async {
        // Group rows by workout
        let workoutGroups = Dictionary(grouping: rows) { row in
            return "\(row.startTime)|\(row.title)"
        }
        
        let totalWorkouts = workoutGroups.count
        var processedWorkouts = 0
        
        for (_, workoutRows) in workoutGroups {
            guard let firstRow = workoutRows.first else { continue }
            
            processedWorkouts += 1
            importStatus = .importing(
                progress: 0.3 + (0.7 * (Double(processedWorkouts) / Double(totalWorkouts))),
                stage: .processingWorkouts(current: processedWorkouts, total: totalWorkouts)
            )
            
            await createSingleHevyWorkout(from: firstRow, rows: workoutRows)
            await Task.yield()
        }
        
        importStatus = .importing(progress: 0.95, stage: .savingData)
        do {
            try modelContext.save()
        } catch {
            importStatus = .failed(error: "Failed to save workouts: \(error.localizedDescription)")
        }
    }
    
    private func createSingleStrongWorkout(from firstRow: StrongCSVRow, rows workoutRows: [StrongCSVRow]) async {
        let workout = Workout(
            name: firstRow.workoutName,
            date: firstRow.date,
            endTime: firstRow.date.addingTimeInterval(firstRow.duration.toTimeInterval() ?? 0),
            isFinished: true,
            notes: firstRow.workoutNotes ?? ""
        )
        
        let exerciseGroups = Dictionary(grouping: workoutRows) { $0.exerciseName }
        
        workout.exercises = await withTaskGroup(of: WorkoutExercise.self) { group in
            for (exerciseName, exerciseRows) in exerciseGroups {
                group.addTask {
                    let exerciseID = await exerciseViewModel.findOrCreateExerciseID(for: exerciseName)
                    
                    let workoutExercise = WorkoutExercise(
                        exerciseID: exerciseID,
                        order: 0
                    )
                    
                    workoutExercise.sets = exerciseRows.map { row in
                        ExerciseSet(
                            reps: row.reps,
                            weight: row.weight,
                            rpe: row.rpe,
                            notes: row.notes,
                            order: row.setOrder - 1,
                            isDone: true
                        )
                    }.sorted { $0.order < $1.order }
                    
                    return workoutExercise
                }
            }
            
            var exercises: [WorkoutExercise] = []
            for await exercise in group {
                exercises.append(exercise)
            }
            
            // Update exercise order
            for (index, exercise) in exercises.enumerated() {
                exercise.order = index
            }
            
            return exercises
        }
        
        modelContext.insert(workout)
    }
    
    private func createSingleHevyWorkout(from firstRow: HevyCSVRow, rows workoutRows: [HevyCSVRow]) async {
        let workout = Workout(
            name: firstRow.title,
            date: firstRow.startTime,
            endTime: firstRow.endTime,
            isFinished: true,
            notes: firstRow.description ?? ""
        )
        
        let exerciseGroups = Dictionary(grouping: workoutRows) { $0.exerciseTitle }
        
        workout.exercises = await withTaskGroup(of: WorkoutExercise.self) { group in
            for (exerciseName, exerciseRows) in exerciseGroups {
                group.addTask {
                    let exerciseID = await exerciseViewModel.findOrCreateExerciseID(for: exerciseName)
                    
                    let workoutExercise = WorkoutExercise(
                        exerciseID: exerciseID,
                        order: 0,
                        notes: exerciseRows.first?.exerciseNotes
                    )
                    
                    workoutExercise.sets = exerciseRows.map { row in
                        let setType: SetType = {
                            switch row.setType.lowercased() {
                            case "warmup":
                                return .warmup
                            case "failure":
                                return .failure
                            case "drop":
                                return .drop
                            default:
                                return .working
                            }
                        }()
                        
                        return ExerciseSet(
                            reps: row.reps,
                            weight: row.weightLbs,
                            type: setType,
                            rpe: row.rpe,
                            notes: nil,
                            order: row.setIndex,
                            isDone: true
                        )
                    }.sorted { $0.order < $1.order }
                    
                    return workoutExercise
                }
            }
            
            var exercises: [WorkoutExercise] = []
            for await exercise in group {
                exercises.append(exercise)
            }
            
            // Update exercise order
            for (index, exercise) in exercises.enumerated() {
                exercise.order = index
            }
            
            return exercises
        }
        
        modelContext.insert(workout)
    }
    
    // MARK: - Helper Functions
    
    // Parse a CSV line with proper handling of quoted values
    private nonisolated func parseCSVLine(_ line: String) -> [String] {
        var fields: [String] = []
        var currentField = ""
        var inQuotes = false
        
        for char in line {
            switch char {
            case "\"":
                inQuotes.toggle()
            case ",":
                if !inQuotes {
                    fields.append(currentField)
                    currentField = ""
                } else {
                    currentField.append(char)
                }
            default:
                currentField.append(char)
            }
        }
        
        // Add the last field
        fields.append(currentField)
        
        // Trim quotes in one pass after parsing
        return fields.map { field in
            field.trimmingCharacters(in: quotesCharacterSet)
        }
    }
    
    // Parse Hevy date with multiple format support
    private nonisolated func parseHevyDate(_ dateString: String) -> Date? {
        // Try multiple date formats
        let formatters = [
            hevyDateFormatter,
            strongDateFormatter, // Try Strong format too in case of confusion
            
            // Add more formats for robustness
            { () -> DateFormatter in
                let formatter = DateFormatter()
                formatter.dateFormat = "dd MMM yyyy, h:mm a"
                return formatter
            }(),
            { () -> DateFormatter in
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                return formatter
            }()
        ]
        
        for formatter in formatters {
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        
        // If we still can't parse, try to extract a date portion
        if let dateComponent = dateString.components(separatedBy: CharacterSet(charactersIn: " ,T")).first,
           dateComponent.count >= 8 {
            let dateOnlyFormatter = DateFormatter()
            dateOnlyFormatter.dateFormat = "yyyy-MM-dd"
            
            if let date = dateOnlyFormatter.date(from: dateComponent) {
                return date
            }
        }
        
        print("Failed to parse date: \(dateString)")
        return nil
    }
}

#Preview {
    CSVImportView()
        .modelContainer(for: SupaSetSchemaV1.Workout.self)
}
