//
//  WebViewK.swift
//  KaxhyapUI
//
//  Created by Sachin Kaxhyap on 26/12/2025.
//

import SwiftUI
#if canImport(WebKit)
import WebKit
#endif
#if canImport(SafariServices)
import SafariServices
#endif

// MARK: - Public API
public struct WebViewK: View {

    public enum Style {
        case embedded
        case safari
    }

    private let url: URL?
    private let style: Style

    public init(
        url: URL?,
        style: Style = .embedded
    ) {
        self.url = url
        self.style = style
    }

    public var body: some View {
        Group {
            #if os(iOS)
            switch style {
            case .embedded:
                WKWebViewWrapper(url: url)

            case .safari:
                if let url {
                    SafariView(url: url)
                } else {
                    unavailableView
                }
            }
            #elseif os(macOS)
            // Safari style not available on macOS, fall back to WKWebView
            if url != nil {
                WKWebViewWrapper(url: url)
            } else {
                unavailableView
            }
            #else
            unavailableView
            #endif
        }
    }

    @ViewBuilder
    private var unavailableView: some View {
        ContentUnavailableView(
            "No URL",
            systemImage: "network.slash",
            description: Text("Please provide a valid URL")
        )
    }
}

// MARK: - iOS WKWebView Wrapper
#if os(iOS)
struct WKWebViewWrapper: UIViewRepresentable {
    let url: URL?

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.allowsBackForwardNavigationGestures = true
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard let url else { return }
        let request = URLRequest(url: url)
        
        // Only load if not already loading this URL
        if webView.url != url {
            webView.load(request)
        }
    }
}

// MARK: - SafariView Wrapper (iOS only)
struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.barCollapsingEnabled = true
        return SFSafariViewController(url: url, configuration: config)
    }

    func updateUIViewController(
        _ uiViewController: SFSafariViewController,
        context: Context
    ) {}
}
#endif

// MARK: - macOS WKWebView Wrapper
#if os(macOS)
struct WKWebViewWrapper: NSViewRepresentable {
    let url: URL?

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.allowsBackForwardNavigationGestures = true
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        guard let url else { return }
        let request = URLRequest(url: url)
        
        // Only load if not already loading this URL
        if webView.url != url {
            webView.load(request)
        }
    }
}
#endif

// MARK: - Previews
#Preview("WebView") {
    WebViewK(
        url: URL(string: "https://apple.com"),
        style: .embedded
    )
}

#Preview("Safari") {
    WebViewK(
        url: URL(string: "https://apple.com"),
        style: .safari
    )
}

#Preview("No URL") {
    WebViewK(url: nil)
}
