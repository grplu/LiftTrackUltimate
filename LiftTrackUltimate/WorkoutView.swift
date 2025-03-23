import SwiftUI

struct WorkoutView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedTemplate: WorkoutTemplate?
    @State private var isWorkoutActive = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Title
                HStack {
                    Text("Workout")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                    Spacer()
                }
                
                // Templates List
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(dataManager.templates) { template in
                            Button(action: {
                                selectedTemplate = template
                                isWorkoutActive = true
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(template.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        Text("\(template.exercises.count) Exercises • \(estimatedDuration(for: template)) mins")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding()
                                    
                                    Spacer()
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(uiColor: .systemBackground))
                                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                
                // Navigation to ActiveWorkoutView when a template is selected
                NavigationLink(
                    destination: ActiveWorkoutView(
                        template: selectedTemplate,
                        onEnd: {
                            isWorkoutActive = false
                            selectedTemplate = nil
                        }
                    ),
                    isActive: $isWorkoutActive
                ) {
                    EmptyView()
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    // Helper method to estimate workout duration
    private func estimatedDuration(for template: WorkoutTemplate) -> Int {
        // Assuming ~10 minutes per exercise as a rough estimate
        return template.exercises.count * 10
    }
}
