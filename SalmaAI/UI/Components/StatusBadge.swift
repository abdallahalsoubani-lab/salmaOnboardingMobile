import SwiftUI

struct StatusBadge: View {
    let status: String

    var body: some View {
        Text(status)
            .font(SalmaDesign.Typography.captionMedium)
            .foregroundColor(foregroundColor)
            .padding(.horizontal, SalmaDesign.Spacing.sm)
            .padding(.vertical, SalmaDesign.Spacing.xs)
            .background(backgroundColor)
            .cornerRadius(SalmaDesign.Radius.full)
    }

    private var foregroundColor: Color {
        switch status.lowercased() {
        case "approved": return SalmaDesign.Colors.success
        case "rejected": return SalmaDesign.Colors.danger
        case "pending", "pending review": return SalmaDesign.Colors.warning
        default: return SalmaDesign.Colors.info
        }
    }

    private var backgroundColor: Color {
        foregroundColor.opacity(0.12)
    }
}
