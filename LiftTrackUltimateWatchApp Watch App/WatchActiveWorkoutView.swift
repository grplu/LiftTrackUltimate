import SwiftUI
import HealthKit

struct WatchActiveWorkoutView: View {
    var workoutType: String
    var onEnd: () -> Void
    
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer? = nil
    @State private var heartRate: Double = 0
    @State private var caloriesBurned: Double = 0
    @State private var isPaused = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                // Workout type and timer
                Text(workoutType)
                    .font(.headline)
                
                Text(formattedElapsedTime())
                    .font(.system(size: 40, design: .monospaced))
                    .fontWeight(.bold)
                
                Divider()
                
                // Heart rate and calories
                HStack {
                    VStack {
                        Text("\(Int(heartRate))")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("BPM")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Divider()
                    
                    VStack {
                        Text("\(Int(caloriesBurned))")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("CAL")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                
                Divider()
                
                // Control buttons
                HStack {
                    Button(action: {
                        isPaused.toggle()
                        if isPaused {
                            pauseTimer()
                        } else {
                            resumeTimer()
                        }
                    }) {
                        Image(systemName: isPaused ? "play.fill" : "pause.fill")
                            .font(.title3)
                            .padding(8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        onEnd()
                    }) {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .padding(8)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                }
            }
            .padding()
        }
        .onAppear {
            startTimer()
            startUpdatingMetrics()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if !isPaused {
                elapsedTime += 1
            }
        }
    }
    
    private func pauseTimer() {
        // Just set isPaused flag, the timer continues to run
    }
    
    private func resumeTimer() {
        // Reset isPaused flag to continue incrementing elapsedTime
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func startUpdatingMetrics() {
        // In a real app, this would connect to HealthKit
        // For demo purposes, we'll just simulate changing values
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            // Simulate heart rate between 80-160
            heartRate = Double.random(in: 80...160)
            
            // Simulate increasing calories
            caloriesBurned += Double.random(in: 1...5)
        }
    }
    
    private func formattedElapsedTime() -> String {
        let hours = Int(elapsedTime) / 3600
        let minutes = (Int(elapsedTime) % 3600) / 60
        let seconds = Int(elapsedTime) % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
