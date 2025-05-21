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
        let html = """
        <html><body style="margin:0;padding:0;background:transparent;">
        <img src="\(gifURL.absoluteString)" style="width:100%;height:auto;" />
        </body></html>
        """
        uiView.loadHTMLString(html, baseURL: nil)
    }
}
