//
//  ContentView.swift
//  MacTube
//
//  Created by Kevin Dion on 2022-02-23. edited by ryan m on sun aug 2 2026
//

import SwiftUI
import WebKit

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme

    let webView = WebView()

    var body: some View {
        webView
            .toolbar {
                Spacer()

                Text("MacTube")
                    .padding(.leading, 110)

                Spacer()

                Button(action: {
                    self.webView.wkWebView.goBack()
                }) {
                    Image(systemName: "chevron.left")
                }

                Button(action: {
                    self.webView.wkWebView.goForward()
                }) {
                    Image(systemName: "chevron.right")
                }

                Button(action: {
                    self.webView.wkWebView.reload()
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
            .background(Color(colorScheme == .dark
                ? CGColor(red: 0.097, green: 0.097, blue: 0.097, alpha: 1)
                : CGColor(red: 1, green: 1, blue: 1, alpha: 1)
            ))
    }
}


struct WebView: NSViewRepresentable {
    let wkWebView: WKWebView

    init() {
        let preferences = WKPreferences()
        preferences.isElementFullscreenEnabled = false

        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences

        let theaterModeJS = """
        (function() {
            if (window.top !== window.self) {
                return;
            }

            function log(msg) {
                window.webkit.messageHandlers.mactube.postMessage(String(msg));
            }

            log('SCRIPT STARTED, url=' + window.location.href);

            try {
                var style = document.createElement('style');
                var css = 'html.mactube-theater-fill, html.mactube-theater-fill body {' +
                        'overflow: hidden !important;' +
                        'height: 100% !important;' +
                        'width: 100% !important;' +
                    '}' +
                    'html.mactube-theater-fill ytd-app,' +
                    'html.mactube-theater-fill ytd-page-manager,' +
                    'html.mactube-theater-fill ytd-watch-flexy,' +
                    'html.mactube-theater-fill #columns,' +
                    'html.mactube-theater-fill #primary,' +
                    'html.mactube-theater-fill #primary-inner,' +
                    'html.mactube-theater-fill #player-container-outer,' +
                    'html.mactube-theater-fill #player-container-inner,' +
                    'html.mactube-theater-fill #player,' +
                    'html.mactube-theater-fill #movie_player,' +
                    'html.mactube-theater-fill .html5-video-player {' +
                        'width: 100vw !important;' +
                        'height: 100vh !important;' +
                        'max-width: 100vw !important;' +
                        'max-height: 100vh !important;' +
                        'min-width: 0 !important;' +
                        'min-height: 0 !important;' +
                        'margin: 0 !important;' +
                        'padding: 0 !important;' +
                    '}' +
                    'html.mactube-theater-fill #masthead-container,' +
                    'html.mactube-theater-fill ytd-masthead,' +
                    'html.mactube-theater-fill #secondary,' +
                    'html.mactube-theater-fill #related,' +
                    'html.mactube-theater-fill #comments,' +
                    'html.mactube-theater-fill ytd-comments,' +
                    'html.mactube-theater-fill #meta,' +
                    'html.mactube-theater-fill #meta-contents,' +
                    'html.mactube-theater-fill ytd-watch-metadata,' +
                    'html.mactube-theater-fill #below,' +
                    'html.mactube-theater-fill #chips-wrapper,' +
                    'html.mactube-theater-fill #description,' +
                    'html.mactube-theater-fill #playlist,' +
                    'html.mactube-theater-fill #panels-full-bleed-container {' +
                        'display: none !important;' +
                    '}';
                style.appendChild(document.createTextNode(css));
                document.documentElement.appendChild(style);
                log('style appended ok');

                var isActive = false;

                function applyState(isTheater) {
                    log('applyState isTheater=' + isTheater);
                    if (isTheater && !isActive) {
                        document.documentElement.classList.add('mactube-theater-fill');
                        isActive = true;
                        window.dispatchEvent(new Event('resize'));
                        log('added fill class');
                    } else if (!isTheater && isActive) {
                        document.documentElement.classList.remove('mactube-theater-fill');
                        isActive = false;
                        window.dispatchEvent(new Event('resize'));
                        log('removed fill class');
                    }
                }

                function watchFlexy() {
                    var flexy = document.querySelector('ytd-watch-flexy');
                    log('watchFlexy tick, flexy found=' + !!flexy);
                    if (!flexy) {
                        setTimeout(watchFlexy, 500);
                        return;
                    }

                    applyState(flexy.hasAttribute('theater'));

                    var observer = new MutationObserver(function(mutations) {
                        mutations.forEach(function(m) {
                            if (m.attributeName === 'theater') {
                                applyState(flexy.hasAttribute('theater'));
                            }
                        });
                    });

                    observer.observe(flexy, { attributes: true });
                    log('observer attached');
                }

                log('about to call watchFlexy');
                watchFlexy();
                log('watchFlexy called ok');

                document.addEventListener('keydown', function(e) {
                    if (e.key === 'Escape') {
                        applyState(false);
                    }
                });

            } catch (err) {
                log('CAUGHT ERROR: ' + err.message + ' | stack: ' + err.stack);
            }
        })();
        """

        let userScript = WKUserScript(
            source: theaterModeJS,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        )
        configuration.userContentController.addUserScript(userScript)

        wkWebView = WKWebView(frame: .zero, configuration: configuration)
    }

    class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("NAVIGATION FINISHED")
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            print("JS LOG:", message.body)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> WKWebView {
        wkWebView.uiDelegate = context.coordinator
        wkWebView.navigationDelegate = context.coordinator
        wkWebView.configuration.userContentController.add(context.coordinator, name: "mactube")

        let url = URL(string: "https://www.youtube.com")!
        wkWebView.load(URLRequest(url: url))

        return wkWebView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {

    }
}
