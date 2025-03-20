import SwiftUI

struct WorkoutView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedTemplate: WorkoutTemplate?
    @State private var isWorkoutActive = false
    @State private var showingTemplateSelection = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if isWorkoutActive {
                    ActiveWorkoutView(
                        template: selectedTemplate,
                        onEnd: {
                            isWorkoutActive = false
                            selectedTemplate = nil
                        }
                    )
                    .environmentObject(dataManager)
                } else {
                    // Start Workout Options
                    VStack(spacing: 30) {
                        Image(systemName: "figure.run")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.blue)
                        
                        Text("Ready to get started?")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Button(action: {
                            isWorkoutActive = true
                        }) {
                            Text("Start Empty Workout")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            showingTemplateSelection = true
                        }) {
                            Text("Use Template")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    
                    Spacer()
                }
            }
            .navigationTitle("Workout")
            .sheet(isPresented: $showingTemplateSelection) {
                TemplateSelectionView { template in
                    self.selectedTemplate = template
                    self.isWorkoutActive = true
                    self.showingTemplateSelection = false
                }
                .environmentObject(dataManager)
            }
        }
    }
}

struct TemplateSelectionView: View {
    @EnvironmentObject var dataManager: DataManager
    var onSelect: (WorkoutTemplate) -> Void
    
    var body: some View {
        NavigationView {
            List(dataManager.templates) { template in
                Button(action: {
                    onSelect(template)
                }) {
                    VStack(alignment: .leading) {
                        Text(template.name)
                            .font(.headline)
                        
                        Text("\(template.exercises.count) exercises")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 5)
                }
            }
            .navigationTitle("Select Template")
        }
    }
}
