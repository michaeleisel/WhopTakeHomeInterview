import Foundation
import SwiftUI
import WebKit

struct WKWebViewProviderKey: EnvironmentKey {
    static let defaultValue: WKWebViewProvidable = WKWebViewProvider()
}

extension EnvironmentValues {
    var WKWebViewProvider: WKWebViewProvidable {
        get { self[WKWebViewProviderKey.self] }
        set { self[WKWebViewProviderKey.self] = newValue }
    }
}

// Here I use @EnvironentObject, but in a larger scenario, perhaps one with
// more unit testing, I might use a more structured/configurable
// approach to DI, such as with https://github.com/pointfreeco/swift-dependencies

// In a production context, things like force unwraps and fatal errors
// could be replaced with more nuanced
struct WebView: UIViewRepresentable {
    @Environment(\.WKWebViewProvider) var WKWebViewProvider
    private let site: Site
    init(site: Site) {
        self.site = site
    }

    func makeUIView(context: Context) -> WKWebView {
        // Note that this web view lacks any back/forward functionality,
        // but we could add buttons and a WKNavigationDelegate to support that
        return WKWebViewProvider.createWebView()
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        let request = URLRequest(url: site.url)
        uiView.load(request)
    }
}

