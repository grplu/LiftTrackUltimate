import SwiftUI

/// Design system for the LIFT app
/// Provides consistent colors, typography, and layout guidelines
struct LiftTheme {
    // MARK: - Colors
    struct Colors {
        // Primary brand colors
        static let primary = Color.black
        static let secondary = Color.white
        
        // Background colors
        static let background = Color.white
        static let secondaryBackground = Color(UIColor.systemGray6)
        static let darkBackground = Color.black
        
        // Content colors
        static let primaryContent = Color.black
        static let secondaryContent = Color.gray
        static let tertiaryContent = Color(UIColor.systemGray2)
        
        // UI element colors
        static let accent = Color.black
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
        
        // Card and surface colors
        static let surface = Color.white
        static let surfaceBorder = Color(UIColor.systemGray5)
    }
    
    // MARK: - Typography
    struct Typography {
        // Title text styles
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .default)
        static let title = Font.system(size: 28, weight: .bold, design: .default)
        static let subtitle = Font.system(size: 22, weight: .semibold, design: .default)
        
        // Body text styles
        static let bodyLarge = Font.system(size: 17, weight: .medium, design: .default)
        static let body = Font.system(size: 16, weight: .regular, design: .default)
        static let bodySmall = Font.system(size: 14, weight: .regular, design: .default)
        
        // Detail text styles
        static let caption = Font.system(size: 12, weight: .regular, design: .default)
        static let captionBold = Font.system(size: 12, weight: .semibold, design: .default)
        
        // Button text styles
        static let button = Font.system(size: 16, weight: .semibold, design: .default)
        static let smallButton = Font.system(size: 14, weight: .medium, design: .default)
    }
    
    // MARK: - Layout
    struct Layout {
        // Standard spacing values
        static let spacing2 = 2.0
        static let spacing4 = 4.0
        static let spacing8 = 8.0
        static let spacing12 = 12.0
        static let spacing16 = 16.0
        static let spacing20 = 20.0
        static let spacing24 = 24.0
        static let spacing32 = 32.0
        static let spacing48 = 48.0
        
        // Padding values
        static let paddingSmall = 8.0
        static let paddingMedium = 16.0
        static let paddingLarge = 24.0
        
        // Corner radius values
        static let cornerRadiusSmall = 4.0
        static let cornerRadiusMedium = 8.0
        static let cornerRadiusLarge = 12.0
        static let cornerRadiusExtraLarge = 16.0
        
        // Border widths
        static let borderWidthThin = 0.5
        static let borderWidthRegular = 1.0
        static let borderWidthThick = 2.0
        
        // Shadows
        static let shadowSmall = Shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        static let shadowMedium = Shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        static let shadowLarge = Shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Animation
    struct Animation {
        static let defaultAnimation = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let quickAnimation = SwiftUI.Animation.easeOut(duration: 0.2)
        static let springAnimation = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.8)
    }
}

// MARK: - Helper Components
// Shadow struct for easier shadow application
struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    
    func apply<T: View>(to view: T) -> some View {
        view.shadow(color: color, radius: radius, x: x, y: y)
    }
}

// MARK: - View Extensions
extension View {
    // Apply card styling
    func liftCardStyle() -> some View {
        self
            .padding(LiftTheme.Layout.paddingMedium)
            .background(LiftTheme.Colors.surface)
            .cornerRadius(LiftTheme.Layout.cornerRadiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: LiftTheme.Layout.cornerRadiusMedium)
                    .stroke(LiftTheme.Colors.surfaceBorder, lineWidth: LiftTheme.Layout.borderWidthThin)
            )
            .shadow(
                color: LiftTheme.Layout.shadowSmall.color,
                radius: LiftTheme.Layout.shadowSmall.radius,
                x: LiftTheme.Layout.shadowSmall.x,
                y: LiftTheme.Layout.shadowSmall.y
            )
    }
    
    // Apply primary button styling
    func liftPrimaryButtonStyle() -> some View {
        self
            .font(LiftTheme.Typography.button)
            .foregroundColor(LiftTheme.Colors.secondary)
            .padding(.vertical, LiftTheme.Layout.paddingSmall)
            .padding(.horizontal, LiftTheme.Layout.paddingMedium)
            .background(LiftTheme.Colors.primary)
            .cornerRadius(LiftTheme.Layout.cornerRadiusSmall)
    }
    
    // Apply secondary button styling
    func liftSecondaryButtonStyle() -> some View {
        self
            .font(LiftTheme.Typography.button)
            .foregroundColor(LiftTheme.Colors.primary)
            .padding(.vertical, LiftTheme.Layout.paddingSmall)
            .padding(.horizontal, LiftTheme.Layout.paddingMedium)
            .background(LiftTheme.Colors.background)
            .overlay(
                RoundedRectangle(cornerRadius: LiftTheme.Layout.cornerRadiusSmall)
                    .stroke(LiftTheme.Colors.primary, lineWidth: LiftTheme.Layout.borderWidthRegular)
            )
            .cornerRadius(LiftTheme.Layout.cornerRadiusSmall)
    }
}
