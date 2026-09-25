<p align="center">
  <img src="MacTube/Assets.xcassets/AppIcon.appiconset/81504064a338bd4299acf122b1d1a628_YouTube_1024x1024x32.png" width="180" alt="MacTube 2 icon">
</p>

<h1 align="center">MacTube 2</h1>

<p align="center">
  YouTube as a real Mac app — without Shorts, without AI slop, without opening Chrome.
</p>

<p align="center">
  <a href="https://github.com/depo23/MacTube2/releases/latest/download/MacTube2.dmg"><img src="https://img.shields.io/badge/Download-MacTube%202%20for%20macOS-black?style=for-the-badge&logo=apple" alt="Download MacTube 2"></a>
</p>

<p align="center"><sub>macOS 13 Ventura or later · Apple Silicon & Intel · always the latest build</sub></p>

---

## Why MacTube 2

**Watch what you chose, not what the algorithm pushes.**

- **Shorts off, for good.** One switch removes Shorts from your home feed, search results, sidebar and recommendations. Shorts links take you back Home instead of down the scroll hole.
- **Skip AI-generated videos.** Videos YouTube labels *Made with AI* are stopped before they play. Channels caught posting them disappear from your feed too, so it gets cleaner the more you watch. One click to watch anyway if you want.
- **Real Mac tabs.** ⌘T opens a new tab, just like Safari. Keep a tutorial, a playlist and a talk open side by side.
- **Links go where they should.** Links in descriptions and comments open in your default browser — no "Are you sure you want to leave YouTube?" detours.
- **Feels native.** Its own Dock icon, its own window, light and dark mode, settings remembered between launches.

## Controls

| | Where | Shortcut |
| --- | --- | --- |
| Show / hide Shorts | **Filters** menu or **Settings** | ⇧⌘1 |
| Show / hide AI videos | **Filters** menu or **Settings** | ⇧⌘2 |
| New tab | **File** menu | ⌘T |
| New window | **File** menu | ⌘N |
| Settings | **MacTube 2** menu | ⌘, |

## Install

1. [Download MacTube2.dmg](https://github.com/depo23/MacTube2/releases/latest/download/MacTube2.dmg) and drag **MacTube 2** into Applications.
2. First launch only: right-click the app → **Open** → **Open**. (It isn't signed with a paid Apple developer account, so macOS asks once.)

## Good to know

- AI detection relies on YouTube's own *Made with AI* label. Videos their creators don't disclose — and YouTube doesn't catch — will still show up.
- Changed your mind about a channel? **Filters → Forget Learned AI Channels** resets the list.

## Build it yourself

Every push to `master` builds a new release automatically. To build locally (needs Xcode): `./build-dmg.sh`.

---

<sub>Based on [MacTube](https://github.com/ryan-mangeno/MacTube) by Kevin Dion. Not affiliated with YouTube or Google.</sub>
