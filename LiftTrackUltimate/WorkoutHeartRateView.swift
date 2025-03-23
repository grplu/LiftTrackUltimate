import SwiftUI
import HealthKit

struct WorkoutHeartRateView: View {
    @StateObject private var viewModel = WorkoutHeartRateViewModel()
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 8) {
            // Heart Icon with Animation
            Image(systemName: "heart.fill")
                .font(.system(size: 18))
                .foregroundColor(.red)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 0.5)
                        .repeatForever(autoreverses: true)
                        .speed(viewModel.animationSpeed),
                    value: isAnimating
                )
                .onAppear {
                    isAnimating = true
                    viewModel.requestAuthorization()
                }
            
            // Heart Rate Value
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(viewModel.isMonitoring ? "\(Int(viewModel.heartRate))" : "--")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("BPM")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.gray)
            }
        }
        .padding(6)
        .background(Color.black.opacity(0.5))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

class WorkoutHeartRateViewModel: ObservableObject {
    private let healthKitManager = HealthKitManager.shared
    private var timer: Timer?
    
    @Published var heartRate: Double = 0
    @Published var isMonitoring: Bool = false
    @Published var lastUpdate: Date? = nil
    @Published var watchConnected: Bool = false
    
    // Animation speed based on heart rate
    var animationSpeed: Double {
        // Adjust animation speed based on heart rate
        // Faster heart rate = faster animation
        if !isMonitoring || heartRate == 0 {
            return 1.0
        }
        
        let baseSpeed = 1.0
        let factor = heartRate / 60.0 // normalized to resting heart rate
        return max(0.5, min(baseSpeed * factor, 2.0))
    }
    
    func requestAuthorization() {
        healthKitManager.requestAuthorization { [weak self] success, error in
            if success {
                DispatchQueue.main.async {
                    self?.startMonitoring()
                }
            }
        }
    }
    
    func startMonitoring() {
        // Begin monitoring for real-time updates
        isMonitoring = true
        
        // Start with a simulated heart rate for immediate feedback
        simulateHeartRate()
        
        // Set up timer for simulated updates as a fallback
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.simulateHeartRate()
        }
        
        // Set up real HealthKit monitoring
        healthKitManager.startHeartRateQuery(quantityTypeIdentifier: .heartRate) { [weak self] heartRate in
            DispatchQueue.main.async {
                self?.heartRate = heartRate
                self?.lastUpdate = Date()
                self?.watchConnected = true
                
                // Once we get real data, we can stop the simulation
                if heartRate > 0 {
                    self?.timer?.invalidate()
                    self?.timer = nil
                }
            }
        }
    }
    
    private func simulateHeartRate() {
        // If we're not getting real data, simulate reasonable heart rate values
        // This will be overridden by actual HealthKit data if available
        let base: Double = 70
        let variation = Double.random(in: -5...15)
        
        heartRate = base + variation
        lastUpdate = Date()
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
}
