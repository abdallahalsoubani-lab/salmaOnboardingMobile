import Foundation

enum Route: Hashable {
    case languageSelection
    case journey
    case idCapture(side: IDSide)
    case selfieCapture
    case photoCapture
    case fileUpload(fieldId: String)
    case submission
    case result(SubmissionResult)
}

enum IDSide: String, Hashable {
    case front
    case back
}
