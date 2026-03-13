// Models.swift
// Data Models for Concrete Repair Tracker - UBC Facade Rod Installation

import Foundation

// MARK: - Repair Type Enum
enum RepairType: String, Codable, CaseIterable {
    case concreteRepair = "concrete"
    case finRepair = "fin"
    case plateInstallation = "plate"
    
    var displayName: String {
        switch self {
        case .concreteRepair: return "Concrete Repair"
        case .finRepair: return "Fin Repair"
        case .plateInstallation: return "Plate Installation"
        }
    }
    
    var tabIcon: String {
        switch self {
        case .concreteRepair: return "building.2"
        case .finRepair: return "rectangle.split.3x3"
        case .plateInstallation: return "square.stack.3d.up"
        }
    }
}

// MARK: - Project Model
struct Project: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var location: String
    var startDate: Date
    var endDate: Date
    var walls: [String: Wall]
    var stages: [Stage]
    let createdAt: Date
    var updatedAt: Date
    var repairType: RepairType
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Project, rhs: Project) -> Bool {
        lhs.id == rhs.id && lhs.updatedAt == rhs.updatedAt
    }
    
    var progressPercentage: Int {
        var totalLocations = 0
        var completedLocations = 0
        
        for wall in walls.values {
            totalLocations += wall.locations.count
            completedLocations += wall.locations.filter { $0.status == .rodsInstalled }.count
        }
        
        return totalLocations > 0 ? Int((Double(completedLocations) / Double(totalLocations)) * 100) : 0
    }
    
    var totalLocations: Int {
        walls.values.reduce(0) { $0 + $1.locations.count }
    }
    
    var completedLocations: Int {
        walls.values.reduce(0) { sum, wall in
            sum + wall.locations.filter { $0.status == .rodsInstalled }.count
        }
    }
    
    init(name: String, location: String, startDate: Date, endDate: Date, repairType: RepairType = .concreteRepair) {
        self.id = UUID()
        self.name = name
        self.location = location
        self.startDate = startDate
        self.endDate = endDate
        self.walls = Wall.defaultWalls()
        self.stages = Stage.defaultStages()
        self.createdAt = Date()
        self.updatedAt = Date()
        self.repairType = repairType
    }
    
    // Custom Codable for backward compatibility
    enum CodingKeys: String, CodingKey {
        case id, name, location, startDate, endDate, walls, stages, createdAt, updatedAt, repairType
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        location = try container.decode(String.self, forKey: .location)
        startDate = try container.decode(Date.self, forKey: .startDate)
        endDate = try container.decode(Date.self, forKey: .endDate)
        walls = try container.decode([String: Wall].self, forKey: .walls)
        stages = try container.decode([Stage].self, forKey: .stages)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        repairType = try container.decodeIfPresent(RepairType.self, forKey: .repairType) ?? .concreteRepair
    }
}

// MARK: - Wall Model
struct Wall: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var bays: Int
    var windows: [String]
    var locationsPerWindow: Int
    var locations: [RodLocation]
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Wall, rhs: Wall) -> Bool {
        lhs.id == rhs.id && lhs.locations.map(\.status) == rhs.locations.map(\.status)
    }
    
    var rodsInstalled: Int {
        locations.filter { $0.status == .rodsInstalled }.count
    }
    
    var holesDrilled: Int {
        locations.filter { $0.status == .holesDrilled }.count
    }
    
    var rebar: Int {
        locations.filter { $0.status == .rebar }.count
    }
    
    var notComplete: Int {
        locations.filter { $0.status == .notComplete }.count
    }
    
    var hss: Int {
        locations.filter { $0.status == .hss }.count
    }
    
    var other: Int {
        locations.filter { $0.status == .other }.count
    }
    
    var progressPercentage: Int {
        locations.isEmpty ? 0 : Int((Double(rodsInstalled) / Double(locations.count)) * 100)
    }
    
    init(name: String, bays: Int, windows: [String], locationsPerWindow: Int, statusDistribution: [LocationStatus: Int]) {
        self.id = UUID()
        self.name = name
        self.bays = bays
        self.windows = windows
        self.locationsPerWindow = locationsPerWindow
        self.locations = Wall.generateLocations(bays: bays, windows: windows, locationsPerWindow: locationsPerWindow, statusDistribution: statusDistribution)
    }
    
    static func generateLocations(bays: Int, windows: [String], locationsPerWindow: Int, statusDistribution: [LocationStatus: Int]) -> [RodLocation] {
        var locations: [RodLocation] = []
        var statusQueue: [LocationStatus] = []
        
        // Build status queue
        for (status, count) in statusDistribution {
            for _ in 0..<count {
                statusQueue.append(status)
            }
        }
        
        // Shuffle for random distribution
        statusQueue.shuffle()
        
        var statusIndex = 0
        
        for bay in 1...bays {
            for window in windows {
                for loc in 1...locationsPerWindow {
                    let status = statusIndex < statusQueue.count ? statusQueue[statusIndex] : .notComplete
                    statusIndex += 1
                    
                    locations.append(RodLocation(
                        bay: bay,
                        window: window,
                        locationNumber: loc,
                        status: status
                    ))
                }
            }
        }
        
        return locations
    }
    
    static func defaultWalls() -> [String: Wall] {
        return [
            "North Wall": Wall(
                name: "North Wall",
                bays: 4,
                windows: ["A", "B", "C", "D", "E", "F", "G", "H"],
                locationsPerWindow: 4,
                statusDistribution: [.rodsInstalled: 60, .notComplete: 68]
            ),
            "East Wall": Wall(
                name: "East Wall",
                bays: 14,
                windows: ["A", "B", "C", "D", "E", "F", "G", "H"],
                locationsPerWindow: 4,
                statusDistribution: [.rodsInstalled: 120, .notComplete: 311, .rebar: 9]
            ),
            "South Wall": Wall(
                name: "South Wall",
                bays: 4,
                windows: ["A", "B", "C", "D", "E", "F", "G", "H"],
                locationsPerWindow: 4,
                statusDistribution: [.holesDrilled: 120]
            ),
            "West Wall": Wall(
                name: "West Wall",
                bays: 14,
                windows: ["A", "B", "C", "D", "E", "F", "G", "H"],
                locationsPerWindow: 4,
                statusDistribution: [.rodsInstalled: 24, .notComplete: 424]
            )
        ]
    }
}

