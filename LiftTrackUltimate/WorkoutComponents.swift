import SwiftUI

// Background view with tap detection
struct WorkoutBackgroundView: View {
    @Binding var confirmingTemplateId: UUID?
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.black, Color.black.opacity(0.9)]),
            startPoint: .top,
            endPoint: .bottom
        )
        .edgesIgnoringSafeArea(.all)
        .contentShape(Rectangle())
        .onTapGesture {
            if confirmingTemplateId != nil {
                withAnimation(.easeOut(duration: 0.2)) {
                    confirmingTemplateId = nil
                }
            }
        }
    }
}

// Body part dropdown component
struct BodyPartDropdown: View {
    @Binding var selectedBodyPart: String?
    @Binding var showDropdown: Bool
    var bodyParts: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(bodyParts, id: \.self) { bodyPart in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedBodyPart = bodyPart
                        showDropdown = false
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: bodyPartIcon(bodyPart))
                            .font(.system(size: 16))
                            .foregroundColor(selectedBodyPart == bodyPart ? .blue : .gray)
                            .frame(width: 24)
                        
                        Text(bodyPart)
                            .font(.system(size: 16))
                            .foregroundColor(selectedBodyPart == bodyPart ? .white : .gray)
                        
                        Spacer()
                        
                        if selectedBodyPart == bodyPart {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        selectedBodyPart == bodyPart ?
                            Color.blue.opacity(0.1) :
                            Color.clear
                    )
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6).opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .offset(y: showDropdown ? 0 : -10)
        .opacity(showDropdown ? 1 : 0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showDropdown)
        .padding(.horizontal)
    }
    
    // Helper function to get icon for body part
    private func bodyPartIcon(_ bodyPart: String) -> String {
        switch bodyPart {
        case "All": return "square.grid.2x2"
        case "Arms": return "figure.arms.open"
        case "Chest": return "heart.fill"
        case "Back": return "figure.strengthtraining.traditional"
        case "Shoulders": return "person.bust"
        case "Core": return "figure.core.training"
        case "Legs": return "figure.walk"
        default: return "figure.mixed.cardio"
        }
    }
}

// Header view with title and dropdown
struct WorkoutHeaderView: View {
    @Binding var selectedBodyPart: String?
    @Binding var showDropdown: Bool
    @Binding var confirmingTemplateId: UUID?
    
    var body: some View {
        VStack(spacing: 16) {
            // Title and filter button
            HStack {
                Text("Workouts")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        if confirmingTemplateId != nil {
                            confirmingTemplateId = nil
                        }
                        showDropdown.toggle()
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: bodyPartIcon(selectedBodyPart ?? "All"))
                            .font(.system(size: 16))
                            .foregroundColor(.blue)
                        
                        Text(selectedBodyPart ?? "All")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.gray)
                            .rotationEffect(.degrees(showDropdown ? 180 : 0))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6).opacity(0.15))
                    )
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
    }
    
    // Helper function to get icon for body part
    private func bodyPartIcon(_ bodyPart: String) -> String {
        switch bodyPart {
        case "All": return "square.grid.2x2"
        case "Arms": return "figure.arms.open"
        case "Chest": return "heart.fill"
        case "Back": return "figure.strengthtraining.traditional"
        case "Shoulders": return "person.bust"
        case "Core": return "figure.core.training"
        case "Legs": return "figure.walk"
        default: return "figure.mixed.cardio"
        }
    }
}

// Welcome text view
struct WorkoutWelcomeView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Ready to work out?")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Choose a template to get started")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.vertical, 16)
    }
}

// Dropdown overlay view
struct WorkoutDropdownView: View {
    var bodyParts: [String]
    @Binding var selectedBodyPart: String?
    @Binding var showDropdown: Bool
    @Binding var confirmingTemplateId: UUID?
    var bodyPartIcon: (String) -> String
    
    var body: some View {
        ZStack {
            // Semi-transparent backdrop
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation(.easeIn(duration: 0.2)) {
                        showDropdown = false
                    }
                }
            
            // Dropdown menu
            VStack(spacing: 0) {
                // Dropdown panel
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(bodyParts, id: \.self) { bodyPart in
                        Button(action: {
                            withAnimation(.easeIn(duration: 0.2)) {
                                selectedBodyPart = bodyPart == "All" ? nil : bodyPart
                                showDropdown = false
                                
                                // Dismiss any confirmations with smooth animation
                                if confirmingTemplateId != nil {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                        confirmingTemplateId = nil
                                    }
                                }
                            }
                        }) {
                            HStack {
                                Image(systemName: bodyPartIcon(bodyPart))
                                    .foregroundColor(bodyPart == selectedBodyPart || (bodyPart == "All" && selectedBodyPart == nil) ? .white : .gray)
                                    .frame(width: 30)
                                
                                Text(bodyPart)
                                    .font(.system(size: 16))
                                    .fontWeight(bodyPart == selectedBodyPart || (bodyPart == "All" && selectedBodyPart == nil) ? .semibold : .regular)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                if bodyPart == selectedBodyPart || (bodyPart == "All" && selectedBodyPart == nil) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                        .font(.system(size: 14))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                (bodyPart == selectedBodyPart || (bodyPart == "All" && selectedBodyPart == nil)) ?
                                    Color(red: 0.15, green: 0.15, blue: 0.25) :
                                    Color.clear
                            )
                        }
                        
                        if bodyPart != bodyParts.last {
                            Divider()
                                .background(Color.gray.opacity(0.2))
                                .padding(.horizontal, 0)
                        }
                    }
                }
                .background(Color(red: 0.1, green: 0.1, blue: 0.1))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(red: 0.2, green: 0.2, blue: 0.2), lineWidth: 1)
                )
                .padding(.horizontal, 16)
                .padding(.top, 65)
            
                Spacer()
            }
        }
        .transition(.opacity)
        .animation(.easeOut(duration: 0.2), value: showDropdown)
        .zIndex(10)
    }
}
