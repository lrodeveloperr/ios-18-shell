# ios-18-shell

A drop-in SwiftUI app shell built on the iOS 18 / Xcode 16 `TabView`
APIs (`Tab`, `TabSection`, `.sidebarAdaptable`, `TabViewCustomization`),
so you can put a native iOS 18-style navigation shell in front of your
existing backend/view-model code without rewriting it.

It adapts automatically per Apple platform, following each platform's
Human Interface Guidelines for navigation:

| Platform | Presentation |
|---|---|
| iPhone | Floating, translucent bottom tab bar |
| iPad | `.sidebarAdaptable` — tab bar or full sidebar, user-toggleable |
| Mac | `.sidebarAdaptable` sidebar (no bottom tab bar, per macOS HIG) |
| Vision Pro | Same sidebar-adaptable behavior as iPad/Mac |
| Apple Watch | Standard vertical paging carousel |
| Apple TV | Standard top-aligned, focus-driven tab bar |

`AppShellView` only owns navigation chrome (tab id, title, SF Symbol,
optional `.search` role, optional grouping). The content of each tab is
just whatever `View` you already have — a `HomeView`, a `SearchView`,
whatever your backend already renders.

## Requirements

- Xcode 16+ (SwiftUI's `Tab` / `TabSection` / `.sidebarAdaptable` APIs
  are iOS 18 / iPadOS 18 / macOS 15 / watchOS 11 / tvOS 18 and later).
- This package targets Apple platforms only — it cannot be built or
  tested on Linux (there's no SwiftUI outside Darwin), so `swift build`
  in this container will not work. Open it in Xcode on macOS to build,
  run, and preview.

## Adding it to your app

**Option A — Swift Package:** In Xcode, `File > Add Package Dependencies…
> Add Local…` and point at this repo, or add it as a git dependency.
Add the `iOS18Shell` library to your app target.

**Option B — copy the source:** `Sources/iOS18Shell/` is two small files
(`AppTab.swift`, `AppShellView.swift`) with no dependencies beyond
SwiftUI — drag them straight into your existing Xcode project if you'd
rather not add a package.

## Usage

```swift
import SwiftUI
import iOS18Shell

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            AppShellView(tabs: [
                AppTab(id: "home", title: "Home", systemImage: "house") {
                    HomeView() // your existing screen
                },
                AppTab(id: "search", title: "Search", systemImage: "magnifyingglass", role: .search) {
                    SearchView()
                }
            ])
        }
    }
}
```

Grouped tabs (shown as a labeled sidebar section on iPad/Mac/Vision Pro):

```swift
AppShellView(
    tabs: [/* ... */],
    groups: [
        AppTabGroup(id: "library", title: "Library", tabs: [
            AppTab(id: "downloads", title: "Downloads", systemImage: "arrow.down.circle") { DownloadsView() },
            AppTab(id: "favorites", title: "Favorites", systemImage: "star") { FavoritesView() }
        ]),
        AppTabGroup(id: "settings", title: "Settings", tabs: [
            AppTab(id: "account", title: "Account", systemImage: "person.crop.circle") { AccountView() }
        ], hiddenFromCompactTabBar: true) // keep it off the iPhone tab bar
    ]
)
```

See `Examples/ShellExampleApp.swift` for a full, runnable example app
with stand-in screens you can replace with your own.

## Project layout

```
Package.swift
Sources/iOS18Shell/
  AppTab.swift        // AppTab, AppTabGroup, AppTabRole models
  AppShellView.swift  // the cross-platform shell itself
Tests/iOS18ShellTests/
  AppTabTests.swift   // non-rendering smoke tests for the models
Examples/
  ShellExampleApp.swift // full usage example
```

## Design notes

- `AppShellView` is intentionally chrome-only: it doesn't know or care
  what's inside each tab, so it sits in front of whatever backend
  networking/state layer your screens already use.
- Tabs are data-driven (`ForEach` inside `TabView`), so you can build
  the `[AppTab]` array dynamically — e.g. from a feature-flagged or
  role-based navigation config — without hand-writing a `switch`.
- `TabViewCustomization` is wired up so people can reorder or hide tabs
  on iPad/Mac/Vision Pro; their choices persist automatically.
- Not affiliated with or endorsed by Apple Inc.
