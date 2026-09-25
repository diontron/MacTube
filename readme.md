# MacTube 2

Fork of [MacTube](https://github.com/ryan-mangeno/MacTube), a WebKit wrapper for YouTube on macOS, with content filters.

## Filters

Menu bar → **Filters** (or **MacTube 2 → Settings…**, ⌘,):

- **Show Shorts** (⇧⌘1) — off hides Shorts shelves, Shorts in feeds/search, the Shorts sidebar entry, and redirects `/shorts/…` to Home.
- **Show AI Videos** (⇧⌘2) — off blocks videos/Shorts carrying YouTube's AI disclosure label ("Made with AI — Sounds or visuals were altered or fully generated", or the older "Altered or synthetic content"). The video's page is fetched logged-out in English and checked for the label text, so it works whatever your YouTube language is.
  - A blocked video shows an overlay with **Go back / Next Short** and **Watch anyway**.
  - Channels caught with a labeled video are remembered and hidden from feeds. **Filters → Forget Learned AI Channels** clears that list.

Limits: YouTube shows no AI label on feed thumbnails, so feed hiding relies on learned channels. Unlabeled AI content isn't detected. YouTube markup changes can break selectors.

## Build

Requires Xcode.

```bash
./build-dmg.sh      # → "MacTube 2.dmg"
```

Or open `MacTube.xcodeproj` and press ⌘R. The app is ad-hoc signed ("Sign to Run Locally"). On first launch from the DMG, right-click → Open, or run `xattr -dr com.apple.quarantine "/Applications/MacTube 2.app"`.

## Debugging detection

On macOS 13.3+ the web view is inspectable: Safari → Develop → [your Mac] → MacTube 2. `window.__mt2` exposes `update({showShorts, showAI})` and `forgetChannels()`; learned channels are in `localStorage['mt2.aiChannels']`.
