import SwiftUI

struct WorkoutDetailView: View {
    var workout: AppWorkout
    @State private var showingDeleteAlert = false
    @State private var appear = false
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background
            Color.black.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header with animated entrance
                    VStack(alignment: .leading, spacing: 8) {
                        // Title with zoom animation
                        Text(workout.name)
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                            .opacity(appear ? 1 : 0)
                            .offset(y: appear ? 0 : 20)
                        
                        // Date and time
                        Text(formattedDate(workout.date))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .opacity(appear ? 1 : 0)
                            .offset(y: appear ? 0 : 15)
                        
                        // Duration
                        Text(formattedDuration(workout.duration))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .opacity(appear ? 1 : 0)
                            .offset(y: appear ? 0 : 10)
                    }
                    .padding(.horizontal)
                    
                    // Summary stats with animated entrance
                    HStack(spacing: 20) {
                        // Exercise count with icon
                        SummaryStatCard(
                            title: "Exercises",
                            value: "\(workout.exercises.count)",
                            iconName: "dumbbell.fill",
                            color: .blue,
                            delay: 0.3
                        )
                        
                        // Sets count with icon
                        SummaryStatCard(
                            title: "Sets",
                            value: "\(workout.exercises.reduce(0) { $0 + $1.sets.count })",
                            iconName: "repeat",
                            color: .green,
                            delay: 0.4
                        )
                    }
                    .padding(.horizontal)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 30)
                    
                    // Exercises section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Exercises")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .opacity(appear ? 1 : 0)
                            .offset(y: appear ? 0 : 20)
                        
                        if workout.exercises.isEmpty {
                            Text("No exercises recorded")
                                .foregroundColor(.gray)
                                .padding()
                                .opacity(appear ? 1 : 0)
                        } else {
                            ForEach(Array(workout.exercises.enumerated()), id: \.element.id) { index, exercise in
                                EnhancedExerciseCard(exercise: exercise, index: index)
                                    .opacity(appear ? 1 : 0)
                                    .offset(y: appear ? 0 : 40)
                                    .animation(Animation.spring(response: 0.6, dampingFraction: 0.8)
                                        .delay(0.4 + Double(index) * 0.1), value: appear)
                            }
                        }
                    }
                    
                    // Notes section if available
                    if let notes = workout.notes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Notes")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text(notes)
                                .foregroundColor(.gray)
                                .padding()
                                .background(Color(.systemGray6).opacity(0.3))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .opacity(appear ? 1 : 0)
                        .offset(y: appear ? 0 : 20)
                        .animation(Animation.spring(response: 0.6, dampingFraction: 0.8)
                            .delay(0.6 + Double(workout.exercises.count) * 0.1), value: appear)
                    }
                    
                    Spacer(minLength: 60)
                }
                .padding(.top, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Workout Details")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingDeleteAlert = true
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .alert("Delete Workout", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                dataManager.deleteWorkout(workout)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this workout? This action cannot be undone.")
        }
        .onAppear {
            // Animate entrance
            withAnimation(Animation.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                appear = true
            }
        }
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func formattedDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        
        if hours > 0 {
            return "\(hours) hr \(minutes) min"
        } else {
            return "\(minutes) min"
        }
    }
}

struct EnhancedExerciseCard: View {
    var exercise: WorkoutExercise
    var index: Int
    @State private var expanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Exercise header
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    expanded.toggle()
                }
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(exercise.exercise.name)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("\(exercise.sets.count) sets • \(exercise.exercise.muscleGroups.joined(separator: ", "))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                        .font(.system(size: 16, weight: .semibold))
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Circle())
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemGray6).opacity(0.3),
                        Color(.systemGray6).opacity(0.2)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            
            // Sets list (conditionally shown)
            if expanded {
                VStack(spacing: 8) {
                    Divider()
                        .background(Color.gray.opacity(0.3))
                    
                    ForEach(exercise.sets) { set in
                        HStack {
                            Text("Set \(exercise.sets.firstIndex(where: { $0.id == set.id })! + 1)")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.gray)
                                .frame(width: 70, alignment: .leading)
                            
                            Spacer()
                            
                            if let reps = set.reps {
                                Text("\(reps) reps")
                                    .font(.system(size: 15))
                                    .foregroundColor(.white)
                                    .frame(width: 70, alignment: .trailing)
                            }
                            
                            if let weight = set.weight {
                                Text("\(String(format: "%.1f", weight)) kg")
                                    .font(.system(size: 15))
                                    .foregroundColor(.white)
                                    .frame(width: 80, alignment: .trailing)
                            }
                            
                            Image(systemName: set.completed ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(set.completed ? .green : .gray)
                                .font(.system(size: 16))
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 6)
                    }
                }
                .background(Color(.systemGray6).opacity(0.1))
                .cornerRadius(16, corners: [.bottomLeft, .bottomRight])
            }
        }
        .background(Color.clear)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
}

struct SummaryStatCard: View {
    var title: String
    var value: String
    var iconName: String
    var color: Color
    var delay: Double
    
    @State private var appear = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon with circle background
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 60, height: 60)
                
                Image(systemName: iconName)
                    .font(.system(size: 24))
                    .foregroundColor(color)
            }
            .scaleEffect(appear ? 1 : 0.5)
            
            // Value
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 10)
            
            // Title
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
                .opacity(appear ? 1 : 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray6).opacity(0.3))
        )
        .onAppear {
            withAnimation(Animation.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                appear = true
            }
        }
    }
}

struct DumbbellAnimationView: View {
    @State private var animating = false
    
    var body: some View {
        ZStack {
            // Left weight
            Circle()
                .fill(Color.gray.opacity(0.7))
                .frame(width: 30, height: 30)
                .offset(x: -30)
            
            // Bar
            Rectangle()
                .fill(Color.gray.opacity(0.9))
                .frame(width: 60, height: 8)
            
            // Right weight
            Circle()
                .fill(Color.gray.opacity(0.7))
                .frame(width: 30, height: 30)
                .offset(x: 30)
        }
        .scaleEffect(animating ? 1.1 : 1.0)
        .rotationEffect(Angle(degrees: animating ? 10 : -10))
        .animation(Animation.easeInOut(duration: 0.7).repeatForever(autoreverses: true), value: animating)
        .onAppear {
            animating = true
        }
    }
}

// Extension to apply rounded corners to specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
