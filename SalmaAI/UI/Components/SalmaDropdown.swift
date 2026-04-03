import SwiftUI

struct SalmaDropdown: View {
    let label: String
    let options: [String]
    @Binding var selection: String
    var placeholder: String = ""
    var errorMessage: String?
    var isRequired: Bool = false

    @State private var showPicker = false
    @State private var searchText = ""

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

            // Dropdown button
            Button { showPicker = true } label: {
                HStack {
                    Text(selection.isEmpty ? (placeholder.isEmpty ? label : placeholder) : selection)
                        .font(SalmaDesign.Typography.body)
                        .foregroundColor(selection.isEmpty ? SalmaDesign.Colors.textTertiary : SalmaDesign.Colors.textPrimary)
                        .lineLimit(1)
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
            .accessibilityLabel(label)
            .accessibilityValue(selection.isEmpty ? (placeholder.isEmpty ? label : placeholder) : selection)
            .accessibilityAddTraits(.isButton)
            .accessibilityHint(L("double_tap_to_select"))

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
        .animation(AppAnimations.fadeIn, value: errorMessage)
        .sheet(isPresented: $showPicker) {
            if options.count <= 7 {
                shortOptionsList
            } else {
                searchableOptionsList
            }
        }
    }

    // Short list (≤7 options)
    private var shortOptionsList: some View {
        NavigationView {
            List {
                ForEach(options, id: \.self) { option in
                    Button {
                        selection = option
                        showPicker = false
                    } label: {
                        HStack {
                            Text(option)
                                .font(SalmaDesign.Typography.body)
                                .foregroundColor(SalmaDesign.Colors.textPrimary)
                            Spacer()
                            if selection == option {
                                Image(systemName: "checkmark")
                                    .foregroundColor(SalmaDesign.Colors.primary)
                            }
                        }
                    }
                }
            }
            .navigationTitle(label)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L("done")) { showPicker = false }
                        .foregroundColor(SalmaDesign.Colors.primary)
                }
            }
        }
        .presentationDetents([.medium])
    }

    // Searchable list (>7 options)
    private var searchableOptionsList: some View {
        NavigationView {
            List {
                ForEach(filteredOptions, id: \.self) { option in
                    Button {
                        selection = option
                        showPicker = false
                    } label: {
                        HStack {
                            Text(option)
                                .font(SalmaDesign.Typography.body)
                                .foregroundColor(SalmaDesign.Colors.textPrimary)
                            Spacer()
                            if selection == option {
                                Image(systemName: "checkmark")
                                    .foregroundColor(SalmaDesign.Colors.primary)
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText)
            .navigationTitle(label)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L("done")) { showPicker = false }
                        .foregroundColor(SalmaDesign.Colors.primary)
                }
            }
        }
    }

    private var filteredOptions: [String] {
        if searchText.isEmpty { return options }
        return options.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
}
