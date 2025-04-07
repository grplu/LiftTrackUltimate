import SwiftUI

// Scale button style with animation (renamed to avoid conflicts)
public struct ScalableButtonStyle: ButtonStyle {
    public var scaleAmount: CGFloat
    
    public init(scaleAmount: CGFloat = 0.95) {
        self.scaleAmount = scaleAmount
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scaleAmount : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

// Extension for easier usage
public extension ButtonStyle where Self == ScalableButtonStyle {
    static var scalable: ScalableButtonStyle {
        return ScalableButtonStyle()
    }
}
