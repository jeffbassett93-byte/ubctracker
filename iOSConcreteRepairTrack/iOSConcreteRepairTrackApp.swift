//
//  iOSConcreteRepairTrackApp.swift
//  iOSConcreteRepairTrack
//
//  Created by Jeff on 2026-02-03.
//

import SwiftUI
import CoreData

@main
struct iOSConcreteRepairTrackApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
