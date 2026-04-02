import SwiftUI

// Will be implemented in Prompt 6
@MainActor
class FormPageViewModel: ObservableObject {
    @Published var fields: [PageField] = []
    @Published var fieldValues: [String: String] = [:]
    @Published var fieldErrors: [String: String] = [:]
}
