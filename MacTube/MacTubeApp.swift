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

@main
struct MacTubeApp: App {
    @AppStorage(Pref.showShorts) private var showShorts = true
    @AppStorage(Pref.showAI) private var showAI = true

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .commands {
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
