import SwiftUI

// Shared components that can be used across the app
// Place this in a separate file to avoid redeclarations

struct MuscleGroupPill: View {
    var muscleGroup: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(muscleGroup)
                .font(.system(size: 14, weight: isSelected ? .bold : .regular))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct MuscleGroupSelectionButton: View {
    var muscleGroup: String
    var isSelected: Bool
    var onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack {
                Text(muscleGroup)
                    .font(.system(size: 14))
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(8)
            .foregroundColor(isSelected ? .blue : .primary)
        }
        .buttonStyle(BorderlessButtonStyle())
    }
}
