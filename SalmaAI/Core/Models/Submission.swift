import Foundation

struct SubmissionResult: Codable, Hashable {
    let submissionId: String
    let status: String
    let message: String
    let ocrData: OcrData?
}

struct OcrData: Codable, Hashable {
    let fullNameAr: String?
    let nationalId: String?
    let dateOfBirth: String?
    let gender: String?
    let confidence: Double?
}

struct SubmissionStatus: Codable {
    let submissionId: String
    let status: String
    let message: String?
    let createdAt: String
    let updatedAt: String
}
