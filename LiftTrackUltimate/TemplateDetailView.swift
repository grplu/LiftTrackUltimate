import SwiftUI

struct TemplateDetailView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteAlert = false
    @State private var showingEditView = false
    @State private var isWorkoutActive = false
    @State private var appear = false
    
    var template: WorkoutTemplate
    
    var body: some View {
        ZStack {
            // Background color
            Color.black.ignoresSafeArea()
            
            MainContentView(
                template: template,
                showingEditView: $showingEditView,
                showingDeleteAlert: $showingDeleteAlert,
                isWorkoutActive: $isWorkoutActive,
                dismiss: dismiss
            )
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingEditView) {
            EnhancedTemplateCreationView(
                existingTemplate: template,
                onSave: { updatedTemplate in
                    dataManager.updateTemplate(updatedTemplate)
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
        .fullScreenCover(isPresented: $isWorkoutActive) {
            ActiveWorkoutView(
                template: template,
                onEnd: {
                    isWorkoutActive = false
                    dismiss()
                }
            )
        }
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    if gesture.translation.height > 100 {
                        withAnimation {
                            appear = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            dismiss()
                        }
                    }
                }
        )
        .offset(y: appear ? 0 : UIScreen.main.bounds.height)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: appear)
        .onAppear {
            withAnimation {
                appear = true
            }
        }
    }
}

// MARK: - Subviews

struct MainContentView: View {
    let template: WorkoutTemplate
    @Binding var showingEditView: Bool
    @Binding var showingDeleteAlert: Bool
    @Binding var isWorkoutActive: Bool
    let dismiss: DismissAction
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(
                template: template,
                showingEditView: $showingEditView,
                showingDeleteAlert: $showingDeleteAlert,
                dismiss: dismiss
            )
            
            ExerciseListView(exercises: template.exercises)
            
            BottomActionPanel(
                template: template,
                isWorkoutActive: $isWorkoutActive
            )
        }
        .background(Color.black)
    }
}

struct HeaderView: View {
    let template: WorkoutTemplate
    @Binding var showingEditView: Bool
    @Binding var showingDeleteAlert: Bool
    let dismiss: DismissAction
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            NavigationBar(
                showingEditView: $showingEditView,
                showingDeleteAlert: $showingDeleteAlert,
                dismiss: dismiss
            )
            
            TemplateHeader(template: template)
        }
        .padding(.vertical, 16)
        .background(Color.black)
    }
}

struct NavigationBar: View {
    @Binding var showingEditView: Bool
    @Binding var showingDeleteAlert: Bool
    let dismiss: DismissAction
    
    var body: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Menu {
                Button(action: { showingEditView = true }) {
                    Label("Edit Template", systemImage: "pencil")
                }
                
                Button(role: .destructive, action: { showingDeleteAlert = true }) {
                    Label("Delete Template", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal)
    }
}

struct TemplateHeader: View {
    let template: WorkoutTemplate
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            TemplateIcon(template: template)
            
            TemplateInfo(template: template)
        }
        .padding(.horizontal)
    }
}

struct TemplateIcon: View {
    let template: WorkoutTemplate
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.getColor(named: template.iconColor ?? "blue").opacity(0.2))
                .frame(width: 60, height: 60)
            
            Image(systemName: template.customIcon ?? "dumbbell.fill")
                .font(.system(size: 24))
                .foregroundColor(Color.getColor(named: template.iconColor ?? "blue"))
        }
    }
}

struct TemplateInfo: View {
    let template: WorkoutTemplate
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(template.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            if let description = template.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct ExerciseListView: View {
    let exercises: [TemplateExercise]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(exercises) { exercise in
                    TemplateExerciseRow(exercise: exercise)
                }
            }
            .padding(.top, 16)
        }
    }
}

struct BottomActionPanel: View {
    let template: WorkoutTemplate
    @Binding var isWorkoutActive: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            StatsRow(exerciseCount: template.exercises.count)
            
            StartWorkoutButton(isWorkoutActive: $isWorkoutActive)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray6).opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
}

struct StatsRow: View {
    let exerciseCount: Int
    
    var body: some View {
        HStack(spacing: 20) {
            ExerciseCountView(count: exerciseCount)
            EstimatedTimeView(count: exerciseCount)
        }
        .padding(.bottom, 8)
    }
}

struct ExerciseCountView: View {
    let count: Int
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "dumbbell.fill")
                .font(.system(size: 16))
                .foregroundColor(.blue)
            
            Text("\(count) exercises")
                .font(.system(size: 16))
                .foregroundColor(.gray)
        }
    }
}

struct EstimatedTimeView: View {
    let count: Int
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "clock.fill")
                .font(.system(size: 16))
                .foregroundColor(.orange)
            
            Text("\(count * 10) mins")
                .font(.system(size: 16))
                .foregroundColor(.gray)
        }
    }
}

struct StartWorkoutButton: View {
    @Binding var isWorkoutActive: Bool
    
    var body: some View {
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
    }
}

// Preview provider for SwiftUI Canvas
struct TemplateDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleExercise = Exercise(name: "Bench Press", category: "Strength", muscleGroups: ["Chest"])
        let templateExercise = TemplateExercise(exercise: sampleExercise, targetSets: 3, targetReps: 10)
        let sampleTemplate = WorkoutTemplate(name: "Sample Workout", exercises: [templateExercise])
        
        return NavigationView {
            TemplateDetailView(template: sampleTemplate)
                .environmentObject(DataManager())
                .preferredColorScheme(.dark)
        }
    }
}
