import SwiftUI

@MainActor
class VerificationFlowState: ObservableObject {
    // Journey data
    @Published var journey: JourneyDetail?
    @Published var currentPageIndex: Int = 0

    // Form data keyed by field ID
    @Published var fieldValues: [String: String] = [:]

    // Captured images keyed by field ID
    @Published var capturedImages: [String: CapturedImage] = [:]

    // Submission
    @Published var submissionResult: SubmissionResult?

    // Liveness
    @Published var livenessSessionId: String?
    @Published var livenessResult: Bool?
    @Published var livenessConfidence: Float?
    @Published var livenessEnabled: Bool = true

    // OCR extraction
    @Published var ocrExtractionResult: OcrExtractionResult?
    @Published var isExtractingOcr: Bool = false
    @Published var ocrConfirmed: Bool = false

    // Loading states
    @Published var isLoadingJourney: Bool = false
    @Published var isSubmitting: Bool = false
    @Published var journeyError: APIError?
    @Published var submissionError: APIError?
    @Published var uploadProgress: Double = 0.0

    // MARK: - Computed Properties

    var sortedPages: [JourneyPage] {
        journey?.pages.sorted(by: { $0.order < $1.order }) ?? []
    }

    var totalPages: Int {
        sortedPages.count
    }

    var currentPage: JourneyPage? {
        guard currentPageIndex >= 0, currentPageIndex < sortedPages.count else { return nil }
        return sortedPages[currentPageIndex]
    }

    var isFirstPage: Bool {
        currentPageIndex == 0
    }

    var isLastPage: Bool {
        currentPageIndex == totalPages - 1
    }

    var progressFraction: Double {
        guard totalPages > 0 else { return 0 }
        return Double(currentPageIndex + 1) / Double(totalPages)
    }

    // MARK: - Validation

    func isPageValid(at index: Int) -> Bool {
        guard index >= 0, index < sortedPages.count else { return false }
        let page = sortedPages[index]
        for field in page.fields where field.isRequired {
            if !isFieldFilled(field) { return false }
        }
        return true
    }

    func isCurrentPageValid() -> Bool {
        isPageValid(at: currentPageIndex)
    }

    private func isFieldFilled(_ field: PageField) -> Bool {
        let fieldType = FieldType(rawValue: field.type)
        if fieldType?.isMediaField == true {
            return capturedImages[field.id] != nil
        } else if fieldType == .checkbox {
            return fieldValues[field.id] == "true"
        } else {
            let value = fieldValues[field.id] ?? ""
            return !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    // MARK: - Field Helpers

    func setValue(_ value: String, for fieldId: String) {
        fieldValues[fieldId] = value
    }

    func getValue(for fieldId: String) -> String {
        fieldValues[fieldId] ?? ""
    }

    func setCapturedImage(_ image: CapturedImage, for fieldId: String) {
        capturedImages[fieldId] = image
    }

    func getCapturedImage(for fieldId: String) -> CapturedImage? {
        capturedImages[fieldId]
    }

    func removeCapturedImage(for fieldId: String) {
        capturedImages.removeValue(forKey: fieldId)
    }

    // MARK: - Reset

    func reset() {
        journey = nil
        currentPageIndex = 0
        fieldValues.removeAll()
        capturedImages.removeAll()
        submissionResult = nil
        livenessSessionId = nil
        livenessResult = nil
        livenessConfidence = nil
        ocrExtractionResult = nil
        isExtractingOcr = false
        ocrConfirmed = false
        isLoadingJourney = false
        isSubmitting = false
        journeyError = nil
        submissionError = nil
        uploadProgress = 0.0
    }
}
