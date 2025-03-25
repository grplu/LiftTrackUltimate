import SwiftUI

struct ProgressSteps: View {
    var currentStep: Int
    
    var body: some View {
        HStack {
            ForEach(0..<3) { step in
                Capsule()
                    .fill(step <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                    .frame(height: 4)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
    }
}
