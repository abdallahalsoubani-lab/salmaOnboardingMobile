import SwiftUI
import UniformTypeIdentifiers

struct FormPageView: View {
    let pageIndex: Int

    @EnvironmentObject var flowState: VerificationFlowState
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var languageManager: LanguageManager
    @StateObject private var viewModel: FormPageViewModel

    @State private var showPhotoPicker = false
    @State private var showDocumentPicker = false
    @State private var showImagePreview = false
    @State private var activeMediaFieldId: String?

    init(pageIndex: Int) {
        self.pageIndex = pageIndex
        self._viewModel = StateObject(wrappedValue: FormPageViewModel(pageIndex: pageIndex))
    }

    private var currentPage: JourneyPage? {
        let pages = flowState.sortedPages
        return pages.indices.contains(pageIndex) ? pages[pageIndex] : nil
    }

    var body: some View {
        let pages = flowState.sortedPages
        let isLast = pageIndex == pages.count - 1

        VStack(spacing: 0) {
            ProgressStepBar(
                currentStep: pageIndex + 1,
                totalSteps: pages.count
            )
            .padding(.horizontal, SalmaDesign.Spacing.md)
            .padding(.top, SalmaDesign.Spacing.sm)

            if let page = currentPage {
                Text(languageManager.localizedTitle(for: page))
                    .font(SalmaDesign.Typography.title2)
                    .foregroundColor(SalmaDesign.Colors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, SalmaDesign.Spacing.md)
                    .padding(.top, SalmaDesign.Spacing.lg)
                    .padding(.bottom, SalmaDesign.Spacing.md)
            }

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: SalmaDesign.Spacing.lg) {
                        if let page = currentPage {
                            let sortedFields = page.fields.sorted(by: { $0.order < $1.order })
                            ForEach(Array(sortedFields.enumerated()), id: \.element.id) { index, field in
                                if shouldShowField(field) {
                                    VStack(spacing: SalmaDesign.Spacing.md) {
                                        makeFieldView(for: field)
                                            .id(field.id)
                                            .modifier(ShakeEffect(trigger: viewModel.shakeFieldId == field.id))
                                            .staggeredAppear(index: index)

                                        if FieldType(rawValue: field.type) == .idScan {
                                            ocrSectionForField(field)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, SalmaDesign.Spacing.md)
                    .padding(.bottom, 120)
                }
                .onChange(of: viewModel.shakeFieldId) { fieldId in
                    if let fieldId = fieldId {
                        withAnimation { proxy.scrollTo(fieldId, anchor: .center) }
                    }
                }
            }

            Spacer(minLength: 0)
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
        .sheet(isPresented: $showPhotoPicker) {
            PhotoPickerView(
                selectedImage: .constant(nil),
                onImageSelected: { handleGalleryImage($0) },
                onCancel: { showPhotoPicker = false }
            )
        }
        .sheet(isPresented: $showDocumentPicker) { documentPickerSheet }
        .fullScreenCover(isPresented: $showImagePreview) { imagePreviewCover }
    }

    // MARK: - Field View Builder

    @ViewBuilder
    private func makeFieldView(for field: PageField) -> some View {
        let valueBinding = Binding<String>(
            get: { flowState.getValue(for: field.id) },
            set: { newValue in
                flowState.setValue(newValue, for: field.id)
                viewModel.validateField(
                    field: field, value: newValue,
                    capturedImage: flowState.getCapturedImage(for: field.id),
                    language: languageManager.currentLanguage
                )
            }
        )

        let imageBinding = Binding<CapturedImage?>(
            get: { flowState.getCapturedImage(for: field.id) },
            set: { newImage in
                if let img = newImage { flowState.setCapturedImage(img, for: field.id) }
                viewModel.validateField(
                    field: field, value: flowState.getValue(for: field.id),
                    capturedImage: newImage, language: languageManager.currentLanguage
                )
            }
        )

        FieldFactory.makeField(
            for: field,
            value: valueBinding,
            capturedImage: imageBinding,
            errorMessage: viewModel.error(for: field.id),
            languageManager: languageManager,
            onCameraCapture: { handleCameraCapture($0) },
            onGalleryPick: { handleGalleryPick($0) },
            onFilePick: { handleFilePick($0) },
            onImagePreview: { handleImagePreview($0) },
            onImageRemove: { handleImageRemove($0) }
        )
    }

    // MARK: - OCR Result Card

    @ViewBuilder
    private func ocrSectionForField(_ field: PageField) -> some View {
        if flowState.isExtractingOcr {
            HStack(spacing: SalmaDesign.Spacing.sm) {
                ProgressView()
                    .scaleEffect(0.8)
                Text(L("extracting_id_data"))
                    .font(SalmaDesign.Typography.caption)
                    .foregroundColor(SalmaDesign.Colors.textSecondary)
            }
            .padding(SalmaDesign.Spacing.md)
            .transition(.opacity.combined(with: .move(edge: .top)))
        } else if let ocrResult = flowState.ocrExtractionResult {
            OcrResultCard(
                result: ocrResult,
                confirmed: $flowState.ocrConfirmed
            )
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }

    // MARK: - Conditional Visibility

    private func shouldShowField(_ field: PageField) -> Bool {
        PageValidator.isFieldVisible(field, allFieldValues: flowState.fieldValues)
    }

    // MARK: - Media Handlers

    private func handleCameraCapture(_ field: PageField) {
        activeMediaFieldId = field.id
        let fieldType = FieldType(rawValue: field.type) ?? .photo
        switch fieldType {
        case .idScan: router.presentFullScreen(.idCapture(fieldId: field.id, side: .front))
        case .selfie:
            if flowState.livenessEnabled {
                router.presentFullScreen(.livenessCheck(fieldId: field.id))
            } else {
                router.presentFullScreen(.selfieCapture(fieldId: field.id))
            }
        case .photo: router.presentFullScreen(.photoCapture(fieldId: field.id))
        default: break
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
        if viewModel.hasAttemptedNext, let f = findField(by: field.id) {
            viewModel.validateField(field: f, value: flowState.getValue(for: field.id),
                                    capturedImage: nil, language: languageManager.currentLanguage)
        }
    }

    private func handleGalleryImage(_ image: UIImage) {
        guard let fieldId = activeMediaFieldId,
              let data = image.jpegData(compressionQuality: 0.85) else { return }
        let fieldType = findField(by: fieldId).flatMap { FieldType(rawValue: $0.type) } ?? .photo
        let captureType: CapturedImage.CaptureType
        switch fieldType {
        case .idScan: captureType = .idFront
        case .selfie: captureType = .selfie
        case .fileUpload: captureType = .document
        default: captureType = .photo
        }
        var captured = CapturedImage(fieldId: fieldId, imageData: data, type: captureType)
        if fieldType == .fileUpload {
            captured.fileName = "\(fieldId).jpg"
            captured.mimeType = "image/jpeg"
            captured.fileSize = data.count
        }
        flowState.setCapturedImage(captured, for: fieldId)
        if viewModel.hasAttemptedNext, let f = findField(by: fieldId) {
            viewModel.validateField(field: f, value: flowState.getValue(for: fieldId),
                                    capturedImage: captured, language: languageManager.currentLanguage)
        }
    }

    private func handlePickedDocuments(_ docs: [PickedDocument], fieldId: String) {
        guard let doc = docs.first else { return }
        let captured = CapturedImage(
            fieldId: fieldId,
            imageData: doc.data,
            type: .document,
            fileName: doc.fileName,
            mimeType: doc.mimeType,
            fileSize: doc.fileSize
        )
        flowState.setCapturedImage(captured, for: fieldId)
        if viewModel.hasAttemptedNext, let f = findField(by: fieldId) {
            viewModel.validateField(field: f, value: flowState.getValue(for: fieldId),
                                    capturedImage: captured, language: languageManager.currentLanguage)
        }
    }

    private func findField(by id: String) -> PageField? {
        flowState.journey?.pages.flatMap { $0.fields }.first { $0.id == id }
    }

    // MARK: - Sheets/Covers

    @ViewBuilder
    private var documentPickerSheet: some View {
        if let fieldId = activeMediaFieldId, let field = findField(by: fieldId) {
            let formats = (field.validationRules?.acceptedFormats ?? ["pdf", "jpg", "png"])
                .compactMap { $0.utType }
            DocumentPickerView(
                allowedTypes: formats.isEmpty ? [.pdf, .jpeg, .png] : formats,
                allowMultiple: field.validationRules?.allowMultiple ?? false,
                onDocumentsPicked: { handlePickedDocuments($0, fieldId: fieldId) },
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
                image: uiImage, isPresented: $showImagePreview,
                onRetake: { flowState.removeCapturedImage(for: fieldId); showImagePreview = false },
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
                    title: L("previous"), style: .secondary, size: .medium,
                    icon: languageManager.currentLanguage == .arabic ? "chevron.right" : "chevron.left",
                    iconPosition: .leading, action: { router.pop() }
                )
            }

            SalmaButton(
                title: isLast ? L("review_and_submit") : L("next"),
                size: .medium,
                icon: languageManager.currentLanguage == .arabic ? "chevron.left" : "chevron.right",
                iconPosition: .trailing, action: { handleNext(isLast: isLast) }
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

    private func handleNext(isLast: Bool) {
        guard let page = currentPage else { return }
        let isValid = viewModel.validateBeforeNext(
            page: page, fieldValues: flowState.fieldValues,
            capturedImages: flowState.capturedImages,
            language: languageManager.currentLanguage
        )
        guard isValid else { return }
        if isLast { router.push(.review) }
        else { router.push(.formPage(pageIndex: pageIndex + 1)) }
    }
}
