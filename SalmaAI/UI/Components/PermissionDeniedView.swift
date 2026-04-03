import SwiftUI

struct PermissionDeniedView: View {
    let permissionType: PermissionType
    let onOpenSettings: () -> Void
    let onCancel: () -> Void

    enum PermissionType {
        case camera
        case photoLibrary

        var icon: String {
            switch self {
            case .camera: return "camera.fill"
            case .photoLibrary: return "photo.on.rectangle"
            }
        }

        var titleKey: String {
            switch self {
            case .camera: return "camera_permission_required"
            case .photoLibrary: return "photo_library_permission_required"
            }
        }

        var explanationKey: String {
            switch self {
            case .camera: return "camera_permission_explanation"
            case .photoLibrary: return "photo_library_permission_explanation"
            }
        }
    }

    var body: some View {
        VStack(spacing: SalmaDesign.Spacing.lg) {
            Spacer()

            Image(systemName: permissionType.icon)
                .font(.system(size: 56))
                .foregroundColor(SalmaDesign.Colors.textTertiary)

            Text(NSLocalizedString(permissionType.titleKey, bundle: .localized, comment: ""))
                .font(SalmaDesign.Typography.title2)
                .foregroundColor(SalmaDesign.Colors.textPrimary)

            Text(NSLocalizedString(permissionType.explanationKey, bundle: .localized, comment: ""))
                .font(SalmaDesign.Typography.body)
                .foregroundColor(SalmaDesign.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)

            VStack(spacing: SalmaDesign.Spacing.md) {
                SalmaButton(
                    title: L("go_to_settings"),
                    action: onOpenSettings
                )

                SalmaButton(
                    title: L("cancel"),
                    style: .ghost,
                    action: onCancel
                )
            }
            .padding(.horizontal, SalmaDesign.Spacing.xl)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SalmaDesign.Colors.background.ignoresSafeArea())
    }
}
