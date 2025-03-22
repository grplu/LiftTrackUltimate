import SwiftUI
import HealthKit

struct HeartRateView: View {
    @ObservedObject private var viewModel = HeartRateViewModel()
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Heart Rate Display
            VStack {
                if viewModel.isMonitoring {
                    // Heart Icon with Animation
                    Image(systemName: "heart.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.red)
                        .scaleEffect(isAnimating ? 1.2 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 0.5)
                                .repeatForever(autoreverses: true)
                                .speed(viewModel.animationSpeed),
                            value: isAnimating
                        )
                        .onAppear {
                            isAnimating = true
                        }
                    
                    // Heart Rate Value
                    HStack(alignment: .firstTextBaseline) {
                        Text("\(Int(viewModel.heartRate))")
                            .font(.system(size: 64, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("BPM")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.gray)
                            .padding(.leading, 4)
                    }
                    .padding(.top, 8)
                    
                    // Status Text
                    if viewModel.lastUpdate != nil {
                        Text("Last updated: \(viewModel.formattedLastUpdate)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                } else {
                    // Not Monitoring State
                    Image(systemName: "heart.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)
                    
                    Text("--")
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Waiting for heart rate data...")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(30)
            .background(Color(.systemGray6).opacity(0.3))
            .cornerRadius(20)
            
            // Heart Rate Zone
            if viewModel.isMonitoring {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Heart Rate Zone")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    HeartRateZoneView(heartRate: viewModel.heartRate)
                    
                    Text(viewModel.zoneDescription)
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.black)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
            
            // Action Button
            Button(action: {
                if viewModel.isMonitoring {
                    viewModel.stopMonitoring()
                } else {
                    viewModel.startMonitoring()
                }
            }) {
                HStack {
                    Image(systemName: viewModel.isMonitoring ? "stop.fill" : "play.fill")
                    Text(viewModel.isMonitoring ? "Stop Monitoring" : "Start Monitoring")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.isMonitoring ? Color.red : Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            // Apple Watch Status
            if !viewModel.watchConnected {
                HStack {
                    Image(systemName: "applewatch.radiowaves.left.and.right")
                        .foregroundColor(.orange)
                    Text("For real-time data, wear your Apple Watch")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .onAppear {
            viewModel.requestAuthorization()
        }
        .onDisappear {
            viewModel.stopMonitoring()
        }
    }
}

struct HeartRateZoneView: View {
    let heartRate: Double
    
    private var zoneColor: Color {
        switch heartRate {
        case 0..<60:
            return .blue
        case 60..<100:
            return .green
        case 100..<140:
            return .yellow
        case 140..<180:
            return .orange
        default:
            return .red
        }
    }
    
    private var zonePercentage: Double {
        min(max(0, heartRate / 220.0), 1.0)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background Bar
                Rectangle()
                    .fill(Color(.systemGray4))
                    .frame(height: 16)
                    .cornerRadius(8)
                
                // Progress Bar
                Rectangle()
                    .fill(zoneColor)
                    .frame(width: geometry.size.width * zonePercentage, height: 16)
                    .cornerRadius(8)
            }
        }
        .frame(height: 16)
    }
}

class HeartRateViewModel: ObservableObject {
    private let healthKitManager = HealthKitManager.shared
    private var timer: Timer?
    
    @Published var heartRate: Double = 0
    @Published var isMonitoring: Bool = false
    @Published var lastUpdate: Date? = nil
    @Published var watchConnected: Bool = false
    
    // Heart rate zone-related computed properties
    var zoneDescription: String {
        switch heartRate {
        case 0..<60:
            return "Resting: Your heart rate is in the resting zone"
        case 60..<100:
            return "Light: Low intensity activity zone"
        case 100..<140:
            return "Moderate: Cardio training zone"
        case 140..<180:
            return "Hard: High intensity training zone"
        default:
            return "Maximum: Peak performance zone"
        }
    }
    
    // Animation speed based on heart rate
    var animationSpeed: Double {
        // Adjust animation speed based on heart rate
        // Faster heart rate = faster animation
        let baseSpeed = 1.0
        let factor = heartRate / 60.0 // normalized to resting heart rate
        return max(0.5, min(baseSpeed * factor, 2.0))
    }
    
    var formattedLastUpdate: String {
        guard let lastUpdate = lastUpdate else { return "" }
        
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        
        return formatter.string(from: lastUpdate)
    }
    
    func requestAuthorization() {
        healthKitManager.requestAuthorization { success, error in
            DispatchQueue.main.async {
                if success {
                    // Automatically start monitoring when authorized
                    self.watchConnected = true
                    self.startMonitoring()
                } else {
                    print("Failed to get authorization: \(error?.localizedDescription ?? "unknown error")")
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
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.simulateHeartRate()
        }
        
        // Set up real HealthKit monitoring
        healthKitManager.startHeartRateQuery(quantityTypeIdentifier: .heartRate) { [weak self] heartRate in
            DispatchQueue.main.async {
                self?.heartRate = heartRate
                self?.lastUpdate = Date()
                self?.watchConnected = true
                
                // Invalidate timer since we're getting real data
                self?.timer?.invalidate()
            }
        }
    }
    
    func stopMonitoring() {
        isMonitoring = false
        timer?.invalidate()
        timer = nil
    }
    
    private func simulateHeartRate() {
        // If we're not getting real data, simulate reasonable heart rate values
        // This will be overridden by actual HealthKit data if available
        if !watchConnected {
            let base: Double = isMonitoring ? 70 : 0
            let variation = Double.random(in: -5...15)
            
            heartRate = base + variation
            lastUpdate = Date()
        }
    }
    
    deinit {
        stopMonitoring()
    }
}

struct HeartRateView_Previews: PreviewProvider {
    static var previews: some View {
        HeartRateView()
            .preferredColorScheme(.dark)
    }
}
