import SwiftUI

struct OcrResultCard: View {
    let result: OcrExtractionResult
    @Binding var confirmed: Bool
    @EnvironmentObject var languageManager: LanguageManager

    var body: some View {
        VStack(alignment: .trailing, spacing: SalmaDesign.Spacing.md) {
            HStack(spacing: SalmaDesign.Spacing.sm) {
                Image(systemName: "creditcard.fill")
                    .foregroundColor(SalmaDesign.Colors.primary)
                Text(L("extracted_id_data"))
                    .font(SalmaDesign.Typography.bodyMedium)
                    .foregroundColor(SalmaDesign.Colors.textPrimary)
                Spacer()
                Text(String(format: "%d%%", Int(result.confidence)))
                    .font(SalmaDesign.Typography.captionMedium)
                    .foregroundColor(result.confidence > 70 ? SalmaDesign.Colors.success : SalmaDesign.Colors.warning)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        (result.confidence > 70 ? SalmaDesign.Colors.success : SalmaDesign.Colors.warning)
                            .opacity(0.1)
                    )
                    .cornerRadius(SalmaDesign.Radius.sm)
            }

            Divider()

            if let v = result.fullName { dataRow(label: L("ocr_full_name"), value: v) }
            if let v = result.fullNameEn { dataRow(label: L("ocr_full_name_en"), value: v) }
            if let v = result.nationalId { dataRow(label: L("ocr_national_id"), value: v) }
            if let v = result.dateOfBirth { dataRow(label: L("ocr_date_of_birth"), value: v) }
            if let v = result.gender {
                dataRow(label: L("ocr_gender"), value: v == "Male" ? L("ocr_male") : L("ocr_female"))
            }
            if let v = result.nationality { dataRow(label: L("ocr_nationality"), value: v) }
            if let v = result.placeOfBirth { dataRow(label: L("ocr_place_of_birth"), value: v) }
            if let v = result.motherName { dataRow(label: L("ocr_mother_name"), value: v) }
            if let v = result.expiryDate { dataRow(label: L("ocr_expiry_date"), value: v) }
            if let v = result.placeOfResidence { dataRow(label: L("ocr_place_of_residence"), value: v) }
            if let v = result.placeOfIssue { dataRow(label: L("ocr_place_of_issue"), value: v) }
            if let v = result.bloodType { dataRow(label: L("ocr_blood_type"), value: v) }

            if let warnings = result.warnings, !warnings.isEmpty {
                ForEach(warnings, id: \.self) { warning in
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(SalmaDesign.Colors.warning)
                        Text(warning)
                            .font(SalmaDesign.Typography.caption)
                            .foregroundColor(SalmaDesign.Colors.warning)
                    }
                }
            }

            Divider()

            Button(action: { confirmed.toggle(); HapticManager.impact(.light) }) {
                HStack(spacing: SalmaDesign.Spacing.sm) {
                    Image(systemName: confirmed ? "checkmark.square.fill" : "square")
                        .font(.system(size: 24))
                        .foregroundColor(confirmed ? SalmaDesign.Colors.primary : SalmaDesign.Colors.border)
                    Text(L("confirm_id_data_correct"))
                        .font(SalmaDesign.Typography.body)
                        .foregroundColor(SalmaDesign.Colors.textPrimary)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(SalmaDesign.Spacing.lg)
        .background(SalmaDesign.Colors.surface)
        .cornerRadius(SalmaDesign.Radius.md)
        .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
    }

    @ViewBuilder
    private func dataRow(label: String, value: String) -> some View {
        HStack {
            Text(value)
                .font(SalmaDesign.Typography.body)
                .foregroundColor(SalmaDesign.Colors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .trailing)
            Text(label)
                .font(SalmaDesign.Typography.caption)
                .foregroundColor(SalmaDesign.Colors.textSecondary)
                .frame(width: 120, alignment: .trailing)
        }
    }
}
