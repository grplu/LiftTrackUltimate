import SwiftUI

// Add this file to your project

struct ExerciseDetailLoadingView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var isLoading = true
    let exercise: Exercise
    
    var body: some View {
        ZStack {
            // Background
            Color.black.edgesIgnoringSafeArea(.all)
            
            if isLoading {
                // Loading state
                VStack(spacing: 20) {
                    // Custom loading indicator
                    LoadingSpinner()
                    
                    Text("Loading \(exercise.name)...")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
            } else {
                // Show actual detail view once loaded
                ExerciseDetailView(exercise: exercise)
                    .environmentObject(dataManager)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: isLoading)
            }
        }
        .navigationTitle("Exercise Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Simulate loading time (remove in production)
            // This gives the UI time to transition and prepare data
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    isLoading = false
                }
            }
        }
    }
}

// A simple loading spinner
struct LoadingSpinner: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 4)
                .frame(width: 50, height: 50)
                .foregroundColor(Color.gray.opacity(0.3))
            
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(Color.blue, lineWidth: 4)
                .frame(width: 50, height: 50)
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                .animation(
                    Animation.linear(duration: 1)
                        .repeatForever(autoreverses: false),
                    value: isAnimating
                )
        }
        .onAppear {
            isAnimating = true
        }
    }
}
