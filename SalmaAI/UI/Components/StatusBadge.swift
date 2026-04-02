import SwiftUI

struct StatusBadge: View {
    let status: String
    var size: BadgeSize = .medium

    var body: some View {
        Text(displayLabel)
            .font(size == .small ? SalmaDesign.Typography.caption : SalmaDesign.Typography.captionMedium)
            .foregroundColor(statusColor)
            .padding(.horizontal, size == .small ? 8 : 12)
            .padding(.vertical, size == .small ? 2 : 4)
            .background(statusColor.opacity(0.15))
            .cornerRadius(SalmaDesign.Radius.full)
            .accessibilityLabel(displayLabel)
    }

    private var statusColor: Color {
        switch status.lowercased() {
        case "approved", "published": return SalmaDesign.Colors.success
        case "rejected": return SalmaDesign.Colors.danger
        case "pending", "flagged": return SalmaDesign.Colors.warning
        case "inreview", "in review": return SalmaDesign.Colors.info
        case "draft", "archived": return SalmaDesign.Colors.textSecondary
        default: return SalmaDesign.Colors.textSecondary
        }
    }

    private var displayLabel: String {
        let isArabic = LanguageManager.shared.currentLanguage == .arabic
        switch status.lowercased() {
        case "approved": return isArabic ? "مقبول" : "Approved"
        case "rejected": return isArabic ? "مرفوض" : "Rejected"
        case "pending": return isArabic ? "قيد الانتظار" : "Pending"
        case "inreview", "in review": return isArabic ? "قيد المراجعة" : "In Review"
        case "flagged": return isArabic ? "مُعلَّم" : "Flagged"
        case "draft": return isArabic ? "مسودة" : "Draft"
        case "published": return isArabic ? "منشورة" : "Published"
        case "archived": return isArabic ? "مؤرشفة" : "Archived"
        default: return status
        }
    }
}

enum BadgeSize {
    case small, medium
}
