import SwiftUI

struct FormPageView: View {
    let pageIndex: Int

    @EnvironmentObject var flowState: VerificationFlowState
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var languageManager: LanguageManager

    @State private var showPhotoPicker = false
    @State private var showDocumentPicker = false
    @State private var showImagePreview = false
    @State private var activeMediaFieldId: String?

    var body: some View {
        let pages = flowState.sortedPages
        let page = pages.indices.contains(pageIndex) ? pages[pageIndex] : nil
        let isLast = pageIndex == pages.count - 1

        VStack(spacing: 0) {
            // Progress bar
            ProgressStepBar(
                currentStep: pageIndex + 1,
                totalSteps: pages.count
            )
            .padding(.horizontal, SalmaDesign.Spacing.md)
            .padding(.top, SalmaDesign.Spacing.sm)

            // Page title
            if let page = page {
                Text(languageManager.localizedTitle(for: page))
                    .font(SalmaDesign.Typography.title2)
                    .foregroundColor(SalmaDesign.Colors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, SalmaDesign.Spacing.md)
                    .padding(.top, SalmaDesign.Spacing.lg)
                    .padding(.bottom, SalmaDesign.Spacing.md)
            }

            // Scrollable fields
            ScrollView {
                VStack(spacing: SalmaDesign.Spacing.lg) {
                    if let page = page {
                        let sortedFields = page.fields.sorted(by: { $0.order < $1.order })
                        ForEach(Array(sortedFields.enumerated()), id: \.element.id) { index, field in
                            if shouldShowField(field) {
                                makeFieldView(for: field)
                                    .staggeredAppear(index: index)
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                    }
                }
                .padding(.horizontal, SalmaDesign.Spacing.md)
                .padding(.bottom, 120)
            }

            Spacer(minLength: 0)

            // Bottom buttons
            bottomButtons(isLast: isLast)
        }
        .background(SalmaDesign.Colors.background)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { router.presentSheet(.languageSwitch) } label: {
                    Image(systemName: "globe")
                        .font(.system(size: 18))
                        .foregroundColor(SalmaDesign.Colors.textSecondary)
                }
            }
        }
        .dismissKeyboardOnTap()
        .onAppear { flowState.currentPageIndex = pageIndex }
        // Photo picker
        .sheet(isPresented: $showPhotoPicker) {
            PhotoPickerView(
                selectedImage: .constant(nil),
                onImageSelected: { image in handleGalleryImage(image) },
                onCancel: { showPhotoPicker = false }
            )
        }
        // Document picker
        .sheet(isPresented: $showDocumentPicker) {
            documentPickerSheet
        }
        // Image preview
        .fullScreenCover(isPresented: $showImagePreview) {
            imagePreviewCover
        }
    }

    // MARK: - Field View Builder

    @ViewBuilder
    private func makeFieldView(for field: PageField) -> some View {
        let valueBinding = Binding<String>(
            get: { flowState.getValue(for: field.id) },
            set: { flowState.setValue($0, for: field.id) }
        )

        let imageBinding = Binding<CapturedImage?>(
            get: { flowState.getCapturedImage(for: field.id) },
            set: { if let img = $0 { flowState.setCapturedImage(img, for: field.id) } }
        )

        FieldFactory.makeField(
            for: field,
            value: valueBinding,
            capturedImage: imageBinding,
            errorMessage: nil,
            languageManager: languageManager,
            onCameraCapture: { handleCameraCapture($0) },
            onGalleryPick: { handleGalleryPick($0) },
            onFilePick: { handleFilePick($0) },
            onImagePreview: { handleImagePreview($0) },
            onImageRemove: { handleImageRemove($0) }
        )
    }

    // MARK: - Conditional Visibility

    private func shouldShowField(_ field: PageField) -> Bool {
        guard let condition = field.validationRules?.condition else { return true }
        let watchedValue = flowState.getValue(for: condition.field)

        switch condition.operator {
        case "equals":
            return watchedValue == (condition.value ?? "")
        case "not_equals":
            return watchedValue != (condition.value ?? "")
        case "contains":
            return watchedValue.contains(condition.value ?? "")
        case "not_empty":
            return !watchedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        default:
            return true
        }
    }

    // MARK: - Media Handlers

