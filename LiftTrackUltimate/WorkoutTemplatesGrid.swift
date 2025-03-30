import SwiftUI

struct WorkoutTemplatesGridView: View {
    var filteredTemplates: [WorkoutTemplate]
    var animateCards: Bool
    @Binding var confirmingTemplateId: UUID?
    var onSelectTemplate: (WorkoutTemplate) -> Void
    var onEditTemplate: (WorkoutTemplate) -> Void
    var onDeleteTemplate: (WorkoutTemplate) -> Void
    var onCreateTemplate: () -> Void
    
    var body: some View {
        ScrollView {
            if filteredTemplates.isEmpty {
                // Empty state if no templates match filter
                WorkoutEmptyStateView(onCreateTemplate: onCreateTemplate)
            } else {
                // Grid layout similar to Templates tab
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(filteredTemplates) { template in
                        WorkoutTemplateCard(
                            template: template,
                            index: filteredTemplates.firstIndex(of: template) ?? 0,
                            appear: animateCards,
                            isConfirming: confirmingTemplateId == template.id,
                            onCardTap: {
                                // Toggle confirmation state for this card
                                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                impactFeedback.prepare()
                                impactFeedback.impactOccurred()
                                
                                // If a different card is showing confirmation, hide it first with quick animation
                                if let currentId = confirmingTemplateId, currentId != template.id {
                                    withAnimation(.easeOut(duration: 0.15)) {
                                        confirmingTemplateId = nil
                                    }
                                    
                                    // Then after a tiny delay, show the new confirmation
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                            confirmingTemplateId = template.id
                                        }
                                    }
                                } else {
                                    // Just toggle current card's confirmation
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                        confirmingTemplateId = confirmingTemplateId == template.id ? nil : template.id
                                    }
                                }
                            },
                            onStartTap: {
                                // Heavy haptic feedback
                                let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                                impactFeedback.prepare()
                                impactFeedback.impactOccurred()
                                
                                // Clear confirmation and select template
                                withAnimation {
                                    confirmingTemplateId = nil
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        onSelectTemplate(template)
                                    }
                                }
                            },
                            onEdit: {
                                onEditTemplate(template)
                            },
                            onDelete: {
                                onDeleteTemplate(template)
                            }
                        )
                    }
                    
                    // Create New Template card
                    CreateTemplateCard(
                        onTap: onCreateTemplate,
                        index: filteredTemplates.count,
                        appear: animateCards
                    )
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
            }
        }
        .refreshable {
            // Clear any confirmations and refresh
            confirmingTemplateId = nil
            
            // Pull to refresh - reload templates
            // No animation needed here since it will be redrawn
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

// Empty state view
struct WorkoutEmptyStateView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedBodyPart: String? = nil
    var onCreateTemplate: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.dashed")
                .font(.system(size: 40))
                .foregroundColor(.gray)
                .padding(.top, 40)
            
            Text(selectedBodyPart == nil || selectedBodyPart == "All" ? "No workout templates found" : "No templates for \(selectedBodyPart!)")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Create a new template or select a different body part")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Button(action: {
                selectedBodyPart = "All"
            }) {
                Text("Show All Templates")
                    .foregroundColor(.blue)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .stroke(Color.blue, lineWidth: 1)
                    )
            }
            .padding(.top, 8)
            .opacity(selectedBodyPart == "All" || selectedBodyPart == nil ? 0 : 1)
            
            Button(action: onCreateTemplate) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16))
                    
                    Text("Create Template")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .shadow(color: Color.blue.opacity(0.4), radius: 8, x: 0, y: 4)
            }
            .padding(.top, 24)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
    }
}
