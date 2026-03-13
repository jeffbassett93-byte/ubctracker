// ConcreteRepairTrackerApp.swift
// Concrete Repair Tracker iOS App

import SwiftUI

@main
struct ConcreteRepairTrackerApp: App {
    @StateObject private var dataManager = ProjectDataManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
        }
    }
}
