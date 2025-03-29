import SwiftUI

// Background view with tap detection
struct WorkoutBackgroundView: View {
    @Binding var confirmingTemplateId: UUID?
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.black, Color(hex: "101010")]),
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

// Header view with title and dropdown
struct WorkoutHeaderView: View {
    @Binding var selectedBodyPart: String?
    @Binding var showDropdown: Bool
    @Binding var confirmingTemplateId: UUID?
    
    var body: some View {
        HStack {
            Text("Workout")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            // Dropdown menu button
            Button(action: {
                // Dismiss any confirmation when opening dropdown
                if confirmingTemplateId != nil {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        confirmingTemplateId = nil
                    }
                }
                
                withAnimation(.easeOut(duration: 0.2)) {
                    showDropdown.toggle()
                }
            }) {
                HStack(spacing: 6) {
                    Text(selectedBodyPart ?? "All")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.gray)
                        .rotationEffect(Angle(degrees: showDropdown ? 180 : 0))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color(red: 0.15, green: 0.15, blue: 0.15))
                )
            }
        }
        .padding(.horizontal)
        .padding(.top, 12)
        .padding(.bottom, 16)
        .zIndex(2)
    }
}

// Welcome header view
struct WorkoutWelcomeView: View {
    var body: some View {
        VStack(spacing: 4) {
            Text("Pick a Workout to Start")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Text("Select a template below to get started")
                .font(.system(size: 14))
                .foregroundColor(Color(.systemGray))
        }
        .padding(.top, 16)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity)
        .background(
            Rectangle()
                .fill(Color.clear)
                .frame(height: 1)
                .background(Color(hex: "3A3F42"))
                .padding(.top, 68)
        )
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