// MARK: - Rod Location Model
struct RodLocation: Identifiable, Codable, Hashable {
    let id: UUID
    var bay: Int
    var window: String
    var locationNumber: Int
    var status: LocationStatus
    var dateCompleted: Date?
    var technician: String?
    var notes: String?
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: RodLocation, rhs: RodLocation) -> Bool {
        lhs.id == rhs.id && lhs.status == rhs.status && lhs.dateCompleted == rhs.dateCompleted
    }
    
    init(bay: Int, window: String, locationNumber: Int, status: LocationStatus) {
        self.id = UUID()
        self.bay = bay
        self.window = window
        self.locationNumber = locationNumber
        self.status = status
        self.dateCompleted = status == .rodsInstalled ? Date() : nil
        self.technician = nil
        self.notes = nil
    }
}

// MARK: - Location Status Enum
enum LocationStatus: String, CaseIterable, Codable {
    case notComplete = "Not Complete"
    case holesDrilled = "Holes Drilled"
    case rebar = "Rebar"
    case rodsInstalled = "Rods Installed"
    case hss = "HSS"
    case other = "Other"
    
    var displayName: String {
        rawValue
    }
    
    var nextStatus: LocationStatus {
        switch self {
        case .notComplete:
            return .holesDrilled
        case .holesDrilled:
            return .rebar
        case .rebar:
            return .rodsInstalled
        case .rodsInstalled:
            return .hss
        case .hss:
            return .other
        case .other:
            return .notComplete
        }
    }
}

// MARK: - Stage Model (kept for backward compatibility)
struct Stage: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var duration: Int
    var status: StageStatus
    var order: Int
    
    var progressPercentage: Int {
        switch status {
        case .pending:
            return 0
        case .inProgress:
            return 50
        case .completed:
            return 100
        case .delayed:
            return 25
        }
    }
    
    init(name: String, description: String, duration: Int, status: StageStatus, order: Int) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.duration = duration
        self.status = status
        self.order = order
    }
    
    static func defaultStages() -> [Stage] {
        return [
            Stage(name: "Initial Assessment", description: "Evaluate concrete damage and determine repair scope", duration: 3, status: .completed, order: 1),
            Stage(name: "Surface Preparation", description: "Clean and prepare the concrete surface for repair", duration: 5, status: .completed, order: 2),
            Stage(name: "Drilling for Tectonic Plate Install", description: "Drill holes for tectonic plate installation", duration: 3, status: .inProgress, order: 3),
            Stage(name: "Cleaning of Drilled Holes", description: "Clean and prepare drilled holes for rod installation", duration: 2, status: .inProgress, order: 4),
            Stage(name: "Setting Rods for Plate Install", description: "Install and secure rods for plate mounting", duration: 4, status: .inProgress, order: 5),
            Stage(name: "Plate Install", description: "Install tectonic plates and secure connections", duration: 3, status: .pending, order: 6),
            Stage(name: "Final Inspection", description: "Inspect completed repair work", duration: 2, status: .pending, order: 7),
            Stage(name: "Site Cleanup", description: "Clean and prepare site for handover", duration: 1, status: .pending, order: 8)
        ]
    }
}

// MARK: - Stage Status Enum
enum StageStatus: String, CaseIterable, Codable {
    case pending = "pending"
    case inProgress = "in-progress"
    case completed = "completed"
    case delayed = "delayed"
    
    var displayName: String {
        switch self {
        case .pending:
            return "Pending"
        case .inProgress:
            return "In Progress"
        case .completed:
            return "Completed"
        case .delayed:
            return "Delayed"
        }
    }
    
    var nextStatus: StageStatus {
        switch self {
        case .pending:
            return .inProgress
        case .inProgress:
            return .completed
        case .completed:
            return .pending
        case .delayed:
            return .inProgress
        }
    }
}
