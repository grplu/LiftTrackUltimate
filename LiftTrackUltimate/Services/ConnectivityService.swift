import Foundation
import WatchConnectivity
import Combine

class ConnectivityService: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = ConnectivityService()
    
    @Published private(set) var isReachable = false
    @Published private(set) var isPaired = false
    @Published private(set) var error: Error?
    
    private let session: WCSession
    private var messageQueue: [(message: [String: Any], completion: ((Error?) -> Void)?)] = []
    
    private override init() {
        self.session = WCSession.default
        super.init()
        
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }
    
    // MARK: - WCSessionDelegate Methods
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isPaired = activationState == .activated
            self.error = error
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isPaired = false
        }
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // Begin the activation process for the new Apple Watch.
        WCSession.default.activate()
    }
    
    #if os(iOS)
    func sessionWatchStateDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isPaired = session.isPaired
        }
    }
    #endif
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
            if session.isReachable {
                self.processMessageQueue()
            }
        }
    }
    
    // MARK: - Message Handling
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        handleReceivedMessage(message)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        handleReceivedMessage(message)
        replyHandler(["status": "received"])
    }
    
    private func handleReceivedMessage(_ message: [String: Any]) {
        DispatchQueue.main.async {
            if let workoutData = message["workout"] as? Data {
                NotificationCenter.default.post(name: .workoutReceived, object: workoutData)
            }
            if let heartRate = message["heartRate"] as? Double {
                NotificationCenter.default.post(name: .heartRateReceived, object: heartRate)
            }
            if let workoutState = message["workoutState"] as? String {
                NotificationCenter.default.post(name: .workoutStateReceived, object: workoutState)
            }
        }
    }
    
    // MARK: - Sending Messages
    func sendMessage(_ message: [String: Any], completion: ((Error?) -> Void)? = nil) {
        guard WCSession.isSupported() else {
            completion?(ConnectivityError.notSupported)
            return
        }
        
        if session.isReachable {
            session.sendMessage(message, replyHandler: { _ in
                completion?(nil)
            }, errorHandler: { error in
                completion?(error)
            })
        } else {
            messageQueue.append((message: message, completion: completion))
        }
    }
    
    private func processMessageQueue() {
        while !messageQueue.isEmpty {
            let item = messageQueue.removeFirst()
            sendMessage(item.message, completion: item.completion)
        }
    }
    
    // MARK: - Workout Sync Methods
    func syncWorkout(_ workout: AppWorkout) {
        guard let data = try? JSONEncoder().encode(workout) else { return }
        sendMessage(["workout": data])
    }
    
    func syncHeartRate(_ heartRate: Double) {
        sendMessage(["heartRate": heartRate])
    }
    
    func syncWorkoutState(_ state: String) {
        sendMessage(["workoutState": state])
    }
}

// MARK: - Errors
enum ConnectivityError: Error {
    case notSupported
    case notReachable
    case encodingFailed
    case sendFailed
}

// MARK: - Notification Names
extension Notification.Name {
    static let workoutReceived = Notification.Name("workoutReceived")
    static let heartRateReceived = Notification.Name("heartRateReceived")
    static let workoutStateReceived = Notification.Name("workoutStateReceived")
} 