import SwiftUI
import UniformTypeIdentifiers

struct FileUploadFieldView: View {
    let field: PageField
    let label: String
    @Binding var capturedImage: CapturedImage?
    let errorMessage: String?
    let onFilePick: () -> Void
    let onGallery: () -> Void
    let onPreview: () -> Void
    let onRemove: () -> Void

    @EnvironmentObject var languageManager: LanguageManager
    @State private var showActionSheet = false

    private var acceptedFormats: [String] {
        field.validationRules?.acceptedFormats ?? SalmaDesign.FileUpload.allAllowedFormats
    }

    private var hasImageFormats: Bool {
        let imageExts = Set(["jpg", "jpeg", "png", "webp"])
        return acceptedFormats.contains { imageExts.contains($0.lowercased()) }
    }

    private var hasDocFormats: Bool {
        let docExts = Set(["pdf", "doc", "docx"])
        return acceptedFormats.contains { docExts.contains($0.lowercased()) }
    }

    private var hasCapturedFile: Bool {
        capturedImage != nil
    }

    private var displayFileName: String? {
        capturedImage?.fileName
    }

    private var displayFileSize: Int? {
        capturedImage?.fileSize ?? capturedImage?.imageData.count
    }

    private var isImageFile: Bool {
        guard let name = displayFileName else { return capturedImage != nil && capturedImage?.fileName == nil }
        let ext = (name as NSString).pathExtension.lowercased()
        return ["jpg", "jpeg", "png", "webp"].contains(ext)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SalmaDesign.Spacing.xs) {
            HStack(spacing: 2) {
                Text(label)
                    .font(SalmaDesign.Typography.callout)
                    .foregroundColor(SalmaDesign.Colors.textSecondary)
                if field.isRequired {
                    Text("*").font(SalmaDesign.Typography.callout)
                        .foregroundColor(SalmaDesign.Colors.danger)
                }
            }

            if let formats = field.validationRules?.acceptedFormats, !formats.isEmpty {
                HStack(spacing: 4) {
                    ForEach(formats, id: \.self) { format in
                        Text(format.uppercased())
                            .font(SalmaDesign.Typography.small)
                            .foregroundColor(SalmaDesign.Colors.textTertiary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(SalmaDesign.Colors.backgroundSecondary)
                            .cornerRadius(4)
                    }

                    if let maxSize = field.validationRules?.maxFileSizeMB {
                        Text("max \(maxSize) MB")
                            .font(SalmaDesign.Typography.small)
                            .foregroundColor(SalmaDesign.Colors.textTertiary)
                    }
                }
            }

            if hasCapturedFile {
                capturedFileView
            } else {
                emptyUploadView
            }

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
        .confirmationDialog(
            L("choose_source"),
            isPresented: $showActionSheet,
            titleVisibility: .visible
        ) {
            if hasImageFormats {
                Button(L("choose_from_gallery")) { onGallery() }
            }
            if hasDocFormats {
                Button(L("choose_file")) { onFilePick() }
            }
            Button(L("cancel"), role: .cancel) {}
        }
    }

    // MARK: - Empty State

    private var emptyUploadView: some View {
        Button { handleUploadTap() } label: {
            VStack(spacing: SalmaDesign.Spacing.sm) {
                Image(systemName: "paperclip")
                    .font(.system(size: 32))
                    .foregroundColor(SalmaDesign.Colors.textTertiary)

                Text(uploadInstructionText)
                    .font(SalmaDesign.Typography.callout)
                    .foregroundColor(SalmaDesign.Colors.textTertiary)
                    .multilineTextAlignment(.center)
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

    // MARK: - Captured File State

    @ViewBuilder
    private var capturedFileView: some View {
        if isImageFile, let data = capturedImage?.imageData, let uiImage = UIImage(data: data) {
            imagePreview(uiImage)
        } else {
            documentPreview
        }
    }

    private func imagePreview(_ image: UIImage) -> some View {
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

            HStack {
                Button { handleUploadTap() } label: {
                    Text(L("change"))
                        .font(SalmaDesign.Typography.captionMedium)
                        .foregroundColor(.white)
                }
                Spacer()
                if let size = displayFileSize {
                    Text(formattedSize(size))
                        .font(SalmaDesign.Typography.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                Spacer()
                Button { removeFile() } label: {
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
    }

    private var documentPreview: some View {
        HStack(spacing: SalmaDesign.Spacing.md) {
            Image(systemName: fileIcon)
                .font(.system(size: 28))
                .foregroundColor(fileIconColor)

            VStack(alignment: .leading, spacing: 2) {
                Text(displayFileName ?? L("file_selected"))
                    .font(SalmaDesign.Typography.bodyMedium)
                    .foregroundColor(SalmaDesign.Colors.textPrimary)
                    .lineLimit(1)

                if let size = displayFileSize {
                    Text(formattedSize(size))
                        .font(SalmaDesign.Typography.caption)
                        .foregroundColor(SalmaDesign.Colors.textSecondary)
                }
            }

            Spacer()

            VStack(spacing: SalmaDesign.Spacing.xs) {
                Button { handleUploadTap() } label: {
                    Text(L("change"))
                        .font(SalmaDesign.Typography.caption)
                        .foregroundColor(SalmaDesign.Colors.primary)
                }
                Button { removeFile() } label: {
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

    // MARK: - Actions

    private func handleUploadTap() {
        if hasImageFormats && hasDocFormats {
            showActionSheet = true
        } else if hasImageFormats {
            onGallery()
        } else {
            onFilePick()
        }
    }

    private func removeFile() {
        capturedImage = nil
        onRemove()
    }

    // MARK: - Helpers

    private var uploadInstructionText: String {
        if hasImageFormats && hasDocFormats {
            return L("tap_to_choose_file_or_image")
        } else if hasImageFormats {
            return L("choose_from_gallery")
        } else {
            return L("tap_to_choose")
        }
    }

    private var fileIcon: String {
        guard let name = displayFileName else { return "doc.fill" }
        let ext = (name as NSString).pathExtension.lowercased()
        switch ext {
        case "pdf": return "doc.text.fill"
        case "doc", "docx": return "doc.fill"
        default: return "doc.fill"
        }
    }

    private var fileIconColor: Color {
        guard let name = displayFileName else { return SalmaDesign.Colors.textSecondary }
        let ext = (name as NSString).pathExtension.lowercased()
        switch ext {
        case "pdf": return .red
        case "doc", "docx": return .blue
        default: return SalmaDesign.Colors.textSecondary
        }
    }

    private func formattedSize(_ bytes: Int) -> String {
        if bytes >= 1_048_576 {
            return String(format: "%.1f MB", Double(bytes) / 1_048_576.0)
        } else {
            return String(format: "%.0f KB", Double(bytes) / 1024.0)
        }
    }
}
