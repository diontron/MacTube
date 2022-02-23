//
//  ContentView.swift
//  MacTube
//
//  Created by Kevin Dion on 2022-02-23.
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
                }, label: {
                    Image(systemName: "chevron.left")
                })
                
                Button(action: {
                    self.webView.wkWebView.goForward()
                }, label: {
                    Image(systemName: "chevron.right")
                })
                
                Button(action: {
                    self.webView.wkWebView.reload()
                }, label: {
                    Image(systemName: "arrow.clockwise")
                })
            }
            .background(Color(colorScheme == .dark
                ? CGColor(red: 0.097, green: 0.097, blue: 0.097, alpha: 1)
                : CGColor(red: 1, green: 1, blue: 1, alpha: 1)
            ))
    }
}


struct WebView: NSViewRepresentable {
    let wkWebView = WKWebView()
    
    func makeNSView(context: Context) -> WKWebView {
        return wkWebView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        let url = URL(string: "https://www.youtube.com")
        let urlRequest = URLRequest(url: url!)
        
        nsView.load(urlRequest)
    }
}
