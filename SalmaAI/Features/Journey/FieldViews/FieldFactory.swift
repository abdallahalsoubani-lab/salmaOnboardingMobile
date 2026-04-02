import SwiftUI

// Will be implemented in Prompt 6
struct FieldFactory {
    @ViewBuilder
    static func makeField(for field: PageField, value: Binding<String>, error: String?) -> some View {
        Text("Field: \(field.label)")
    }
}
