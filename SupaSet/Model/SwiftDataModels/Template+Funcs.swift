//
//  Template+Funcs.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/21/25.
//

extension Template{
    func insertExercise(_ exerciseID: String) {
        let templateExercise = TemplateExercise(exerciseID: exerciseID, order: exercises.count)
        exercises.append(templateExercise)
    }
}
extension Template: Equatable {
    public static func == (lhs: Template, rhs: Template) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.notes == rhs.notes &&
        lhs.createdAt == rhs.createdAt &&
        lhs.lastUsed == rhs.lastUsed &&
        lhs.order == rhs.order &&
        lhs.exercises == rhs.exercises
    }
}

extension TemplateExercise: Equatable {
    public static func == (lhs: TemplateExercise, rhs: TemplateExercise) -> Bool {
        lhs.id == rhs.id &&
        lhs.exerciseID == rhs.exerciseID &&
        lhs.notes == rhs.notes &&
        lhs.order == rhs.order &&
        lhs.sets == rhs.sets
    }
}

extension TemplateExerciseSet: Equatable {
    public static func == (lhs: TemplateExerciseSet, rhs: TemplateExerciseSet) -> Bool {
        lhs.id == rhs.id &&
        lhs.order == rhs.order &&
        lhs.reps == rhs.reps &&
        lhs.weight == rhs.weight
    }
}

// First, create a protocol for content equality
protocol ContentEquatable {
    func isContentEqual(to other: Self) -> Bool
}

extension Template {
    func isContentEqual(to other: Template) -> Bool {
        // Compare name
        guard self.name == other.name else { return false }
        
        // Compare notes (handling optionals)
        guard self.notes == other.notes else { return false }
        
        // Compare order
        guard self.order == other.order else { return false }
        
        // Compare dates
        guard self.createdAt == other.createdAt else { return false }
        guard self.lastUsed == other.lastUsed else { return false }
        
        // Compare exercises
        guard self.exercises.count == other.exercises.count else { return false }
        
        // Create sorted arrays of exercises to ensure order doesn't matter
        let selfExercises = self.exercises.sorted { $0.order < $1.order }
        let otherExercises = other.exercises.sorted { $0.order < $1.order }
        
        // Compare each exercise
        for (selfExercise, otherExercise) in zip(selfExercises, otherExercises) {
            guard selfExercise.isContentEqual(to: otherExercise) else { return false }
        }
        
        return true
    }
}

extension TemplateExercise {
    func isContentEqual(to other: TemplateExercise) -> Bool {
        // Compare exercise properties
        guard self.exerciseID == other.exerciseID,
              self.order == other.order,
              self.notes == other.notes else { return false }
        
        // Compare sets
        guard self.sets.count == other.sets.count else { return false }
        
        // Create sorted arrays of sets to ensure order doesn't matter
        let selfSets = self.sets.sorted { $0.order < $1.order }
        let otherSets = other.sets.sorted { $0.order < $1.order }
        
        // Compare each set
        for (selfSet, otherSet) in zip(selfSets, otherSets) {
            guard selfSet.isContentEqual(to: otherSet) else { return false }
        }
        
        return true
    }
}

extension TemplateExerciseSet {
    func isContentEqual(to other: TemplateExerciseSet) -> Bool {
        return self.order == other.order &&
               self.reps == other.reps &&
               self.weight == other.weight
    }
}
