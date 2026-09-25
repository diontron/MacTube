//
//  MacTubeApp.swift
//  MacTube 2
//
//  Forked from MacTube by Kevin Dion (2022-02-23).
//

import SwiftUI

enum Pref {
    static let showShorts = "showShorts"
    static let showAI = "showAI"
}

extension Notification.Name {
    static let forgetAIChannels = Notification.Name("forgetAIChannels")
}

let homeURL = URL(string: "https://www.youtube.com")!

/// Value that opens a window. Unique per request so SwiftUI never reuses an existing window.
struct TabRequest: Codable, Hashable {
    var id = UUID()
    var url: URL
}

@main
struct MacTubeApp: App {
    @AppStorage(Pref.showShorts) private var showShorts = true
    @AppStorage(Pref.showAI) private var showAI = true

    var body: some Scene {
        WindowGroup(for: TabRequest.self) { $request in
            ContentView(url: request?.url ?? homeURL)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .commands {
            CommandGroup(after: .newItem) {
                NewTabButton()
            }
            CommandMenu("Filters") {
                Toggle("Show Shorts", isOn: $showShorts)
                    .keyboardShortcut("1", modifiers: [.command, .shift])
                Toggle("Show AI Videos", isOn: $showAI)
                    .keyboardShortcut("2", modifiers: [.command, .shift])
                Divider()
                Button("Forget Learned AI Channels") {
                    NotificationCenter.default.post(name: .forgetAIChannels, object: nil)
                }
            }
        }

        Settings {
            SettingsView()
        }
    }
}

struct NewTabButton: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button("New Tab") {
            TabHost.pending = NSApp.keyWindow
            openWindow(value: TabRequest(url: homeURL))
        }
        .keyboardShortcut("t")
    }
}

/// Native window tabs: a window opened as a tab is attached to the window that requested it.
enum TabHost {
    static weak var pending: NSWindow?
}

struct WindowTabbing: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView { TabbingView() }
    func updateNSView(_ nsView: NSView, context: Context) {}

    final class TabbingView: NSView {
        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            guard let window = window else { return }
            window.tabbingMode = .preferred
            guard let host = TabHost.pending, host !== window else { return }
            TabHost.pending = nil
            if host.tabbedWindows?.contains(window) != true {
                host.addTabbedWindow(window, ordered: .above)
            }
            window.makeKeyAndOrderFront(nil)
        }
    }
}

struct SettingsView: View {
    @AppStorage(Pref.showShorts) private var showShorts = true
    @AppStorage(Pref.showAI) private var showAI = true

    var body: some View {
        Form {
            Toggle("Show Shorts", isOn: $showShorts)
            Toggle("Show AI videos", isOn: $showAI)
            Text("AI videos are detected by YouTube's AI disclosure label. Channels caught once are also hidden from feeds.")
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Button("Forget Learned AI Channels") {
                NotificationCenter.default.post(name: .forgetAIChannels, object: nil)
            }
        }
        .padding(20)
        .frame(width: 380)
    }
}
