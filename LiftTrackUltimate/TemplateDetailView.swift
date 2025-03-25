import SwiftUI

struct TemplateDetailView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteAlert = false
    @State private var showingEditView = false
    @State private var isWorkoutActive = false
    
    var template: WorkoutTemplate
    
    var body: some View {
        ZStack {
            // Background color
            Color.black.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Template header card
                    VStack(spacing: 16) {
                        // Icon
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.blue.opacity(0.5)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "dumbbell.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 20)
                        
                        // Template name
                        Text(template.name)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        // Exercise count & time
                        HStack(spacing: 20) {
                            // Exercise count
                            HStack(spacing: 8) {
                                Image(systemName: "dumbbell.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.blue)
                                
                                Text("\(template.exercises.count) exercises")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                            }
                            
                            // Estimated time
                            HStack(spacing: 8) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.orange)
                                
                                Text("\(template.exercises.count * 10) mins")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.bottom, 8)
                        
                        // Start workout button
                        Button(action: {
                            isWorkoutActive = true
                        }) {
                            Text("Start Workout")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(height: 56)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.green)
                                )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    }
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemGray6).opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal)
                    
                    // Exercises section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Exercises")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        ForEach(template.exercises.indices, id: \.self) { index in
                            ExerciseDetailRow(
                                exercise: template.exercises[index],
                                index: index
                            )
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Template Details")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        showingEditView = true
                    }) {
                        Label("Edit Template", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive, action: {
                        showingDeleteAlert = true
                    }) {
                        Label("Delete Template", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEditView) {
            EnhancedTemplateCreationView(
                existingTemplate: template,
                onSave: { updatedTemplate in
                    // Update the template in the data manager
                    dataManager.updateTemplate(updatedTemplate)
                }
            )
            .environmentObject(dataManager)
        }
        .sheet(isPresented: $isWorkoutActive) {
            // Use the existing ActiveWorkoutView
            ActiveWorkoutView(
                template: template,
                onEnd: {
                    isWorkoutActive = false
                }
            )
            .environmentObject(dataManager)
        }
        .alert("Delete Template", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                dataManager.deleteTemplate(template)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this template? This action cannot be undone.")
        }
    }
}

struct ExerciseDetailRow: View {
    var exercise: TemplateExercise
    var index: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Exercise header
            HStack(spacing: 16) {
                // Exercise number indicator with circle background
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.blue.opacity(0.7),
                                    Color.blue.opacity(0.5)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    
                    Text("\(index + 1)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.exercise.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    // Handle optional reps safely
                    let repsText = exercise.targetReps != nil ? "\(exercise.targetReps!)" : "0"
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.blue.opacity(0.8))
                            
                            Text("\(exercise.targetSets) sets")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "repeat")
                                .font(.system(size: 12))
                                .foregroundColor(.green.opacity(0.8))
                            
                            Text("\(repsText) reps")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6).opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
}
