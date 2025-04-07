import SwiftUI

// Workout template card with consistent icon styling
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Icon and title row
            HStack(alignment: .center, spacing: 12) {
                // Badge icon with gradient background
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [accentColor.opacity(0.7), accentColor.opacity(0.5)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: templateIcon)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }
                
                // Template name
                Text(template.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Stats row
            VStack(spacing: 12) {
                // Exercise count
                HStack {
                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 12))
                        .foregroundColor(accentColor)
                    
                    Text("\(template.exercises.count) exercises")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    // Chevron indicator
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                // Estimated time with divider
                HStack {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 12))
                        .foregroundColor(clockIconColor)
                    
                    Text("\(durationInMinutes) mins")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Spacer()
                }
            }
        }
        .padding(16)
        .frame(height: 160)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6).opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(accentColor.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 20)
        .animation(
            .easeOut(duration: 0.2).delay(Double(index) * 0.03),
            value: appear
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                onCardTap()
            }
        }
        .contextMenu {
            Button(action: onEdit) {
                Label("Edit Template", systemImage: "pencil")
            }
            
            Button(role: .destructive, action: onDelete) {
                Label("Delete Template", systemImage: "trash")
            }
        }
    }
    
    // Get the template icon - prioritize custom icon if available
    private var templateIcon: String {
        // Use custom icon if available
        if let customIcon = template.customIcon, !customIcon.isEmpty {
            return customIcon
        }
        
        // Otherwise fall back to muscle-based icon
        return primaryMuscleIcon
    }
    
    // Duration calculation directly in the card view
    private var durationInMinutes: Int {
        // Assuming ~10 minutes per exercise as a rough estimate
        return template.exercises.count * 10
    }
    
    // Get accent color based on template's iconColor or primary muscle group
    private var accentColor: Color {
        // Use custom color if available
        if let colorName = template.iconColor, !colorName.isEmpty {
            return Color.getColor(named: colorName)
        }
        
        // Otherwise fall back to muscle-based color
        return primaryMuscleColor
    }
    
    // Clock icon color - orange is the default, but use accent color if it's similar to the template color
    private var clockIconColor: Color {
        // Only use default orange if accent color is blue or purple
        // For other colors, keep consistent with the template accent color
        if accentColor == .blue || accentColor == .purple {
            return .orange
        } else {
            return accentColor
        }
    }
    
    // Get icon based on primary muscle group
    private var primaryMuscleIcon: String {
        let primaryMuscle = template.exercises.first?.exercise.muscleGroups.first?.lowercased() ?? ""
        
        if primaryMuscle.contains("chest") {
            return "heart.fill"
        } else if primaryMuscle.contains("back") {
            return "figure.strengthtraining.traditional"
        } else if primaryMuscle.contains("shoulder") || primaryMuscle.contains("delt") {
            return "person.bust"
        } else if primaryMuscle.contains("bicep") || primaryMuscle.contains("tricep") || primaryMuscle.contains("arm") {
            return "figure.arms.open"
        } else if primaryMuscle.contains("core") || primaryMuscle.contains("abdominal") {
            return "figure.core.training"
        } else if primaryMuscle.contains("leg") || primaryMuscle.contains("quad") || primaryMuscle.contains("hamstring") {
            return "figure.walk"
        }
        
        return "dumbbell.fill"
    }
    
    // Get color based on primary muscle group
    private var primaryMuscleColor: Color {
        let primaryMuscle = template.exercises.first?.exercise.muscleGroups.first?.lowercased() ?? ""
        
        if primaryMuscle.contains("chest") {
            return .red
        } else if primaryMuscle.contains("back") {
            return .blue
        } else if primaryMuscle.contains("shoulder") || primaryMuscle.contains("delt") {
            return .purple
        } else if primaryMuscle.contains("bicep") || primaryMuscle.contains("tricep") || primaryMuscle.contains("arm") {
            return .green
        } else if primaryMuscle.contains("core") || primaryMuscle.contains("abdominal") {
            return .yellow
        } else if primaryMuscle.contains("leg") || primaryMuscle.contains("quad") || primaryMuscle.contains("hamstring") {
            return .orange
        }
        
        return .blue
    }
}
