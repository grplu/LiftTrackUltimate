import WatchConnectivity

class ConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = ConnectivityManager()
    
    private var session: WCSession?
    
    override init() {
        super.init()
        
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }
    
    // MARK: WCSessionDelegate methods
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Session activation completed: \(activationState.rawValue)")
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Session became inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("Session deactivated")
    }
    #endif
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // Handle received messages from counterpart device
        print("Received message: \(message)")
    }
    
    // Methods to send data between devices
    func sendWorkoutToWatch(_ workout: Workout) {
        guard let session = session, session.isReachable else { return }
        
        // In a real app, we'd convert the workout to a dictionary and send it
        let workoutDict: [String: Any] = [
            "name": workout.name,
            "date": workout.date,
            "duration": workout.duration
        ]
        
        session.sendMessage(workoutDict, replyHandler: nil)
    }
    
    func sendWorkoutFromWatch(_ workoutName: String, duration: TimeInterval, calories: Double) {
        guard let session = session, session.isReachable else { return }
        
        let workoutDict: [String: Any] = [
            "name": workoutName,
            "duration": duration,
            "calories": calories
        ]
        
        session.sendMessage(workoutDict, replyHandler: nil)
    }
}
