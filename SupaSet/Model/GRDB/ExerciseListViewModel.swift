//
//  ExerciseListViewModel.swift
//  SupaSet
// ... (imports) ...

import Foundation
import os

@MainActor
class ExerciseListViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var exercises: [ExerciseRecord] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var canLoadMorePages: Bool = true
    @Published var searchText: String = ""
    // Filter selections - nil means "All"
    @Published var selectedCategory: Category? = nil
    @Published var selectedMuscleGroup: MuscleGroup? = nil
    @Published var selectedLevel: Level? = nil
    @Published var selectedEquipment: Equipment? = nil

    // MARK: - Filter Options for Pickers
    // Add 'nil' to represent the "All" option
    let allCategories: [Category?] = [nil] + Category.allCases.sorted { $0.rawValue < $1.rawValue }
    let allMuscleGroups: [MuscleGroup?] = [nil] + MuscleGroup.allCases.sorted { $0.description < $1.description }
    let allLevels: [Level?] = [nil] + Level.allCases.sorted { $0.rawValue < $1.rawValue }
    let allEquipment: [Equipment?] = [nil] + Equipment.allCases.sorted { $0.rawValue < $1.rawValue }

    // MARK: - Private State
    private var currentPage = 0
    private let pageSize = 20
    private var totalCount = 0
    private let dbManager = GRDBManager.shared
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ExerciseListViewModel")

    // Debounce filter changes slightly to avoid rapid reloads if multiple pickers are changed quickly.
    // Note: Direct .onChange in the View might be sufficient for many cases.
    // private var filterDebounceTimer: AnyCancellable?

    // MARK: - Initialization
    init() {
        // Initial load (consider if filters should apply initially or start blank)
        Task {
           await loadMoreExercises(isInitialLoad: true)
        }
    }

    // MARK: - Public Methods

    /// Call this when any filter picker value changes in the View.
    func filtersDidChange() async {
         guard !isLoading else {
             logger.debug("Filters changed, but loading is already in progress. Ignoring.")
             return // Avoid concurrent modifications if already loading
         }

        logger.info("Filters changed. Resetting list and reloading.")

        // Reset state BEFORE fetching
        self.exercises = []
        self.currentPage = 0
        self.canLoadMorePages = true
        self.totalCount = 0 // Force recount with new filters
        self.errorMessage = nil // Clear previous errors

        // Fetch new data using current filter selections
        await loadMoreExercises()
    }

    /// Refreshes the list, resetting filters and pagination.
    func refreshExercises(resetFilters: Bool = false) async {
         guard !isLoading else { return } // Don't refresh if already loading

        logger.info("Refreshing exercises... Reset Filters: \(resetFilters)")
        isLoading = true
        errorMessage = nil
        currentPage = 0
        canLoadMorePages = true
        totalCount = 0
        exercises = []

        if resetFilters {
            selectedCategory = nil
            selectedMuscleGroup = nil
            selectedLevel = nil
            selectedEquipment = nil
        }

        await loadMoreExercises() // Load the first page with current (potentially reset) filters
    }


    func loadMoreExercisesIfNeeded(currentItem item: ExerciseRecord?) {
        guard let item = item else {
             // Handles initial load if needed, although init/filtersDidChange should cover it
            Task {
                 if exercises.isEmpty && !isLoading && canLoadMorePages {
                     await loadMoreExercises()
                 }
            }
            return
        }

        // Only proceed if we can still load more and aren't already loading
        guard canLoadMorePages, !isLoading else { return }

        let thresholdIndex = exercises.index(exercises.endIndex, offsetBy: -5)
        if exercises.firstIndex(where: { $0.id == item.id }) == thresholdIndex {
            logger.debug("Threshold reached by item \(item.name). Loading more.")
            Task {
                await loadMoreExercises()
            }
        }
    }
    func fetchMuscleGroups(for exerciseID: String) async -> [MuscleGroup]{
        do {
            return try await dbManager.fetchPrimaryMuscles(id: exerciseID)
        } catch {
            logger.error("Failed to load muscle group for \(exerciseID): \(error.localizedDescription)")
            errorMessage = "Failed to load muscle group"
            // Don't change currentPage, so next attempt tries the same page
            isLoading = false
            return []
        }
    }
    // MARK: - Private Loading Logic
    /// Loads exercises, respecting current filters and pagination.
    private func loadMoreExercises(isInitialLoad: Bool = false) async {
        // Prevent concurrent loads and loading beyond the end
        guard !isLoading && (canLoadMorePages || isInitialLoad) else {
             if isLoading { logger.debug("Load triggered, but already loading.") }
             if !canLoadMorePages { logger.debug("Load triggered, but cannot load more pages.") }
            return
        }

        isLoading = true
        // Don't clear error message here, let it persist until success or explicit clear
        // errorMessage = nil
        let requestedPage = currentPage + 1 // Page to request

        logger.info("Loading page \(requestedPage) with filters - Cat: \(self.selectedCategory?.rawValue ?? "All"), Muscle: \(self.selectedMuscleGroup?.description ?? "All"), Lvl: \(self.selectedLevel?.rawValue ?? "All"), Eqp: \(self.selectedEquipment?.rawValue ?? "All")")

        do {
            // Get total count matching filters if we don't have it yet (or if filters changed)
            if totalCount == 0 {
                totalCount = try await dbManager.fetchTotalExerciseCount(
                    category: selectedCategory,
                    muscleGroup: selectedMuscleGroup,
                    level: selectedLevel,
                    equipment: selectedEquipment
                )
                 logger.info("Total exercises matching filters: \(self.totalCount)")
                 // If count is 0, no need to fetch further
                 if totalCount == 0 {
                    canLoadMorePages = false
                    isLoading = false
                    exercises = [] // Ensure list is empty
                    logger.info("Total count is 0. No exercises to load.")
                    return
                 }
            }

            // Fetch the actual records for the current page
            let newExercises = try await dbManager.fetchExerciseRecords(
                page: requestedPage,
                pageSize: pageSize,
                category: selectedCategory,
                muscleGroup: selectedMuscleGroup,
                level: selectedLevel,
                equipment: selectedEquipment
            )

            // --- Update State ---
            if newExercises.isEmpty && requestedPage > 1 {
                // We requested a page beyond the first, and it came back empty
                logger.info("Loaded 0 exercises for page \(requestedPage). Reached the end.")
                canLoadMorePages = false
            } else {
                // Append new exercises. If it was page 1, this replaces the empty array.
                 logger.info("Loaded \(newExercises.count) exercises for page \(requestedPage).")
                exercises.append(contentsOf: newExercises)
                currentPage = requestedPage // Only update current page on successful load
                // Check if we've loaded all possible items
                 if exercises.count >= totalCount {
                     canLoadMorePages = false
                     logger.info("Reached total count (\(self.totalCount)). Disabling further loading.")
                 } else if newExercises.count < pageSize {
                    // If last fetch returned fewer than page size, assume it's the end
                    canLoadMorePages = false
                     logger.info("Partial page loaded (\(newExercises.count)/\(self.pageSize)). Assuming end of results.")
                 } else {
                    // We loaded a full page and haven't reached the total count yet
                    canLoadMorePages = true
                 }
            }
            errorMessage = nil // Clear error on success
            isLoading = false

        } catch {
            logger.error("Failed to load exercises page \(requestedPage): \(error.localizedDescription)")
            errorMessage = "Failed to load exercises. Pull to refresh or adjust filters."
            // Don't change currentPage, so next attempt tries the same page
            isLoading = false
            // If the first load fails, ensure we can try again
            if requestedPage == 1 { canLoadMorePages = true }
        }
    }

    // MARK: - Helper for Picker Display Name
    // Helper function to display "All" for nil selections in Pickers
     func displayName<T: RawRepresentable>(for option: T?) -> String where T.RawValue == String {
        return option?.rawValue.capitalized ?? "All"
    }
    // Overload for MuscleGroup which uses description
     func displayName(for option: MuscleGroup?) -> String {
        return option?.description ?? "All"
    }

}
