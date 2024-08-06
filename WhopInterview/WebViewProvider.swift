import Foundation
import WebKit

// Provides a factory function for creating new web views that use a shared process pool. This is helpful
// in reducing memory usage and in reducing the time it takes to create each new webview (roughly 10ms -> 5ms)
// Note that when WKProcessPool is created for the first time, it goes through some lengthy setup.
// Why does Apple not share a WKProcessPool for WKWebViews by default? Because process-based isolation is
// helpful for security and stability. However, depending on a number of factors
// (emphasis on performance, the level of trust
// in the sites being visited, whether or not multiple unrelated domains are being visited, etc.) it can
// can be acceptable to share processes.
// Unfortunately, WKProcessPool.init() is considered to be a main-thread-only UI function, so it can't be run
// in the background, although it could be run while the main thread is idling.
protocol WKWebViewProvidable {
    func createWebView() -> WKWebView
}

final class WKWebViewProvider: WKWebViewProvidable {
    lazy private var sharedProcessPool: WKProcessPool? = {
        WKProcessPool()
    }()

    func createWebView() -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.processPool = sharedProcessPool!
        return WKWebView(frame: .zero, configuration: configuration)
    }
}
