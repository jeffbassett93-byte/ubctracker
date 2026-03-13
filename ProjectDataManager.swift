// ProjectDataManager.swift
// Data Management for Concrete Repair Tracker

import Foundation
import Combine
import SwiftUI

final class ProjectDataManager: ObservableObject {
    @Published var projects: [Project] = []
    
    private let userDefaults = UserDefaults.standard
    private let projectsKey = "concreteRepairProjects"
    
    // MARK: - Dashboard Sync
    @Published var dashboardURL: String {
        didSet {
            UserDefaults.standard.set(dashboardURL, forKey: "dashboardURL")
        }
    }
    
    @Published var lastSyncDate: Date?
    @Published var syncError: String?
    @Published var isSyncing = false
    
    init() {
        self.dashboardURL = UserDefaults.standard.string(forKey: "dashboardURL") ?? ""
        loadProjects()
    }
    
    // MARK: - Project Management
    func addProject(_ project: Project) {
        projects.append(project)
        saveProjects()
    }
    
    func deleteProject(at indexSet: IndexSet) {
        projects.remove(atOffsets: indexSet)
        saveProjects()
    }
    
    func updateProject(_ project: Project) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index] = project
            saveProjects()
        }
    }
    
    // MARK: - Stage Management
    func deleteStages(from project: Project, at offsets: IndexSet) {
        if let projectIndex = projects.firstIndex(where: { $0.id == project.id }) {
            let sortedStages = projects[projectIndex].stages.sorted(by: { $0.order < $1.order })
            for index in offsets {
                if index < sortedStages.count {
                    let stageToDelete = sortedStages[index]
                    projects[projectIndex].stages.removeAll { $0.id == stageToDelete.id }
                }
            }
            
            // Reorder remaining stages
            for (index, _) in projects[projectIndex].stages.enumerated() {
                projects[projectIndex].stages[index].order = index + 1
            }
            
            projects[projectIndex].updatedAt = Date()
            saveProjects()
        }
    }
    
    func toggleStageStatus(for project: Project, stage: Stage) {
        if let projectIndex = projects.firstIndex(where: { $0.id == project.id }),
           let stageIndex = projects[projectIndex].stages.firstIndex(where: { $0.id == stage.id }) {
            projects[projectIndex].stages[stageIndex].status = stage.status.nextStatus
            projects[projectIndex].updatedAt = Date()
            saveProjects()
        }
    }
    
    func addStage(to project: Project, stage: Stage) {
        if let projectIndex = projects.firstIndex(where: { $0.id == project.id }) {
            projects[projectIndex].stages.append(stage)
            projects[projectIndex].updatedAt = Date()
            saveProjects()
        }
    }
    
    // MARK: - Wall/Location Management
    func toggleLocationStatus(project: Project, wallName: String, locationId: UUID) {
        guard let projectIndex = projects.firstIndex(where: { $0.id == project.id }),
              var wall = projects[projectIndex].walls[wallName],
              let locationIndex = wall.locations.firstIndex(where: { $0.id == locationId }) else {
            return
        }
        
        // Toggle to next status
        wall.locations[locationIndex].status = wall.locations[locationIndex].status.nextStatus
        
        // Update date if completed
        if wall.locations[locationIndex].status == .rodsInstalled {
            wall.locations[locationIndex].dateCompleted = Date()
        }
        
        // Save wall back to project
        projects[projectIndex].walls[wallName] = wall
        projects[projectIndex].updatedAt = Date()
        saveProjects()
    }
    
    func updateLocationStatus(project: Project, wallName: String, locationId: UUID, newStatus: LocationStatus) {
        guard let projectIndex = projects.firstIndex(where: { $0.id == project.id }),
              var wall = projects[projectIndex].walls[wallName],
              let locationIndex = wall.locations.firstIndex(where: { $0.id == locationId }) else {
            return
        }
        
        wall.locations[locationIndex].status = newStatus
        
        if newStatus == .rodsInstalled {
            wall.locations[locationIndex].dateCompleted = Date()
        }
        
        projects[projectIndex].walls[wallName] = wall
        projects[projectIndex].updatedAt = Date()
        saveProjects()
    }
    
    func updateLocation(project: Project, wallName: String, locationId: UUID, status: LocationStatus, technician: String?, notes: String?, dateCompleted: Date?) {
        guard let projectIndex = projects.firstIndex(where: { $0.id == project.id }),
              var wall = projects[projectIndex].walls[wallName],
              let locationIndex = wall.locations.firstIndex(where: { $0.id == locationId }) else {
            return
        }
        
        wall.locations[locationIndex].status = status
        
        // Only update fields if they're provided (not nil means we want to update)
        if let technician = technician {
            wall.locations[locationIndex].technician = technician
        }
        if let notes = notes {
            wall.locations[locationIndex].notes = notes
        }
        wall.locations[locationIndex].dateCompleted = dateCompleted
        
        projects[projectIndex].walls[wallName] = wall
        projects[projectIndex].updatedAt = Date()
        saveProjects()
    }
    
    func bulkUpdateLocations(project: Project, wallName: String, locationIds: Set<UUID>, status: LocationStatus, technician: String?, notes: String?, dateCompleted: Date?) {
        guard let projectIndex = projects.firstIndex(where: { $0.id == project.id }),
              var wall = projects[projectIndex].walls[wallName] else {
            return
        }
        
        for locationId in locationIds {
            if let locationIndex = wall.locations.firstIndex(where: { $0.id == locationId }) {
                wall.locations[locationIndex].status = status
                
                if let technician = technician {
                    wall.locations[locationIndex].technician = technician
                }
                if let notes = notes {
                    wall.locations[locationIndex].notes = notes
                }
                wall.locations[locationIndex].dateCompleted = dateCompleted
            }
        }
        
        projects[projectIndex].walls[wallName] = wall
        projects[projectIndex].updatedAt = Date()
        saveProjects()
    }
    
    func updateStage(in project: Project, stage: Stage) {
        if let projectIndex = projects.firstIndex(where: { $0.id == project.id }),
           let stageIndex = projects[projectIndex].stages.firstIndex(where: { $0.id == stage.id }) {
            projects[projectIndex].stages[stageIndex] = stage
            projects[projectIndex].updatedAt = Date()
            saveProjects()
        }
    }
    
    // MARK: - Data Persistence
    private func saveProjects() {
        do {
            let data = try JSONEncoder().encode(projects)
            userDefaults.set(data, forKey: projectsKey)
        } catch {
            print("Error saving projects: \(error)")
        }
    }
    
    private func loadProjects() {
        guard let data = userDefaults.data(forKey: projectsKey) else { return }
        
        do {
            projects = try JSONDecoder().decode([Project].self, from: data)
        } catch {
            print("Error loading projects: \(error)")
            projects = []
        }
    }
    
    // MARK: - Dashboard Sync
    func syncToDashboard(completion: ((Bool) -> Void)? = nil) {
        guard !dashboardURL.isEmpty,
              let url = URL(string: "\(dashboardURL)/api/sync.php") else {
            syncError = "Invalid dashboard URL"
            completion?(false)
            return
        }
        
        isSyncing = true
        syncError = nil
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(projects)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = data
            request.timeoutInterval = 15
            
            URLSession.shared.dataTask(with: request) { [weak self] _, response, error in
                DispatchQueue.main.async {
                    self?.isSyncing = false
                    
                    if let error = error {
                        self?.syncError = error.localizedDescription
                        completion?(false)
                        return
                    }
                    
                    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                        self?.lastSyncDate = Date()
                        self?.syncError = nil
                        completion?(true)
                    } else {
                        self?.syncError = "Server returned an error"
                        completion?(false)
                    }
                }
            }.resume()
        } catch {
            isSyncing = false
            syncError = "Failed to encode data: \(error.localizedDescription)"
            completion?(false)
        }
    }
    
    // MARK: - Export/Import
    func exportProjects() -> URL? {
        do {
            let data = try JSONEncoder().encode(projects)
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsPath.appendingPathComponent("concrete-repair-tracker-\(Date().ISO8601Format()).json")
            
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Error exporting projects: \(error)")
            return nil
        }
    }
    
    func importProjects(from url: URL) {
        do {
            let data = try Data(contentsOf: url)
            let importedProjects = try JSONDecoder().decode([Project].self, from: data)
            projects = importedProjects
            saveProjects()
        } catch {
            print("Error importing projects: \(error)")
        }
    }
}
