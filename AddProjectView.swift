// AddProjectView.swift
// View for adding new projects

import SwiftUI

struct AddProjectView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataManager: ProjectDataManager
    
    let repairType: RepairType
    
    @State private var projectName = ""
    @State private var projectLocation = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Project Information")) {
                    TextField("Project Name", text: $projectName)
                    TextField("Location", text: $projectLocation)
                }
                
                Section(header: Text("Timeline")) {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("Estimated Completion", selection: $endDate, displayedComponents: .date)
                }
            }
            .navigationTitle("New Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProject()
                    }
                    .disabled(projectName.isEmpty || projectLocation.isEmpty)
                }
            }
        }
    }
    
    private func saveProject() {
        let newProject = Project(
            name: projectName,
            location: projectLocation,
            startDate: startDate,
            endDate: endDate,
            repairType: repairType
        )
        
        dataManager.addProject(newProject)
        presentationMode.wrappedValue.dismiss()
    }
}

struct AddProjectView_Previews: PreviewProvider {
    static var previews: some View {
        AddProjectView(repairType: .concreteRepair)
            .environmentObject(ProjectDataManager())
    }
}
