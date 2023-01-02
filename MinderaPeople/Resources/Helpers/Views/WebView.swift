import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let request: URLRequest
    private var webView: WKWebView
    private var completion: (String) -> Void

    init(request: URLRequest, completion: @escaping (String) -> Void) {
        webView = WKWebView()
        self.request = request
        self.completion = completion
    }

    func makeUIView(context: Context) -> WKWebView {
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.navigationDelegate = context.coordinator
        uiView.load(request)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url?.absoluteString,
               let range = url.range(of: "mindera-people://auth?token=") {
                let token = url[range.upperBound...]
                parent.completion(String(token))
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }
    }
}
