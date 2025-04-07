import SwiftUI

struct WorkoutTemplatesGridView: View {
    var filteredTemplates: [WorkoutTemplate]
    var animateCards: Bool
    @Binding var confirmingTemplateId: UUID?
    var onSelectTemplate: (WorkoutTemplate) -> Void
    var onEditTemplate: (WorkoutTemplate) -> Void
    var onDeleteTemplate: (WorkoutTemplate) -> Void
    var onCreateTemplate: () -> Void
    
    // Grid layout configuration
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            if filteredTemplates.isEmpty {
                // Empty state if no templates match filter
                WorkoutEmptyStateView(onCreateTemplate: onCreateTemplate)
            } else {
                // Grid layout similar to Templates tab
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(filteredTemplates) { template in
                        WorkoutTemplateCard(
                            template: template,
                            index: filteredTemplates.firstIndex(of: template) ?? 0,
                            appear: animateCards,
                            isConfirming: confirmingTemplateId == template.id,
                            onCardTap: {
                                onSelectTemplate(template)
                            },
                            onStartTap: {
                                onSelectTemplate(template)
                            },
                            onEdit: {
                                onEditTemplate(template)
                            },
                            onDelete: {
                                onDeleteTemplate(template)
                            }
                        )
                    }
                    
                    // Create template card
                    CreateTemplateCard(onCreateTemplate: onCreateTemplate)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        }
        .scrollDismissesKeyboard(.immediately)
    }
}

// Empty state view
struct WorkoutEmptyStateView: View {
    var onCreateTemplate: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "dumbbell.fill")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("No templates found")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Create a template or show all templates")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Button(action: onCreateTemplate) {
                Text("Create Template")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// Create template card
struct CreateTemplateCard: View {
    var onCreateTemplate: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onCreateTemplate) {
            VStack(alignment: .leading, spacing: 16) {
                // Icon and title row
                HStack(alignment: .center, spacing: 12) {
                    // Badge icon with gradient background
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.blue.opacity(0.5)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    }
                    
                    // Template name
                    Text("Create Template")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Stats row (empty for create card)
                VStack(spacing: 12) {
                    // Empty space to maintain layout
                    HStack {
                        Spacer()
                    }
                    
                    // Hint text
                    HStack {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 12))
                            .foregroundColor(Color.blue)
                        
                        Text("Add a new template")
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
                            .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                    )
            )
            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}


