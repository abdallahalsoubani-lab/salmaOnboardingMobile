import SwiftUI
import WebKit

struct HTMLTermsView: UIViewRepresentable {
    let html: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let isArabic = Locale.current.language.languageCode?.identifier == "ar"
        let direction = isArabic ? "rtl" : "ltr"
        let wrapped = """
        <html dir="\(direction)">
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">
            <style>
                body {
                    font-family: -apple-system, Arial, sans-serif;
                    font-size: 16px;
                    line-height: 1.6;
                    color: #1A1A2E;
                    padding: 0;
                    margin: 0;
                    direction: \(direction);
                }
                h1, h2, h3 { color: #16A085; }
                a { color: #2980B9; }
                @media (prefers-color-scheme: dark) {
                    body { color: #F0F0F0; }
                    h1, h2, h3 { color: #1ABC9C; }
                }
            </style>
        </head>
        <body>\(html)</body>
        </html>
        """
        webView.loadHTMLString(wrapped, baseURL: nil)
    }
}
