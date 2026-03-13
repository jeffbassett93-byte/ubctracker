// ContentView.swift
// Main View for Concrete Repair Tracker - Wall-Based Rod Installation Tracking

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataManager: ProjectDataManager
    
    var body: some View {
        TabView {
            NavigationStack {
                ProjectsListView(repairType: .concreteRepair)
            }
            .tabItem {
                Label("Concrete Repair", systemImage: "building.2")
            }
            
            NavigationStack {
                ProjectsListView(repairType: .finRepair)
            }
            .tabItem {
                Label("Fin Repair", systemImage: "rectangle.split.3x3")
            }
            
            NavigationStack {
                ProjectsListView(repairType: .plateInstallation)
            }
            .tabItem {
                Label("Plate Install", systemImage: "square.stack.3d.up")
            }
            
            NavigationStack {
                DashboardSyncView()
            }
            .tabItem {
                Label("Dashboard", systemImage: "square.and.arrow.up")
            }
        }
    }
}

// MARK: - Projects List View
struct ProjectsListView: View {
    @EnvironmentObject var dataManager: ProjectDataManager
    @State private var showingAddProject = false
    let repairType: RepairType
    
    var filteredProjects: [Project] {
        dataManager.projects.filter { $0.repairType == repairType }
    }
    
    var body: some View {
        Group {
            if filteredProjects.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: repairType.tabIcon)
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No Projects Yet")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("Create your first \(repairType.displayName.lowercased()) project")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Button(action: { showingAddProject = true }) {
                        Label("New Project", systemImage: "plus.circle.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.top)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(filteredProjects) { project in
                        NavigationLink(value: project) {
                            ProjectCardInlineView(project: project)
                        }
                        .id("\(project.id)-\(project.updatedAt)")
                    }
                    .onDelete { indexSet in
                        let projectsToDelete = indexSet.map { filteredProjects[$0] }
                        for project in projectsToDelete {
                            if let globalIndex = dataManager.projects.firstIndex(where: { $0.id == project.id }) {
                                dataManager.projects.remove(at: globalIndex)
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle(repairType.displayName)
        .navigationDestination(for: Project.self) { project in
            WallsOverviewView(project: project)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddProject = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddProject) {
            AddProjectView(repairType: repairType)
        }
    }
}

// MARK: - Project Card Inline View (for List)
struct ProjectCardInlineView: View {
    let project: Project
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(project.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(project.location)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("\(project.progressPercentage)%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("\(project.completedLocations)/\(project.totalLocations)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            ProgressView(value: Double(project.progressPercentage) / 100.0)
                .tint(.green)
            
            HStack {
                Text("\(project.walls.count) walls")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(project.totalLocations) locations")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Walls Overview View
struct WallsOverviewView: View {
    @EnvironmentObject var dataManager: ProjectDataManager
    let project: Project
    
    // Computed property to get the latest project data
    private var currentProject: Project? {
        dataManager.projects.first(where: { $0.id == project.id })
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let currentProject = currentProject {
                    // Project Header
                    VStack(spacing: 8) {
                        Text("\(currentProject.completedLocations) of \(currentProject.totalLocations) rods installed")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        ProgressView(value: Double(currentProject.progressPercentage) / 100.0)
                            .tint(.green)
                            .padding(.horizontal)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Walls Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(Array(currentProject.walls.keys.sorted()), id: \.self) { wallName in
                            if let wall = currentProject.walls[wallName] {
                                NavigationLink(value: WallIdentifier(projectId: currentProject.id, wallName: wallName)) {
                                    WallCardView(wall: wall)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Legend
                    LegendView()
                        .padding()
                }
            }
        }
        .id(currentProject?.updatedAt)
        .navigationTitle(project.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: WallIdentifier.self) { identifier in
            if dataManager.projects.contains(where: { $0.id == identifier.projectId }) {
                WallDetailView(projectId: identifier.projectId, wallName: identifier.wallName)
            }
        }
    }
}

// MARK: - Wall Identifier (for navigation)
struct WallIdentifier: Hashable {
    let projectId: UUID
    let wallName: String
}

// MARK: - Wall Card View
struct WallCardView: View {
    let wall: Wall
    
    var body: some View {
        VStack(spacing: 8) {
            Text(wall.name)
                .font(.headline)
                .foregroundColor(.primary)
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 6)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: CGFloat(wall.progressPercentage) / 100.0)
                    .stroke(Color.green, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                
                Text("\(wall.progressPercentage)%")
                    .font(.caption)
                    .fontWeight(.bold)
            }
            
            HStack(spacing: 4) {
                StatusDot(color: .green)
                Text("\(wall.rodsInstalled)")
                    .font(.caption2)
                StatusDot(color: .gray)
                Text("\(wall.notComplete)")
                    .font(.caption2)
                StatusDot(color: .purple)
                Text("\(wall.hss)")
                    .font(.caption2)
                StatusDot(color: .pink)
                Text("\(wall.other)")
                    .font(.caption2)
            }
            
            Text("\(wall.bays) bays × \(wall.windows.count) windows")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Wall Detail View
struct WallDetailView: View {
    @EnvironmentObject var dataManager: ProjectDataManager
    let projectId: UUID
    let wallName: String
    
    @State private var isSelectionMode = false
    @State private var selectedLocationIds: Set<UUID> = []
    @State private var filterStatus: LocationStatus?
    @State private var showingBulkUpdate = false
    
    // Computed properties to get live data
    private var project: Project? {
        dataManager.projects.first(where: { $0.id == projectId })
    }
    
    private var wall: Wall? {
        project?.walls[wallName]
    }
    
    var filteredBays: [Int] {
        guard let wall = wall else { return [] }
        
        if filterStatus == nil {
            return Array(1...wall.bays)
        }
        // Only show bays that have locations matching the filter
        return (1...wall.bays).filter { bay in
            wall.locations.contains { location in
                location.bay == bay && location.status == filterStatus
            }
        }
    }
    
    var body: some View {
        Group {
            if let project = project, let wall = wall {
                ScrollView {
                    VStack(spacing: 16) {
                        // Wall Header
                        VStack(spacing: 8) {
                            HStack(spacing: 16) {
                                StatBox(label: "Rods Installed", value: "\(wall.rodsInstalled)", color: .green)
                                StatBox(label: "Holes Drilled", value: "\(wall.holesDrilled)", color: .blue)
                                StatBox(label: "Rebar", value: "\(wall.rebar)", color: .orange)
                                StatBox(label: "Not Complete", value: "\(wall.notComplete)", color: .gray)
                                StatBox(label: "HSS", value: "\(wall.hss)", color: .purple)
                                StatBox(label: "Other", value: "\(wall.other)", color: .pink)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        // Filter and Selection Controls
                        VStack(spacing: 12) {
                            // Filter by Status
                            HStack {
                                Text("Filter:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        FilterChip(title: "All", isSelected: filterStatus == nil) {
                                            filterStatus = nil
                                        }
                                        
                                        ForEach(LocationStatus.allCases, id: \.self) { status in
                                            FilterChip(
                                                title: status.displayName,
                                                isSelected: filterStatus == status,
                                                color: colorForStatus(status)
                                            ) {
                                                filterStatus = status
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            // Selection Mode Controls
                            if isSelectionMode {
                                HStack {
                                    Button(action: selectAllFiltered) {
                                        Label("Select All", systemImage: "checkmark.circle")
                                            .font(.subheadline)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: { selectedLocationIds.removeAll() }) {
                                        Label("Deselect All", systemImage: "circle")
                                            .font(.subheadline)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: { showingBulkUpdate = true }) {
                                        Label("Update (\(selectedLocationIds.count))", systemImage: "square.and.pencil")
                                            .font(.subheadline)
                                    }
                                    .disabled(selectedLocationIds.isEmpty)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                                .padding(.horizontal)
                            }
                        }
                        
                        // Bay Grid
                        ForEach(filteredBays, id: \.self) { bay in
                            BayGridView(
                                projectId: projectId,
                                wallName: wallName,
                                bay: bay,
                                isSelectionMode: isSelectionMode,
                                selectedLocationIds: $selectedLocationIds,
                                filterStatus: filterStatus
                            )
                        }
                        
                        // Legend
                        LegendView()
                            .padding()
                    }
                }
                .navigationTitle(wall.name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isSelectionMode.toggle()
                            if !isSelectionMode {
                                selectedLocationIds.removeAll()
                            }
                        }) {
                            Label(
                                isSelectionMode ? "Done" : "Select",
                                systemImage: isSelectionMode ? "checkmark" : "checkmark.circle"
                            )
                        }
                    }
                }
                .sheet(isPresented: $showingBulkUpdate) {
                    if let currentProj = self.project, let currentWall = self.wall {
                        BulkUpdateView(
                            project: currentProj,
                            wall: currentWall,
                            selectedLocationIds: selectedLocationIds,
                            onComplete: {
                                selectedLocationIds.removeAll()
                                isSelectionMode = false
                            }
                        )
                    }
                }
            } else {
                VStack {
                    Text("Wall not found")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private func selectAllFiltered() {
        guard let wall = wall else { return }
        
        let filtered = wall.locations.filter { location in
            if let filter = filterStatus {
                return location.status == filter
            }
            return true
        }
        selectedLocationIds = Set(filtered.map { $0.id })
    }
    
    private func colorForStatus(_ status: LocationStatus) -> Color {
        switch status {
        case .rodsInstalled: return .green
        case .holesDrilled: return .blue
        case .rebar: return .orange
        case .notComplete: return .gray
        case .hss: return .purple
        case .other: return .pink
        }
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    var isSelected: Bool
    var color: Color = .blue
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? color : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

// MARK: - Bay Grid View
struct BayGridView: View {
    @EnvironmentObject var dataManager: ProjectDataManager
    let projectId: UUID
    let wallName: String
    let bay: Int
    var isSelectionMode: Bool = false
    @Binding var selectedLocationIds: Set<UUID>
    var filterStatus: LocationStatus?
    
    // Get live data
    private var project: Project? {
        dataManager.projects.first(where: { $0.id == projectId })
    }
    
    private var wall: Wall? {
        project?.walls[wallName]
    }
    
    init(projectId: UUID, wallName: String, bay: Int, isSelectionMode: Bool = false, selectedLocationIds: Binding<Set<UUID>> = .constant([]), filterStatus: LocationStatus? = nil) {
        self.projectId = projectId
        self.wallName = wallName
        self.bay = bay
        self.isSelectionMode = isSelectionMode
        self._selectedLocationIds = selectedLocationIds
        self.filterStatus = filterStatus
    }
    
    var body: some View {
        Group {
            if let project = project, let wall = wall {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Bay \(bay)")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    // Window Headers
                    HStack(spacing: 4) {
                        ForEach(wall.windows, id: \.self) { window in
                            Text(window)
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Location Grid - 4 rows (locations 1-4)
                    ForEach(1...4, id: \.self) { locationNum in
                        HStack(spacing: 4) {
                            ForEach(wall.windows, id: \.self) { window in
                                if let location = wall.locations.first(where: { 
                                    $0.bay == bay && $0.window == window && $0.locationNumber == locationNum 
                                }) {
                                    if filterStatus == nil || location.status == filterStatus {
                                        LocationButton(
                                            projectId: projectId,
                                            wallName: wallName,
                                            locationId: location.id,
                                            isSelectionMode: isSelectionMode,
                                            isSelected: selectedLocationIds.contains(location.id)
                                        ) {
                                            if isSelectionMode {
                                                if selectedLocationIds.contains(location.id) {
                                                    selectedLocationIds.remove(location.id)
                                                } else {
                                                    selectedLocationIds.insert(location.id)
                                                }
                                            }
                                        }
                                    } else {
                                        // Filtered out - show as disabled
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.1))
                                            .frame(height: 28)
                                            .cornerRadius(4)
                                    }
                                } else {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 28)
                                        .cornerRadius(4)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Location Button
struct LocationButton: View {
    @EnvironmentObject var dataManager: ProjectDataManager
    let projectId: UUID
    let wallName: String
    let locationId: UUID
    var isSelectionMode: Bool = false
    var isSelected: Bool = false
    var onSelectionToggle: (() -> Void)?
    
    @State private var showingLocationDetail = false
    
    // Get live data
    private var project: Project? {
        dataManager.projects.first(where: { $0.id == projectId })
    }
    
    private var wall: Wall? {
        project?.walls[wallName]
    }
    
    private var location: RodLocation? {
        wall?.locations.first(where: { $0.id == locationId })
    }
    
    var body: some View {
        Group {
            if let location = location {
                Button(action: {
                    if isSelectionMode {
                        onSelectionToggle?()
                    } else {
                        showingLocationDetail = true
                    }
                }) {
                    ZStack {
                        Text("\(location.locationNumber)")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 28)
                            .background(statusColor)
                            .cornerRadius(4)
                            .opacity(isSelectionMode && !isSelected ? 0.5 : 1.0)
                        
                        if isSelectionMode && isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.white)
                                .font(.caption)
                                .shadow(color: .black.opacity(0.3), radius: 1)
                        }
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(isSelectionMode && isSelected ? Color.white : Color.clear, lineWidth: 2)
                )
                .sheet(isPresented: $showingLocationDetail) {
                    if let project = project, let wall = wall {
                        LocationDetailView(project: project, wall: wall, location: location)
                    }
                }
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 28)
                    .cornerRadius(4)
            }
        }
    }
    
    var statusColor: Color {
        guard let location = location else { return .gray }
        
        switch location.status {
        case .rodsInstalled:
            return .green
        case .holesDrilled:
            return .blue
        case .rebar:
            return .orange
        case .notComplete:
            return .gray
        case .hss:
            return .purple
        case .other:
            return .pink
        }
    }
}

// MARK: - Location Detail View
struct LocationDetailView: View {
    @EnvironmentObject var dataManager: ProjectDataManager
    @Environment(\.dismiss) var dismiss
    
    let project: Project
    let wall: Wall
    let location: RodLocation
    
    @State private var status: LocationStatus
    @State private var technician: String
    @State private var notes: String
    @State private var dateCompleted: Date
    
    init(project: Project, wall: Wall, location: RodLocation) {
        self.project = project
        self.wall = wall
        self.location = location
        _status = State(initialValue: location.status)
        _technician = State(initialValue: location.technician ?? "")
        _notes = State(initialValue: location.notes ?? "")
        _dateCompleted = State(initialValue: location.dateCompleted ?? Date())
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Location Information") {
                    HStack {
                        Text("Bay")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(location.bay)")
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Window")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(location.window)
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Location #")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(location.locationNumber)")
                            .fontWeight(.semibold)
                    }
                }
                
                Section("Status") {
                    Picker("Current Status", selection: $status) {
                        ForEach(LocationStatus.allCases, id: \.self) { status in
                            Text(status.displayName).tag(status)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    if status == .rodsInstalled {
                        DatePicker("Date Completed", selection: $dateCompleted, displayedComponents: [.date])
                    }
                }
                
                Section("Details") {
                    TextField("Technician Name", text: $technician)
                    
                    ZStack(alignment: .topLeading) {
                        if notes.isEmpty {
                            Text("Notes (optional)")
                                .foregroundColor(Color(.placeholderText))
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        TextEditor(text: $notes)
                            .frame(minHeight: 100)
                    }
                }
            }
            .navigationTitle("\(wall.name) - Bay \(location.bay)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveChanges() {
        dataManager.updateLocation(
            project: project,
            wallName: wall.name,
            locationId: location.id,
            status: status,
            technician: technician.isEmpty ? nil : technician,
            notes: notes.isEmpty ? nil : notes,
            dateCompleted: status == .rodsInstalled ? dateCompleted : nil
        )
    }
}

// MARK: - Bulk Update View
struct BulkUpdateView: View {
    @EnvironmentObject var dataManager: ProjectDataManager
    @Environment(\.dismiss) var dismiss
    
    let project: Project
    let wall: Wall
    let selectedLocationIds: Set<UUID>
    let onComplete: () -> Void
    
    @State private var newStatus: LocationStatus = .notComplete
    @State private var updateTechnician = false
    @State private var technician = ""
    @State private var updateNotes = false
    @State private var notes = ""
    @State private var updateDate = false
    @State private var dateCompleted = Date()
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Update \(selectedLocationIds.count) selected locations")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Section("Status") {
                    Picker("New Status", selection: $newStatus) {
                        ForEach(LocationStatus.allCases, id: \.self) { status in
                            HStack {
                                Circle()
                                    .fill(colorForStatus(status))
                                    .frame(width: 12, height: 12)
                                Text(status.displayName)
                            }
                            .tag(status)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Optional Updates") {
                    Toggle("Update Technician", isOn: $updateTechnician)
                    if updateTechnician {
                        TextField("Technician Name", text: $technician)
                    }
                    
                    Toggle("Update Notes", isOn: $updateNotes)
                    if updateNotes {
                        ZStack(alignment: .topLeading) {
                            if notes.isEmpty {
                                Text("Notes")
                                    .foregroundColor(Color(.placeholderText))
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                            }
                            TextEditor(text: $notes)
                                .frame(minHeight: 80)
                        }
                    }
                    
                    if newStatus == .rodsInstalled {
                        Toggle("Update Completion Date", isOn: $updateDate)
                        if updateDate {
                            DatePicker("Date Completed", selection: $dateCompleted, displayedComponents: [.date])
                        }
                    }
                }
                
                Section {
                    Text("This will apply the selected changes to all \(selectedLocationIds.count) locations.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Bulk Update")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        applyBulkUpdate()
                        onComplete()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func applyBulkUpdate() {
        dataManager.bulkUpdateLocations(
            project: project,
            wallName: wall.name,
            locationIds: selectedLocationIds,
            status: newStatus,
            technician: updateTechnician ? (technician.isEmpty ? nil : technician) : nil,
            notes: updateNotes ? (notes.isEmpty ? nil : notes) : nil,
            dateCompleted: (newStatus == .rodsInstalled && updateDate) ? dateCompleted : nil
        )
    }
    
    private func colorForStatus(_ status: LocationStatus) -> Color {
        switch status {
        case .rodsInstalled: return .green
        case .holesDrilled: return .blue
        case .rebar: return .orange
        case .notComplete: return .gray
        case .hss: return .purple
        case .other: return .pink
        }
    }
}

// MARK: - Helper Views
struct StatusDot: View {
    let color: Color
    var body: some View {
        Circle().fill(color).frame(width: 8, height: 8)
    }
}

struct StatBox: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct LegendView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Legend")
                .font(.headline)
            HStack(spacing: 16) {
                LegendItem(color: .green, label: "Rods Installed")
                LegendItem(color: .blue, label: "Holes Drilled")
                LegendItem(color: .orange, label: "Rebar")
                LegendItem(color: .gray, label: "Not Complete")
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 4) {
            Rectangle()
                .fill(color)
                .frame(width: 12, height: 12)
                .cornerRadius(2)
            Text(label)
                .font(.caption2)
        }
    }
}

// MARK: - Dashboard Sync View
struct DashboardSyncView: View {
    @EnvironmentObject var dataManager: ProjectDataManager
    @State private var showingSyncSuccess = false
    
    var body: some View {
        Form {
            Section(header: Text("Dashboard URL")) {
                TextField("https://your-server.com", text: $dataManager.dashboardURL)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            
            Section(header: Text("Sync")) {
                Button(action: {
                    dataManager.syncToDashboard { success in
                        if success {
                            showingSyncSuccess = true
                        }
                    }
                }) {
                    HStack {
                        if dataManager.isSyncing {
                            ProgressView()
                                .padding(.trailing, 8)
                            Text("Syncing...")
                        } else {
                            Image(systemName: "arrow.triangle.2.circlepath")
                            Text("Sync to Dashboard")
                        }
                    }
                }
                .disabled(dataManager.dashboardURL.isEmpty || dataManager.isSyncing)
                
                if let error = dataManager.syncError {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                if let lastSync = dataManager.lastSyncDate {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Last synced: \(lastSync, style: .relative) ago")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Section(header: Text("Data Summary")) {
                HStack {
                    Text("Total Projects")
                    Spacer()
                    Text("\(dataManager.projects.count)")
                        .foregroundColor(.secondary)
                }
                
                ForEach(RepairType.allCases, id: \.self) { type in
                    let count = dataManager.projects.filter { $0.repairType == type }.count
                    HStack {
                        Image(systemName: type.tabIcon)
                            .frame(width: 20)
                        Text(type.displayName)
                        Spacer()
                        Text("\(count)")
                            .foregroundColor(.secondary)
                    }
                }
                
                let totalLocations = dataManager.projects.reduce(0) { $0 + $1.totalLocations }
                let completedLocations = dataManager.projects.reduce(0) { $0 + $1.completedLocations }
                
                HStack {
                    Text("Total Locations")
                    Spacer()
                    Text("\(totalLocations)")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Completed")
                    Spacer()
                    Text("\(completedLocations)")
                        .foregroundColor(.green)
                }
            }
            
            Section(footer: Text("Enter your dashboard server URL and tap Sync to upload all project data to the web dashboard for sharing.")) {
                EmptyView()
            }
        }
        .navigationTitle("Dashboard")
        .alert("Sync Complete", isPresented: $showingSyncSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("All project data has been uploaded to the dashboard.")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ProjectDataManager())
    }
}
