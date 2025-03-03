//
//  VideoPlayerView.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/18/25.
//

import UIKit
import WebKit

class VideoPlayerView: UIView, WKNavigationDelegate {

    private var webView: WKWebView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupWebView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupWebView()
    }

    private func setupWebView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.isScrollEnabled = false
        addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func loadYouTubeVideo(videoID: String) {
        guard let url = URL(string: "https://www.youtube.com/embed/\(videoID)?playsinline=1&autoplay=1&controls=1&modestbranding=1&rel=0&showinfo=0") else {
             return
        }
        webView.load(URLRequest(url: url))
    }
}
