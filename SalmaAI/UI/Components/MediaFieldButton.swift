import SwiftUI

struct MediaFieldButton: View {
    let label: String
    var fieldType: FieldType = .photo
    var capturedImage: UIImage?
    var capturedFileName: String?
    var capturedFileSize: Int?
    var errorMessage: String?
    var isRequired: Bool = false
    var sourceType: CaptureSource = .cameraAndGallery
    var onCapture: () -> Void = {}
    var onGallery: () -> Void = {}
    var onFilePick: () -> Void = {}
    var onPreview: () -> Void = {}
    var onRemove: () -> Void = {}

    @State private var showSourceSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: SalmaDesign.Spacing.xs) {
            // Label
            HStack(spacing: 2) {
                Text(label)
                    .font(SalmaDesign.Typography.callout)
                    .foregroundColor(SalmaDesign.Colors.textSecondary)
                if isRequired {
                    Text("*")
                        .font(SalmaDesign.Typography.callout)
                        .foregroundColor(SalmaDesign.Colors.danger)
                }
            }

            if capturedImage != nil || capturedFileName != nil {
                capturedState
            } else {
                emptyState
            }

            // Error
            if let error = errorMessage {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 12))
                    Text(error)
                        .font(SalmaDesign.Typography.caption)
                }
                .foregroundColor(SalmaDesign.Colors.danger)
            }
        }
        .accessibilityLabel(label)
        .accessibilityValue(capturedImage != nil ? L("captured") : (capturedFileName ?? L("empty")))
        .confirmationDialog(
            L("choose_source"),
            isPresented: $showSourceSheet,
            titleVisibility: .visible
        ) {
            Button(L("take_photo")) { onCapture() }
            Button(L("choose_from_gallery")) { onGallery() }
            Button(L("cancel"), role: .cancel) {}
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        Button { handleTap() } label: {
            VStack(spacing: SalmaDesign.Spacing.sm) {
                Image(systemName: fieldType.iconName)
                    .font(.system(size: 32))
                    .foregroundColor(SalmaDesign.Colors.textTertiary)

                Text(instructionText)
                    .font(SalmaDesign.Typography.callout)
                    .foregroundColor(SalmaDesign.Colors.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(SalmaDesign.Colors.backgroundSecondary)
            .cornerRadius(SalmaDesign.Radius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: SalmaDesign.Radius.lg)
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                    .foregroundColor(SalmaDesign.Colors.border)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Captured State

    @ViewBuilder
    private var capturedState: some View {
        if let image = capturedImage {
            // Image preview
            ZStack(alignment: .bottom) {
                Button { onPreview() } label: {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 180)
                        .clipped()
                        .cornerRadius(SalmaDesign.Radius.lg)
                }
                .buttonStyle(.plain)

                // Action bar overlay
                HStack {
                    Button { handleTap() } label: {
                        Text(L("change"))
                            .font(SalmaDesign.Typography.captionMedium)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Button { onRemove() } label: {
                        Text(L("remove"))
                            .font(SalmaDesign.Typography.captionMedium)
                            .foregroundColor(SalmaDesign.Colors.danger)
                    }
                }
                .padding(.horizontal, SalmaDesign.Spacing.md)
                .padding(.vertical, SalmaDesign.Spacing.sm)
                .background(.black.opacity(0.5))
            }
            .cornerRadius(SalmaDesign.Radius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: SalmaDesign.Radius.lg)
                    .stroke(SalmaDesign.Colors.primaryLight, lineWidth: 1)
            )
        } else if let fileName = capturedFileName {
            // File preview
            HStack(spacing: SalmaDesign.Spacing.md) {
                Image(systemName: fileIcon(for: fileName))
                    .font(.system(size: 28))
                    .foregroundColor(fileColor(for: fileName))

                VStack(alignment: .leading, spacing: 2) {
                    Text(fileName)
                        .font(SalmaDesign.Typography.bodyMedium)
                        .foregroundColor(SalmaDesign.Colors.textPrimary)
                        .lineLimit(1)

                    if let size = capturedFileSize {
                        Text(formattedSize(size))
                            .font(SalmaDesign.Typography.caption)
                            .foregroundColor(SalmaDesign.Colors.textSecondary)
                    }
                }

                Spacer()

                VStack(spacing: SalmaDesign.Spacing.xs) {
                    Button { handleTap() } label: {
                        Text(L("change"))
                            .font(SalmaDesign.Typography.caption)
                            .foregroundColor(SalmaDesign.Colors.primary)
                    }
                    Button { onRemove() } label: {
                        Text(L("remove"))
                            .font(SalmaDesign.Typography.caption)
                            .foregroundColor(SalmaDesign.Colors.danger)
                    }
                }
            }
            .padding(SalmaDesign.Spacing.md)
            .background(SalmaDesign.Colors.surface)
            .cornerRadius(SalmaDesign.Radius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: SalmaDesign.Radius.lg)
                    .stroke(SalmaDesign.Colors.primaryLight, lineWidth: 1)
            )
        }
    }

    // MARK: - Helpers

    private func handleTap() {
        switch sourceType {
        case .cameraOnly:
            onCapture()
        case .galleryOnly:
            if fieldType == .fileUpload { onFilePick() } else { onGallery() }
        case .cameraAndGallery:
            showSourceSheet = true
        case .none:
            break
        }
    }

    private var instructionText: String {
        switch sourceType {
        case .cameraOnly: return L("tap_to_capture")
        case .galleryOnly:
            return fieldType == .fileUpload ? L("tap_to_choose") : L("choose_from_gallery")
        case .cameraAndGallery: return L("tap_to_capture_or_upload")
        case .none: return ""
        }
    }

    private func fileIcon(for name: String) -> String {
        let ext = (name as NSString).pathExtension.lowercased()
        switch ext {
        case "pdf": return "doc.text.fill"
        case "doc", "docx": return "doc.fill"
        case "jpg", "jpeg", "png", "webp": return "photo.fill"
        default: return "doc.fill"
        }
    }

    private func fileColor(for name: String) -> Color {
        let ext = (name as NSString).pathExtension.lowercased()
        switch ext {
        case "pdf": return .red
        case "doc", "docx": return .blue
        case "jpg", "jpeg", "png", "webp": return SalmaDesign.Colors.success
        default: return SalmaDesign.Colors.textSecondary
        }
    }

    private func formattedSize(_ bytes: Int) -> String {
        if bytes >= 1_048_576 {
            let mb = Double(bytes) / 1_048_576.0
            return String(format: "%.1f MB", mb)
        } else {
            let kb = Double(bytes) / 1024.0
            return String(format: "%.0f KB", kb)
        }
    }
}
