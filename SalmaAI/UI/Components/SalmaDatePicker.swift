import SwiftUI

struct SalmaDatePicker: View {
    let label: String
    @Binding var selectedDate: Date?
    var placeholder: String = ""
    var errorMessage: String?
    var isRequired: Bool = false
    var mustBePast: Bool = false
    var mustBeFuture: Bool = false
    var minDate: Date?
    var maxDate: Date?

    @State private var showPicker = false
    @State private var tempDate = Date()
    @Environment(\.locale) private var locale

    var body: some View {
        VStack(alignment: .leading, spacing: SalmaDesign.Spacing.xs) {
            // Label
            HStack(spacing: 2) {
                Text(label)
                    .font(SalmaDesign.Typography.callout)
                    .foregroundColor(SalmaDesign.Colors.textSecondary)
                if isRequired {
                    Text("*")
                        .font(SalmaDesign.Typography.callout)
                        .foregroundColor(SalmaDesign.Colors.danger)
                }
            }

            // Date button
            Button { showPicker = true } label: {
                HStack {
                    Image(systemName: "calendar")
                        .font(.system(size: 16))
                        .foregroundColor(SalmaDesign.Colors.textTertiary)

                    Text(formattedDate)
                        .font(SalmaDesign.Typography.body)
                        .foregroundColor(selectedDate != nil ? SalmaDesign.Colors.textPrimary : SalmaDesign.Colors.textTertiary)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 14))
                        .foregroundColor(SalmaDesign.Colors.textSecondary)
                }
                .padding(.horizontal, SalmaDesign.Spacing.md)
                .frame(height: 52)
                .background(SalmaDesign.Colors.backgroundSecondary)
                .cornerRadius(SalmaDesign.Radius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: SalmaDesign.Radius.md)
                        .stroke(errorMessage != nil ? SalmaDesign.Colors.danger : SalmaDesign.Colors.border, lineWidth: 1.5)
                )
            }
            .buttonStyle(.plain)

            // Error
            if let error = errorMessage {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 12))
                    Text(error)
                        .font(SalmaDesign.Typography.caption)
                }
                .foregroundColor(SalmaDesign.Colors.danger)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .accessibilityLabel(label)
        .accessibilityValue(selectedDate != nil ? formattedDate : L("no_date_selected"))
        .animation(AppAnimations.fadeIn, value: errorMessage)
        .sheet(isPresented: $showPicker) {
            datePickerSheet
        }
    }

    private var formattedDate: String {
        guard let date = selectedDate else {
            return placeholder.isEmpty ? label : placeholder
        }
        let formatter = DateFormatter()
        formatter.locale = locale
        if locale.identifier.hasPrefix("ar") {
            formatter.dateFormat = "d MMMM yyyy"
        } else {
            formatter.dateFormat = "MMM d, yyyy"
        }
        return formatter.string(from: date)
    }

    private var dateRange: ClosedRange<Date> {
        let distantPast = Calendar.current.date(byAdding: .year, value: -120, to: Date()) ?? .distantPast
        let distantFuture = Calendar.current.date(byAdding: .year, value: 50, to: Date()) ?? .distantFuture

        let lower = minDate ?? (mustBeFuture ? Date() : distantPast)
        let upper = maxDate ?? (mustBePast ? Date() : distantFuture)
        return lower...upper
    }

    private var datePickerSheet: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "",
                    selection: $tempDate,
                    in: dateRange,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .tint(SalmaDesign.Colors.primary)
                .padding()

                Spacer()
            }
            .navigationTitle(label)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L("done")) {
                        selectedDate = tempDate
                        showPicker = false
                    }
                    .foregroundColor(SalmaDesign.Colors.primary)
                    .fontWeight(.semibold)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(L("cancel")) {
                        showPicker = false
                    }
                    .foregroundColor(SalmaDesign.Colors.textSecondary)
                }
            }
            .onAppear {
                tempDate = selectedDate ?? Date()
            }
        }
    }
}
