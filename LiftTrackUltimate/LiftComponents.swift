import SwiftUI

// MARK: - Button Components

/// Standard LIFT button component with multiple styles
struct LiftButton: View {
    enum ButtonStyle {
        case primary, secondary, outline, text, destructive
    }
    
    var title: String
    var icon: String? = nil
    var style: ButtonStyle = .primary
    var fullWidth: Bool = false
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: LiftTheme.Layout.spacing8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                
                Text(title)
                    .font(LiftTheme.Typography.button)
                    .lineLimit(1)
            }
            .padding(.vertical, LiftTheme.Layout.paddingSmall)
            .padding(.horizontal, LiftTheme.Layout.paddingMedium)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(LiftTheme.Layout.cornerRadiusSmall)
            .overlay(
                RoundedRectangle(cornerRadius: LiftTheme.Layout.cornerRadiusSmall)
                    .stroke(borderColor, lineWidth: style == .outline ? LiftTheme.Layout.borderWidthRegular : 0)
            )
        }
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return LiftTheme.Colors.primary
        case .secondary:
            return LiftTheme.Colors.secondaryBackground
        case .outline, .text:
            return Color.clear
        case .destructive:
            return LiftTheme.Colors.error
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary:
            return LiftTheme.Colors.secondary
        case .secondary, .outline:
            return LiftTheme.Colors.primary
        case .text:
            return LiftTheme.Colors.accent
        case .destructive:
            return LiftTheme.Colors.secondary
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .outline:
            return LiftTheme.Colors.primary
        default:
            return Color.clear
        }
    }
}

// MARK: - Card Components

/// Standard card component with title and content
struct LiftCard<Content: View>: View {
    var title: String?
    var icon: String?
    var trailingView: AnyView? = nil
    var content: Content
    
    init(title: String? = nil, icon: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    init<T: View>(title: String? = nil, icon: String? = nil, trailingView: T, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.trailingView = AnyView(trailingView)
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: LiftTheme.Layout.spacing16) {
            if let title = title {
                HStack {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(LiftTheme.Colors.primary)
                    }
                    
                    Text(title)
                        .font(LiftTheme.Typography.subtitle)
                        .foregroundColor(LiftTheme.Colors.primaryContent)
                    
                    Spacer()
                    
                    if let trailingView = trailingView {
                        trailingView
                    }
                }
            }
            
            content
        }
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
}

// MARK: - Stat Item Component

/// Component for displaying a statistic with label and value
struct LiftStatItem: View {
    var label: String
    var value: String
    var iconName: String? = nil
    
    var body: some View {
        VStack(spacing: LiftTheme.Layout.spacing4) {
            Text(label)
                .font(LiftTheme.Typography.caption)
                .foregroundColor(LiftTheme.Colors.secondaryContent)
                .multilineTextAlignment(.center)
            
            HStack(spacing: LiftTheme.Layout.spacing4) {
                if let iconName = iconName {
                    Image(systemName: iconName)
                        .font(.system(size: 14))
                        .foregroundColor(LiftTheme.Colors.primaryContent)
                }
                
                Text(value)
                    .font(LiftTheme.Typography.bodyLarge)
                    .fontWeight(.bold)
                    .foregroundColor(LiftTheme.Colors.primaryContent)
            }
        }
        .padding(.vertical, LiftTheme.Layout.paddingSmall)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Divider Component

/// Styled divider component
struct LiftDivider: View {
    var body: some View {
        Rectangle()
            .fill(LiftTheme.Colors.surfaceBorder)
            .frame(height: 1)
    }
}

// MARK: - Badge Component

/// Badge for displaying tags, categories, or statuses
struct LiftBadge: View {
    var text: String
    var color: Color = LiftTheme.Colors.primary
    var filled: Bool = false
    
    var body: some View {
        Text(text)
            .font(LiftTheme.Typography.captionBold)
            .foregroundColor(filled ? LiftTheme.Colors.secondary : color)
            .padding(.horizontal, LiftTheme.Layout.paddingSmall)
            .padding(.vertical, 4)
            .background(filled ? color : color.opacity(0.1))
            .cornerRadius(LiftTheme.Layout.cornerRadiusSmall)
    }
}

// MARK: - Section Header Component

/// Standard section header
struct LiftSectionHeader: View {
    var title: String
    var showButton: Bool = false
    var buttonTitle: String = "See All"
    var buttonAction: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            Text(title)
                .font(LiftTheme.Typography.subtitle)
                .foregroundColor(LiftTheme.Colors.primaryContent)
            
            Spacer()
            
            if showButton, let buttonAction = buttonAction {
                Button(action: buttonAction) {
                    Text(buttonTitle)
                        .font(LiftTheme.Typography.smallButton)
                        .foregroundColor(LiftTheme.Colors.accent)
                }
            }
        }
        .padding(.horizontal, LiftTheme.Layout.paddingMedium)
        .padding(.vertical, LiftTheme.Layout.paddingSmall)
    }
}

// MARK: - Input Field Component

/// Styled text input field
struct LiftTextField: View {
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

// MARK: - Tab Bar Components

/// Custom tab bar item
struct LiftTabItem: View {
    let icon: String
    let activeIcon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? activeIcon : icon)
                    .font(.system(size: 22, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? LiftTheme.Colors.primary : LiftTheme.Colors.tertiaryContent)
                    .frame(height: 24)
                
                Text(label)
                    .font(.system(size: 10, weight: isSelected ? .medium : .regular))
                    .foregroundColor(isSelected ? LiftTheme.Colors.primary : LiftTheme.Colors.tertiaryContent)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

/// Progress bar component
struct LiftProgressBar: View {
    var progress: Double // 0.0 to 1.0
    var color: Color = LiftTheme.Colors.primary
    var height: CGFloat = 8
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(LiftTheme.Colors.secondaryBackground)
                    .frame(width: geometry.size.width, height: height)
                    .cornerRadius(height / 2)
                
                Rectangle()
                    .fill(color)
                    .frame(width: min(max(0, CGFloat(progress) * geometry.size.width), geometry.size.width), height: height)
                    .cornerRadius(height / 2)
            }
        }
        .frame(height: height)
    }
}
