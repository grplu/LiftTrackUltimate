import SwiftUI

struct BackgroundView: View {
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.2),
                    Color.black
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            // Watermark
            Image(systemName: "dumbbell.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)
                .foregroundColor(Color.white.opacity(0.03))
        }
    }
}

// Add the ViewModifier
struct BackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            BackgroundView()
            content
        }
    }
}

// Extension to make it easier to use
extension View {
    func withAppBackground() -> some View {
        self.modifier(BackgroundModifier())
    }
}

// Preview for the background
struct BackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Sample Content")
            .withAppBackground()
    }
}
