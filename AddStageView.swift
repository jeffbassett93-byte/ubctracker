// AddStageView.swift
// View for adding new stages

import SwiftUI

struct AddStageView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataManager: ProjectDataManager
    
    let project: Project
    
    @State private var stageName = ""
    @State private var stageDescription = ""
    @State private var duration = 1
    @State private var status: StageStatus = .pending
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Stage Information")) {
                    TextField("Stage Name", text: $stageName)
                    if #available(iOS 16.0, *) {
                        TextField("Description", text: $stageDescription, axis: .vertical)
                            .lineLimit(3...6)
                    } else {
                        TextField("Description", text: $stageDescription)
                    }
                }
                
                Section(header: Text("Details")) {
                    HStack {
                        Text("Duration")
                        Spacer()
                        TextField("Days", value: $duration, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("days")
                            .foregroundColor(.secondary)
                    }
                    
                    Picker("Status", selection: $status) {
                        ForEach(StageStatus.allCases, id: \.self) { status in
                            Text(status.displayName).tag(status)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .navigationTitle("New Stage")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveStage()
                    }
                    .disabled(stageName.isEmpty)
                }
            }
        }
    }
    
    private func saveStage() {
        let newStage = Stage(
            name: stageName,
            description: stageDescription,
            duration: duration,
            status: status,
            order: project.stages.count + 1
        )
        
        dataManager.addStage(to: project, stage: newStage)
        presentationMode.wrappedValue.dismiss()
    }
}

struct AddStageView_Previews: PreviewProvider {
    static var previews: some View {
        AddStageView(project: Project(name: "Test", location: "Test", startDate: Date(), endDate: Date()))
            .environmentObject(ProjectDataManager())
    }
}
