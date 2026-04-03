import Foundation

struct OcrExtractionResult: Codable {
    let fullName: String?
    let fullNameEn: String?
    let nationalId: String?
    let dateOfBirth: String?
    let gender: String?
    let nationality: String?
    let placeOfBirth: String?
    let motherName: String?
    let expiryDate: String?
    let placeOfResidence: String?
    let placeOfIssue: String?
    let bloodType: String?
    let idNumber: String?
    let confidence: Float
    let rawText: String?
    let warnings: [String]?
    let processingTimeMs: Int?

    static func merged(_ base: OcrExtractionResult, with new: OcrExtractionResult) -> OcrExtractionResult {
        let mergedFullName = base.fullName ?? new.fullName
        let mergedFullNameEn = base.fullNameEn ?? new.fullNameEn
        let mergedNationalId = base.nationalId ?? new.nationalId
        let mergedDateOfBirth = base.dateOfBirth ?? new.dateOfBirth
        let mergedGender = base.gender ?? new.gender
        let mergedNationality = base.nationality ?? new.nationality
        let mergedPlaceOfBirth = base.placeOfBirth ?? new.placeOfBirth
        let mergedMotherName = base.motherName ?? new.motherName
        let mergedExpiryDate = base.expiryDate ?? new.expiryDate
        let mergedPlaceOfResidence = base.placeOfResidence ?? new.placeOfResidence
        let mergedPlaceOfIssue = base.placeOfIssue ?? new.placeOfIssue
        let mergedBloodType = base.bloodType ?? new.bloodType
        let mergedIdNumber = base.idNumber ?? new.idNumber

        let foundFields: [String?] = [
            mergedFullName, mergedNationalId, mergedDateOfBirth,
            mergedGender, mergedNationality, mergedPlaceOfBirth,
            mergedMotherName, mergedExpiryDate, mergedPlaceOfResidence
        ]
        let foundCount = foundFields.compactMap { $0 }.count
        let mergedConfidence = Float(foundCount) / 9.0 * 100.0

        let allWarnings = (base.warnings ?? []) + (new.warnings ?? [])
        let filteredWarnings = filterWarnings(
            allWarnings: allWarnings,
            fullName: mergedFullName, nationalId: mergedNationalId,
            dateOfBirth: mergedDateOfBirth, gender: mergedGender,
            nationality: mergedNationality, placeOfBirth: mergedPlaceOfBirth,
            motherName: mergedMotherName, expiryDate: mergedExpiryDate,
            placeOfResidence: mergedPlaceOfResidence
        )

        return OcrExtractionResult(
            fullName: mergedFullName,
            fullNameEn: mergedFullNameEn,
            nationalId: mergedNationalId,
            dateOfBirth: mergedDateOfBirth,
            gender: mergedGender,
            nationality: mergedNationality,
            placeOfBirth: mergedPlaceOfBirth,
            motherName: mergedMotherName,
            expiryDate: mergedExpiryDate,
            placeOfResidence: mergedPlaceOfResidence,
            placeOfIssue: mergedPlaceOfIssue,
            bloodType: mergedBloodType,
            idNumber: mergedIdNumber,
            confidence: mergedConfidence,
            rawText: [base.rawText, new.rawText].compactMap { $0 }.joined(separator: "\n---\n"),
            warnings: filteredWarnings.isEmpty ? nil : filteredWarnings,
            processingTimeMs: (base.processingTimeMs ?? 0) + (new.processingTimeMs ?? 0)
        )
    }

    private static func filterWarnings(
        allWarnings: [String],
        fullName: String?, nationalId: String?, dateOfBirth: String?,
        gender: String?, nationality: String?, placeOfBirth: String?,
        motherName: String?, expiryDate: String?, placeOfResidence: String?
    ) -> [String] {
        var filtered = allWarnings
        if fullName != nil { filtered.removeAll { $0.contains("الاسم") } }
        if nationalId != nil { filtered.removeAll { $0.contains("الرقم الوطني") } }
        if dateOfBirth != nil { filtered.removeAll { $0.contains("تاريخ الميلاد") } }
        if gender != nil { filtered.removeAll { $0.contains("الجنس") && !$0.contains("الجنسية") } }
        if nationality != nil { filtered.removeAll { $0.contains("الجنسية") } }
        if placeOfBirth != nil { filtered.removeAll { $0.contains("مكان الولادة") } }
        if motherName != nil { filtered.removeAll { $0.contains("الأم") || $0.contains("الام") } }
        if expiryDate != nil { filtered.removeAll { $0.contains("الانتهاء") || $0.contains("الصلاحية") } }
        if placeOfResidence != nil { filtered.removeAll { $0.contains("الإقامة") || $0.contains("الاقامة") } }
        return Array(Set(filtered))
    }

    static let empty = OcrExtractionResult(
        fullName: nil, fullNameEn: nil, nationalId: nil, dateOfBirth: nil,
        gender: nil, nationality: nil, placeOfBirth: nil, motherName: nil,
        expiryDate: nil, placeOfResidence: nil, placeOfIssue: nil,
        bloodType: nil, idNumber: nil, confidence: 0, rawText: nil,
        warnings: nil, processingTimeMs: nil
    )
}
