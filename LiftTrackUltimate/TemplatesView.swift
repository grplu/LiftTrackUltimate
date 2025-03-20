import SwiftUI

struct TemplatesView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingNewTemplate = false
    @State private var editingTemplate: WorkoutTemplate?
    @State private var showingEditView = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(dataManager.templates) { template in
                    NavigationLink(destination: TemplateDetailView(template: template)
                        .environmentObject(dataManager)) {
                        TemplateRow(template: template)
                    }
                    .contextMenu {
                        Button(action: {
                            editingTemplate = template
                            showingEditView = true
                        }) {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive, action: {
                            // Delete the template
                            dataManager.deleteTemplate(template)
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                .onDelete(perform: deleteTemplates)
            }
            .navigationTitle("Workout Templates")
            .toolbar {
                EditButton()
                
                Button(action: {
                    showingNewTemplate = true
                }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingNewTemplate) {
                NewTemplateView { newTemplate in
                    dataManager.saveTemplate(newTemplate)
                    showingNewTemplate = false
                }
                .environmentObject(dataManager)
            }
            .sheet(item: $editingTemplate) { template in
                EditTemplateView(template: template) { updatedTemplate in
                    dataManager.updateTemplate(updatedTemplate)
                    editingTemplate = nil
                }
                .environmentObject(dataManager)
            }
        }
    }
    
    func deleteTemplates(at offsets: IndexSet) {
        // Get the templates to delete
        let templatesToDelete = offsets.map { dataManager.templates[$0] }
        
        // Delete each template using the data manager
        for template in templatesToDelete {
            dataManager.deleteTemplate(template)
        }
    }
}

struct TemplateRow: View {
    var template: WorkoutTemplate
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(template.name)
                .font(.headline)
            
            Text("\(template.exercises.count) exercises")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 5)
    }
}
