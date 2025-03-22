import SwiftUI

/// A styled text field component that follows the LIFT design system
struct LiftTextInput: View {
    var title: String
    var placeholder: String
    var icon: String? = nil
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: LiftTheme.Layout.spacing8) {
            Text(title)
                .font(LiftTheme.Typography.captionBold)
                .foregroundColor(LiftTheme.Colors.primaryContent)
            
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(LiftTheme.Colors.tertiaryContent)
                        .frame(width: 24)
                }
                
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .font(LiftTheme.Typography.body)
                        .keyboardType(keyboardType)
                } else {
                    TextField(placeholder, text: $text)
                        .font(LiftTheme.Typography.body)
                        .keyboardType(keyboardType)
                }
            }
            .padding(LiftTheme.Layout.paddingSmall)
            .background(LiftTheme.Colors.secondaryBackground)
            .cornerRadius(LiftTheme.Layout.cornerRadiusSmall)
        }
    }
}

// Preview provider for the component
struct LiftTextInput_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            LiftTextInput(
                title: "Name",
                placeholder: "Enter your name",
                icon: "person.fill",
                text: .constant("John Doe")
            )
            
            LiftTextInput(
                title: "Password",
                placeholder: "Enter your password",
                icon: "lock.fill",
                text: .constant(""),
                isSecure: true
            )
            
            LiftTextInput(
                title: "Weight (kg)",
                placeholder: "Enter your weight",
                icon: "scalemass",
                text: .constant("75"),
                keyboardType: .decimalPad
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
