import Foundation
import SwiftUI

// DateFormatter extension for consistent date formatting
extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
    
    static let fullDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }()
}

// TimeInterval extension for duration formatting
extension TimeInterval {
    var formattedDuration: String {
        let hours = Int(self) / 3600
        let minutes = (Int(self) % 3600) / 60
        
        if hours > 0 {
            return "\(hours) hr \(minutes) min"
        } else {
            return "\(minutes) min"
        }
    }
}

// Color extension for custom app colors
extension Color {
    static let primaryApp = Color.blue
    static let secondaryApp = Color.green
    static let accentApp = Color.orange
    
    static let backgroundSecondary = Color(UIColor.secondarySystemBackground)
}

// View extension for reusable modifiers
extension View {
    func standardCard() -> some View {
        self
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(radius: 2)
            .padding(.horizontal)
    }
    
    func primaryButton() -> some View {
        self
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.primaryApp)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
    
    func secondaryButton() -> some View {
        self
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.primaryApp.opacity(0.1))
            .foregroundColor(.primaryApp)
            .cornerRadius(10)
    }
}
