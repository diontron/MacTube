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
        .commands {
            CommandGroup(after: .appInfo) {
                Button("Check for Updates…") { Updater.shared.check(manual: true) }
            }
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

/// Checks GitHub for a newer release and exposes it for the in-window banner.
/// Release builds carry the CI run number as their build number (CFBundleVersion);
/// local builds are 0 and only check when asked.
final class Updater: ObservableObject {
    static let shared = Updater()

    struct Release: Equatable {
        let build: Int
        let version: String?
        let url: URL
    }

    @Published var available: Release?
    let currentBuild = Int(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "") ?? 0
    let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
    private let api = URL(string: "https://api.github.com/repos/depo23/MacTube2/releases/latest")!
    private var timer: Timer?

    private init() {
        guard currentBuild > 0 else { return }
        check()
        timer = Timer.scheduledTimer(withTimeInterval: 6 * 60 * 60, repeats: true) { [weak self] _ in self?.check() }
    }

    func check(manual: Bool = false) {
        URLSession.shared.dataTask(with: api) { [weak self] data, _, _ in
            guard let self = self else { return }
            let release = data.flatMap(Updater.parse)
            DispatchQueue.main.async {
                if let release = release, release.build > self.currentBuild {
                    self.available = release
                } else if manual {
                    let alert = NSAlert()
                    alert.messageText = release == nil ? "Couldn't check for updates" : "MacTube 2 is up to date"
                    alert.informativeText = release == nil ? "Check your connection and try again." : "You have the latest version (\(self.currentVersion))."
                    alert.runModal()
                }
            }
        }.resume()
    }

    /// Releases are compared by CI build number ("Build 12" in the notes, always increasing);
    /// the version ("v2.3" tag) is only for display.
    /// the link prefers the DMG itself, falling back to the release page.
    private static func parse(_ data: Data) -> Release? {
        guard let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any],
              let page = (json["html_url"] as? String).flatMap(URL.init(string:)) else { return nil }
        let text = ["tag_name", "name", "body"].compactMap { json[$0] as? String }.joined(separator: " ")
        guard let match = text.range(of: #"[Bb]uild[- ](\d+)"#, options: .regularExpression),
              let build = Int(text[match].filter(\.isNumber)) else { return nil }
        let dmg = (json["assets"] as? [[String: Any]])?
            .first { ($0["name"] as? String)?.hasSuffix(".dmg") == true }?["browser_download_url"] as? String
        let tag = json["tag_name"] as? String ?? ""
        let version = tag.range(of: #"^v\d+(\.\d+)+$"#, options: .regularExpression).map { _ in String(tag.dropFirst()) }
        return Release(build: build, version: version, url: dmg.flatMap(URL.init(string:)) ?? page)
    }
}

struct UpdateBanner: View {
    @ObservedObject var updater = Updater.shared

    var body: some View {
        if let release = updater.available {
            HStack(spacing: 10) {
                Image(systemName: "arrow.down.circle.fill")
                    .foregroundColor(.accentColor)
                Text("MacTube 2 \(release.version ?? "build \(release.build)") is available.")
                Spacer()
                Button("Download") { NSWorkspace.shared.open(release.url) }
                    .buttonStyle(.borderedProminent)
                Button("Later") { updater.available = nil }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.bar)
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
