import SwiftUI
import WebKit

struct GIFWebView: UIViewRepresentable {
    let gifURL: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        webView.contentMode = .scaleAspectFit
        webView.clipsToBounds = true
        webView.backgroundColor = .clear
        webView.isOpaque = false
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: gifURL)
        uiView.load(request)
    }
}
