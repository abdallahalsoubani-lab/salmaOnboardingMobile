import SwiftUI

// Will be implemented in a future prompt
@MainActor
class DocumentPickerViewModel: ObservableObject {
    @Published var selectedFileURL: URL?
    @Published var selectedFileName: String?
    @Published var error: String?
}
