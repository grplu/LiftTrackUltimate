import SwiftUI

struct ExerciseRow: View {
    var exercise: TemplateExercise
    var index: Int
    var onRemove: () -> Void
    var onEditSets: (Int) -> Void
    var onEditReps: (Int) -> Void
    
    @State private var isExpanded = false
    @State private var isNewlyAdded = true
    @State private var animateGlow = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Exercise header
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            }) {
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
                            .frame(width: 36, height: 36)
                        
                        Text("\(index + 1)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(exercise.exercise.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        // Handle optional safely
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
                    
                    // Expand/Collapse button
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                        .frame(width: 28, height: 28)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Circle())
                    
                    // Remove button
                    Button(action: {
                        withAnimation(.spring()) {
                            onRemove()
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 28, height: 28)
                            .background(Color.red.opacity(0.7))
                            .clipShape(Circle())
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Expanded content (sets & reps)
            if isExpanded {
                VStack(spacing: 24) {
                    Divider()
                        .background(Color.gray.opacity(0.3))
                        .padding(.horizontal)
                    
                    // Sets selector
                    HStack {
                        HStack(spacing: 10) {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.blue)
                            
                            Text("Sets")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        // Modern number stepper
                        ModernNumberStepper(
                            value: exercise.targetSets,
                            range: 1...10,
                            onChanged: onEditSets,
                            accentColor: .blue
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // Reps selector - safely handle optional
                    HStack {
                        HStack(spacing: 10) {
                            Image(systemName: "repeat")
                                .font(.system(size: 16))
                                .foregroundColor(.green)
                            
                            Text("Reps")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        // Modern number stepper with safe unwrapping
                        ModernNumberStepper(
                            value: exercise.targetReps ?? 0, // Default to 0 if nil
                            range: 1...50,
                            onChanged: onEditReps,
                            accentColor: .green
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    Divider()
                        .background(Color.gray.opacity(0.3))
                        .padding(.horizontal)
                    
                    // Optional instructions button
                    Button(action: {
                        // Show instructions in a separate sheet or popup
                    }) {
                        HStack {
                            Image(systemName: "info.circle")
                                .font(.system(size: 14))
                            
                            Text("View Exercise Instructions")
                                .font(.subheadline)
                        }
                        .foregroundColor(.blue)
                        .padding(.vertical, 10)
                    }
                }
                .padding(.vertical, 8)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(.systemGray6).opacity(0.25),
                            Color(.systemGray6).opacity(0.2)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            animateGlow ? Color.blue.opacity(0.6) : Color.white.opacity(0.1),
                            lineWidth: animateGlow ? 2 : 1
                        )
                )
                .shadow(
                    color: animateGlow ? Color.blue.opacity(0.3) : Color.black.opacity(0.1),
                    radius: animateGlow ? 8 : 4
                )
        )
        .scaleEffect(isNewlyAdded ? 0.98 : 1.0)
        .onAppear {
            // Entrance animation
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isNewlyAdded = false
            }
            
            // Highlight glow effect for newly added exercises
            withAnimation(.easeInOut(duration: 0.8).repeatCount(1, autoreverses: true)) {
                animateGlow = true
            }
            
            // Reset animations after some time
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    animateGlow = false
                }
            }
        }
    }
}
