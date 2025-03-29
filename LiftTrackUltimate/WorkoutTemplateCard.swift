import SwiftUI

// Workout template card with confirmation overlay
struct WorkoutTemplateCard: View {
    var template: WorkoutTemplate
    var index: Int
    var appear: Bool
    var isConfirming: Bool
    var onCardTap: () -> Void
    var onStartTap: () -> Void
    var onEdit: () -> Void
    var onDelete: () -> Void
    @State private var isPressed = false
    @State private var isStartPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = true
            }
            
            // Brief delay to show the press effect
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    isPressed = false
                }
                
                // Toggle confirmation with smooth animation
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    onCardTap()
                }
            }
        }) {
            ZStack(alignment: .center) {
                // Card content
                VStack(alignment: .leading, spacing: 12) {
                    // Top row with icon and menu
                    HStack(alignment: .center) {
                        // Icon for primary muscle group
                        ZStack {
                            Circle()
                                .fill(accentColor.opacity(0.2))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: primaryMuscleIcon)
                                .font(.system(size: 18))
                                .foregroundColor(accentColor)
                        }
                        .padding(.top, 2)
                        
                        Spacer()
                        
                        // More options menu
                        Menu {
                            Button(action: onEdit) {
                                Label("Edit", systemImage: "pencil")
                            }
                            
                            Button(role: .destructive, action: onDelete) {
                                Label("Delete", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .padding(8)
                                .contentShape(Circle())
                        }
                    }
                    .padding(.bottom, 2)
                    
                    Spacer()
                    
                    // Template name - dynamic sizing
                    Text(template.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Stats row - properly aligned
                    HStack(alignment: .center) {
                        // Exercise icon and count
                        HStack(spacing: 6) {
                            Image(systemName: "dumbbell.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.green)
                            
                            Text("\(template.exercises.count) exercises")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        // Chevron positioned correctly
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                            .offset(y: -1)
                    }
                    .padding(.bottom, 4)
                    
                    // Duration with icon - properly aligned
                    HStack(spacing: 6) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.orange)
                        
                        Text("\(durationInMinutes) mins")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            
                        Spacer()
                    }
                }
                .padding(16)
                
                // Confirmation overlay when confirming
                if isConfirming {
                    // Position the confirmation dialog to be centered over this card
                    GeometryReader { geometry in
                        ZStack {
                            // Semi-transparent backdrop
                            Color.black.opacity(0.85)
                                .cornerRadius(16)
                                .frame(width: 170, height: 220) // Smaller size
                                .shadow(color: Color.black.opacity(0.5), radius: 10, x: 0, y: 0)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    // Do nothing when tapping on the confirmation overlay itself
                                }
                            
                            // Confirmation content - adjusted for better fit
                            VStack(spacing: 8) { // Reduced spacing
                                // Template name with start text
                                Text("Start \(template.name)")
                                    .font(.system(size: 16, weight: .bold)) // Smaller font
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.7)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.top, 12)
                                    .padding(.horizontal, 10)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        // Do nothing - prevent tap from propagating
                                    }
                                
                                // Stats in row with adjusted spacing - FIXED TEXT CUTOFF
                                HStack(spacing: 36) { // Reduced spacing
                                    // Exercise count with better alignment
                                    VStack(spacing: 4) {
                                        Text("\(template.exercises.count)")
                                            .font(.system(size: 22, weight: .bold)) // Smaller font to fit text
                                            .foregroundColor(.white)
                                        
                                        Text("Exer...")
                                            .font(.system(size: 11))
                                            .foregroundColor(.gray)
                                            .fixedSize(horizontal: true, vertical: false) // Prevent truncation
                                    }
                                    
                                    // Duration with better alignment
                                    VStack(spacing: 4) {
                                        Text("\(durationInMinutes)")
                                            .font(.system(size: 22, weight: .bold)) // Smaller font to fit text
                                            .foregroundColor(.white)
                                        
                                        Text("Mins")
                                            .font(.system(size: 11))
                                            .foregroundColor(.gray)
                                            .fixedSize(horizontal: true, vertical: false) // Prevent truncation
                                    }
                                }
                                .padding(.vertical, 8) // Reduced padding
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    // Do nothing - prevent tap from propagating
                                }
                                
                                // Start button - smaller size with animation
                                Button(action: {
                                    // Visual feedback animation
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        isStartPressed = true
                                    }
                                    
                                    // Brief delay to show animation
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                        withAnimation {
                                            isStartPressed = false
                                        }
                                        onStartTap()
                                    }
                                }) {
                                    Text("Start")
                                        .font(.system(size: 20, weight: .bold)) // Smaller font
                                        .foregroundColor(.white)
                                        .frame(width: 76, height: 76) // Smaller button
                                        .background(
                                            Circle()
                                                .fill(Color.green)
                                        )
                                }
                                .scaleEffect(isStartPressed ? 0.9 : 1.0)
                                .padding(.top, 4) // Reduced padding
                                .padding(.bottom, 12) // Reduced padding
                            }
                            .frame(width: 170, height: 220) // Match the backdrop size
                            .contentShape(Rectangle())
                            .onTapGesture {
                                // Do nothing when tapping on the VStack content
                            }
                        }
                        .position(x: geometry.size.width/2, y: geometry.size.height/2)
                        .transition(
                            .asymmetric(
                                insertion: .scale(scale: 0.9).combined(with: .opacity)
                                    .animation(.spring(response: 0.4, dampingFraction: 0.7)),
                                removal: .scale(scale: 0.9).combined(with: .opacity)
                                    .animation(.easeOut(duration: 0.25))
                            )
                        )
                    }
                }
            }
            .frame(height: 160)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6).opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isPressed ? Color.blue : accentColor.opacity(0.2), lineWidth: isPressed ? 2 : 1)
                    )
            )
            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 20)
        .zIndex(isConfirming ? 10 : 0) // Increase z-index when confirming
        .animation(
            .spring(response: 0.5, dampingFraction: 0.8)
            .delay(0.1 + Double(index) * 0.05),
            value: appear
        )
    }
    
    // Duration calculation directly in the card view
    private var durationInMinutes: Int {
        // Assuming ~10 minutes per exercise as a rough estimate
        return template.exercises.count * 10
    }
    
    // Determine the primary muscle group and corresponding color
    private var primaryMuscleGroup: String {
        // Count occurrences of each muscle group
        var muscleGroupCounts: [String: Int] = [:]
        
        for exerciseTemplate in template.exercises {
            for muscleGroup in exerciseTemplate.exercise.muscleGroups {
                muscleGroupCounts[muscleGroup, default: 0] += 1
            }
        }
        
        // Return the most common muscle group, or "Mixed" if none
        return muscleGroupCounts.max(by: { $0.value < $1.value })?.key ?? "Mixed"
    }
    
    // Get icon for primary muscle group
    private var primaryMuscleIcon: String {
        let mainMuscle = primaryMuscleGroup.lowercased()
        
        if mainMuscle.contains("chest") {
            return "heart.fill"
        } else if mainMuscle.contains("back") {
            return "figure.strengthtraining.traditional"
        } else if mainMuscle.contains("shoulder") || mainMuscle.contains("delt") {
            return "person.bust"
        } else if mainMuscle.contains("bicep") || mainMuscle.contains("tricep") || mainMuscle.contains("arm") {
            return "figure.arms.open"
        } else if mainMuscle.contains("core") || mainMuscle.contains("ab") {
            return "figure.core.training"
        } else if mainMuscle.contains("leg") || mainMuscle.contains("quad") || mainMuscle.contains("hamstring") {
            return "figure.walk"
        } else {
            return "figure.mixed.cardio"
        }
    }
    
    // Get accent color based on primary muscle group
    private var accentColor: Color {
        let mainMuscle = primaryMuscleGroup.lowercased()
        
        if mainMuscle.contains("chest") {
            return .red
        } else if mainMuscle.contains("back") {
            return .blue
        } else if mainMuscle.contains("shoulder") || mainMuscle.contains("delt") {
            return .purple
        } else if mainMuscle.contains("bicep") || mainMuscle.contains("tricep") || mainMuscle.contains("arm") {
            return .green
        } else if mainMuscle.contains("core") || mainMuscle.contains("ab") {
            return .yellow
        } else if mainMuscle.contains("leg") || mainMuscle.contains("quad") || mainMuscle.contains("hamstring") {
            return .orange
        } else {
            return .blue
        }
    }
}

// Create New Template card
struct CreateTemplateCard: View {
    var onTap: () -> Void
    var index: Int
    var appear: Bool
    @State private var isPulsing = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 14) {
                // Pulsing plus icon
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 40, height: 40)
                        
                    Circle()
                        .stroke(Color.blue.opacity(0.5), lineWidth: 2)
                        .frame(width: 40, height: 40)
                        .scaleEffect(isPulsing ? 1.3 : 1.0)
                        .opacity(isPulsing ? 0.0 : 0.8)
                        .animation(
                            Animation.easeInOut(duration: 1.2)
                                .repeatForever(autoreverses: false),
                            value: isPulsing
                        )
                    
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                // Text content
                Text("Create New Template")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("Customize your own workout routine")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            .padding(16)
            .frame(height: 160)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.blue.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
            )
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 20)
            .animation(
                .spring(response: 0.5, dampingFraction: 0.8)
                .delay(0.1 + Double(index) * 0.05),
                value: appear
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            // Start pulsing animation when view appears
            isPulsing = true
        }
    }
}