    private func handleCameraCapture(_ field: PageField) {
        activeMediaFieldId = field.id
        let fieldType = FieldType(rawValue: field.type) ?? .photo

        switch fieldType {
        case .idScan:
            router.presentFullScreen(.idCapture(fieldId: field.id, side: .front))
        case .selfie:
            router.presentFullScreen(.selfieCapture(fieldId: field.id))
        case .photo:
            router.presentFullScreen(.photoCapture(fieldId: field.id))
        default:
            break
        }
    }

    private func handleGalleryPick(_ field: PageField) {
        activeMediaFieldId = field.id
        showPhotoPicker = true
    }

    private func handleFilePick(_ field: PageField) {
        activeMediaFieldId = field.id
        showDocumentPicker = true
    }

    private func handleImagePreview(_ field: PageField) {
        activeMediaFieldId = field.id
        showImagePreview = true
    }

    private func handleImageRemove(_ field: PageField) {
        flowState.removeCapturedImage(for: field.id)
    }

    private func handleGalleryImage(_ image: UIImage) {
        guard let fieldId = activeMediaFieldId,
              let data = image.jpegData(compressionQuality: 0.85) else { return }

        let fieldType = findField(by: fieldId).flatMap { FieldType(rawValue: $0.type) } ?? .photo
        let captureType: CapturedImage.CaptureType
        switch fieldType {
        case .idScan: captureType = .idFront
        case .selfie: captureType = .selfie
        default: captureType = .photo
        }

        flowState.setCapturedImage(
            CapturedImage(fieldId: fieldId, imageData: data, type: captureType),
            for: fieldId
        )
    }

    private func handlePickedDocuments(_ docs: [PickedDocument], fieldId: String) {
        guard let doc = docs.first else { return }
        flowState.setCapturedImage(
            CapturedImage(fieldId: fieldId, imageData: doc.data, type: .document),
            for: fieldId
        )
    }

    private func findField(by id: String) -> PageField? {
        flowState.journey?.pages.flatMap { $0.fields }.first { $0.id == id }
    }

    // MARK: - Sheet/Cover Builders

    @ViewBuilder
    private var documentPickerSheet: some View {
        if let fieldId = activeMediaFieldId,
           let field = findField(by: fieldId) {
            let formats = (field.validationRules?.acceptedFormats ?? ["pdf", "jpg", "png"])
                .compactMap { $0.utType }
            DocumentPickerView(
                allowedTypes: formats.isEmpty ? [.pdf, .jpeg, .png] : formats,
                allowMultiple: field.validationRules?.allowMultiple ?? false,
                onDocumentsPicked: { docs in handlePickedDocuments(docs, fieldId: fieldId) },
                onCancel: { showDocumentPicker = false }
            )
        }
    }

    @ViewBuilder
    private var imagePreviewCover: some View {
        if let fieldId = activeMediaFieldId,
           let captured = flowState.getCapturedImage(for: fieldId),
           let uiImage = UIImage(data: captured.imageData) {
            ImagePreviewOverlay(
                image: uiImage,
                isPresented: $showImagePreview,
                onRetake: {
                    flowState.removeCapturedImage(for: fieldId)
                    showImagePreview = false
                },
                onUse: { showImagePreview = false }
            )
        }
    }

    // MARK: - Bottom Buttons

    @ViewBuilder
    private func bottomButtons(isLast: Bool) -> some View {
        HStack(spacing: SalmaDesign.Spacing.md) {
            if pageIndex > 0 {
                SalmaButton(
                    title: String(localized: "previous"),
                    style: .secondary,
                    size: .medium,
                    icon: languageManager.currentLanguage == .arabic ? "chevron.right" : "chevron.left",
                    iconPosition: .leading,
                    action: { router.pop() }
                )
            }

            SalmaButton(
                title: isLast
                    ? String(localized: "review_and_submit")
                    : String(localized: "next"),
                size: .medium,
                icon: languageManager.currentLanguage == .arabic ? "chevron.left" : "chevron.right",
                iconPosition: .trailing,
                action: {
                    if isLast {
                        router.push(.review)
                    } else {
                        router.push(.formPage(pageIndex: pageIndex + 1))
                    }
                }
            )
        }
        .padding(.horizontal, SalmaDesign.Spacing.md)
        .padding(.vertical, SalmaDesign.Spacing.md)
        .background(
            SalmaDesign.Colors.background
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: -4)
                .mask(Rectangle().padding(.top, -20))
        )
    }
}
