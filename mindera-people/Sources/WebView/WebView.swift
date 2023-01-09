import SwiftUI
import WebKit

public struct WebView: UIViewRepresentable {
    let request: URLRequest
    private var webView: WKWebView
    private var completion: (String) -> Void
    
    public init(request: URLRequest, completion: @escaping (String) -> Void) {
        webView = WKWebView()
        webView.customUserAgent = "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36"
        self.request = request
        self.completion = completion
    }
    
    public func makeUIView(context: Context) -> WKWebView {
        return webView
    }
    
    public func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.navigationDelegate = context.coordinator
        uiView.load(request)
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        public func webView(_ webView: WKWebView,
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
