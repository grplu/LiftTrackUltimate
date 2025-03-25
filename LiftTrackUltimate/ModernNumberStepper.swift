import SwiftUI

struct ModernNumberStepper: View {
    var value: Int
    var range: ClosedRange<Int>
    var onChanged: (Int) -> Void
    var accentColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Decrement button
            Button(action: {
                if value > range.lowerBound {
                    onChanged(value - 1)
                    
                    // Haptic feedback
                    let impactLight = UIImpactFeedbackGenerator(style: .light)
                    impactLight.impactOccurred()
                }
            }) {
                Image(systemName: "minus")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(value <= range.lowerBound ? Color.gray.opacity(0.2) : accentColor.opacity(0.7))
                    )
            }
            .buttonStyle(ScaleButtonStyle())
            .disabled(value <= range.lowerBound)
            .opacity(value <= range.lowerBound ? 0.5 : 1)
            
            // Value display
            Text("\(value)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(minWidth: 40, alignment: .center)
            
            // Increment button
            Button(action: {
                if value < range.upperBound {
                    onChanged(value + 1)
                    
                    // Haptic feedback
                    let impactLight = UIImpactFeedbackGenerator(style: .light)
                    impactLight.impactOccurred()
                }
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(value >= range.upperBound ? Color.gray.opacity(0.2) : accentColor.opacity(0.7))
                    )
            }
            .buttonStyle(ScaleButtonStyle())
            .disabled(value >= range.upperBound)
            .opacity(value >= range.upperBound ? 0.5 : 1)
        }
    }
}

// Button style with scale animation
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
