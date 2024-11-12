//
//  AppContainer.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/11/24.
//

import SwiftData


// Create a singleton or static container for global access
class AppContainer {
    static var shared = AppContainer()
    var container: ModelContainer?
}
