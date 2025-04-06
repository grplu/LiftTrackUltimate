import Foundation
import UserNotifications
import Combine
import SwiftUI

class NotificationService: NSObject, ObservableObject {
    static let shared = NotificationService()
    
    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private var cancellables = Set<AnyCancellable>()
    
    private override init() {
        super.init()
        notificationCenter.delegate = self
        Task {
            await checkAuthorizationStatus()
            // Request authorization if not determined
            if authorizationStatus == .notDetermined {
                await requestAuthorization()
            }
        }
    }
    
    // MARK: - Authorization
    func requestAuthorization() async {
        do {
            // Remove .provisional since we're only using local notifications
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run {
                self.authorizationStatus = granted ? .authorized : .denied
            }
        } catch {
            print("Error requesting authorization: \(error.localizedDescription)")
            await MainActor.run {
                self.authorizationStatus = .denied
            }
        }
    }
    
    private func checkAuthorizationStatus() async {
        let settings = await notificationCenter.notificationSettings()
        await MainActor.run {
            self.authorizationStatus = settings.authorizationStatus
        }
    }
    
    // MARK: - Local Notifications
    func scheduleWorkoutReminder(at date: Date, workoutName: String) {
        let content = UNMutableNotificationContent()
        content.title = "Workout Reminder"
        content.body = "Time for your \(workoutName) workout!"
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "workoutReminder-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request)
    }
    
    func scheduleRestReminder(minutes: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Rest Timer"
        content.body = "Time to start your next set!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(minutes * 60),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "restTimer-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request)
    }
    
    func scheduleAchievementNotification(title: String, description: String) {
        let content = UNMutableNotificationContent()
        content.title = "Achievement Unlocked! 🏆"
        content.body = "\(title): \(description)"
        content.sound = .default
        
        // Show achievement notification immediately
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "achievement-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request)
    }
    
    // MARK: - Notification Management
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
    func cancelNotification(withIdentifier identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        return [.banner, .sound]
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        // Handle notification response based on identifier
        let identifier = response.notification.request.identifier
        if identifier.starts(with: "workoutReminder") {
            NotificationCenter.default.post(name: .workoutCompletionTapped, object: nil)
        } else if identifier.starts(with: "achievement") {
            NotificationCenter.default.post(name: .achievementTapped, object: nil)
        }
    }
} 