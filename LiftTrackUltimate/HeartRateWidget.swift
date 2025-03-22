import SwiftUI
import HealthKit

struct HeartRateWidget: View {
    @StateObject private var viewModel = HeartRateWidgetViewModel()
    @State private var isAnimating = false
    @State private var showFullHeartRateView = false
    
    var body: some View {
        Button(action: {
            showFullHeartRateView = true
        }) {
            VStack {
                HStack(spacing: 16) {
                    // Heart Icon with Animation
                    Image(systemName: "heart.fill")
                        .font(.system(size: 28))
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
                    
                    VStack(alignment: .leading, spacing: 4) {
                        // Heart Rate Value
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(viewModel.isMonitoring ? "\(Int(viewModel.heartRate))" : "--")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("BPM")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                        }
                        
                        // Status Text
                        Text(viewModel.statusText)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .font(.system(size: 14))
                }
                .padding(16)
            }
            .background(Color.black)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            viewModel.requestAuthorization()
        }
        .sheet(isPresented: $showFullHeartRateView) {
            NavigationView {
                HeartRateView()
                    .navigationTitle("Heart Rate Monitor")
                    .navigationBarItems(trailing: Button("Close") {
                        showFullHeartRateView = false
                    })
                    .preferredColorScheme(.dark)
            }
        }
    }
}

class HeartRateWidgetViewModel: ObservableObject {
    private let healthKitManager = HealthKitManager.shared
    private var heartRateQuery: HKQuery?
    
    @Published var heartRate: Double = 0
    @Published var isMonitoring: Bool = false
    @Published var lastUpdate: Date? = nil
    @Published var watchConnected: Bool = false
    
    var statusText: String {
        if !isMonitoring {
            return "Tap to monitor heart rate"
        } else if watchConnected {
            return getZoneText()
        } else {
            return "Awaiting Apple Watch data"
        }
    }
    
    // Animation speed based on heart rate
    var animationSpeed: Double {
        if !isMonitoring || heartRate == 0 {
            return 1.0
        }
        
        let baseSpeed = 1.0
        let factor = heartRate / 60.0 // normalized to resting heart rate
        return max(0.5, min(baseSpeed * factor, 2.0))
    }
    
    private func getZoneText() -> String {
        switch heartRate {
        case 0..<60:
            return "Resting"
        case 60..<100:
            return "Light activity"
        case 100..<140:
            return "Cardio zone"
        case 140..<180:
            return "High intensity"
        default:
            return "Peak zone"
        }
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
        // Stop any existing query
        stopMonitoring()
        
        // Begin monitoring for real-time updates
        isMonitoring = true
        
        // Set up real HealthKit monitoring with a persistent query
        heartRateQuery = healthKitManager.setupContinuousHeartRateObserver { [weak self] heartRate in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                // Only update if the heart rate is non-zero
                if heartRate > 0 {
                    self.heartRate = heartRate
                    self.lastUpdate = Date()
                    self.watchConnected = true
                }
            }
        }
    }
    
    func stopMonitoring() {
        // Stop the existing query if it exists
        if let query = heartRateQuery {
            healthKitManager.stopQuery(query)
            heartRateQuery = nil
        }
        
        isMonitoring = false
        watchConnected = false
    }
    
    deinit {
        stopMonitoring()
    }
}
