import SwiftUI

struct DemoHomeView: View {
    @State private var showVerification = false
    @State private var resultText = ""
    @State private var selectedTheme: ThemeOption = .defaultTheme
    @State private var selectedLanguage: SalmaLanguage = .arabic
    @State private var apiURL = "http://localhost:5000/api/v1"
    @State private var allowLanguageSwitch = true

    enum ThemeOption: String, CaseIterable {
        case defaultTheme = "Default (Teal)"
        case dark = "Dark"
        case banking = "Banking (Blue)"
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Configuration")) {
                    TextField("API URL", text: $apiURL)
                        .textContentType(.URL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)

                    Picker("Language", selection: $selectedLanguage) {
                        Text("Arabic").tag(SalmaLanguage.arabic)
                        Text("English").tag(SalmaLanguage.english)
                    }

                    Picker("Theme", selection: $selectedTheme) {
                        ForEach(ThemeOption.allCases, id: \.self) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }

                    Toggle("Allow Language Switch", isOn: $allowLanguageSwitch)
                }

                Section {
                    Button {
                        showVerification = true
                    } label: {
                        HStack {
                            Image(systemName: "person.badge.shield.checkmark")
                            Text("Start Verification")
                            Spacer()
                            Image(systemName: "arrow.right")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.teal)
                        .cornerRadius(12)
                    }
                }

                if !resultText.isEmpty {
                    Section(header: Text("Result")) {
                        Text(resultText)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                }

                Section(header: Text("SDK Info")) {
                    LabeledContent("Version", value: SalmaSDK.version)
                    LabeledContent("Min iOS", value: "16.0")
                    LabeledContent("Swift Files", value: "116+")
                }
            }
            .navigationTitle("Salma AI Demo")
            .fullScreenCover(isPresented: $showVerification) {
                SalmaSDK.verificationView(
                    config: buildConfig()
                ) { result in
                    showVerification = false
                    handleResult(result)
                }
            }
        }
    }

    private func buildConfig() -> SalmaConfig {
        let theme: SalmaTheme
        switch selectedTheme {
        case .defaultTheme: theme = .default
        case .dark: theme = .dark
        case .banking: theme = .banking
        }

        return SalmaConfig(
            apiBaseURL: apiURL,
            apiKey: "demo_key",
            defaultLanguage: selectedLanguage,
            allowLanguageSwitch: allowLanguageSwitch,
            theme: theme,
            debugMode: true
        )
    }

    private func handleResult(_ result: SalmaResult) {
        switch result {
        case .approved(let data):
            resultText = "APPROVED\nName: \(data.fullName ?? "N/A")\nID: \(data.nationalId ?? "N/A")\nConfidence: \(data.ocrConfidence.map { "\(Int($0 * 100))%" } ?? "N/A")"
        case .rejected(let data):
            resultText = "REJECTED\nReason: \(data.reason)\nSubmission: \(data.submissionId)"
        case .pending(let data):
            resultText = "PENDING\nSubmission: \(data.submissionId)\nMessage: \(data.message)"
        case .cancelled:
            resultText = "User cancelled"
        case .error(let error):
            resultText = "ERROR\n\(error.localizedDescription)"
        }
    }
}
