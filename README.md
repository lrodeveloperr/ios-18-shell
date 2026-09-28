# ios-18-shell

A drop-in SwiftUI app shell built entirely on **official Apple
frameworks** — SwiftUI, SwiftData, TipKit, AuthenticationServices — so
you can put a native iOS 18-style app in front of your existing
backend/view-model code without rewriting it and without pulling in any
third-party dependency.

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

`AppShellView` owns navigation chrome — tabs, sidebar/tab-bar
adaptation, per-tab push navigation, search, and selection restoration —
so the content of each tab is just whatever `View` you already have.

## What's included

| Piece | What it gives you | Built on |
|---|---|---|
| `AppShellView` | The adaptive tab bar/sidebar shell itself, each tab in its own `NavigationStack`, selection restored across launches | `TabView`, `Tab`, `TabSection`, `NavigationStack`, `@SceneStorage` |
| `AppShellNavigator` | Shared state for selected tab + per-tab push path + per-tab search text; the hook for deep linking (`navigate(to:pushing:)`) | `ObservableObject`, `NavigationPath` |
| `appShellSearchQuery` environment key | The search-role tab gets `.searchable()` wired automatically; read the live query with `@Environment(\.appShellSearchQuery)` | `.searchable(text:)` |
| `AppLoadState` / `AppAsyncStateView` | Consistent loading / empty / error UI for any backend call, no hand-rolled `if/else` per screen | `ContentUnavailableView`, `ProgressView` |
| `AppShellSettingsView` / `AppShellSettingsPane` | A standard multi-pane macOS Settings window | `TabView` + `.tabItem` (the same pattern macOS's own Settings uses) |
| `AppShellCommands` | ⌘1…⌘9 menu bar shortcuts that jump between tabs | `Commands`, `CommandMenu` |
| `AppShellModelContainer` | One-line `ModelContainer` setup for your `@Model` types | SwiftData |
| `AppShellTips` | One-line TipKit configuration for onboarding tips | TipKit |
| `AppShellSignInWithAppleButton` | A ready "Sign in with Apple" button (iOS/macOS/visionOS only — there's no watchOS/tvOS button in AuthenticationServices) | AuthenticationServices |

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

**Option B — copy the source:** everything under `Sources/iOS18Shell/`
has no dependencies beyond Apple's own frameworks — drag the folder
straight into your existing Xcode project if you'd rather not add a
package. Skip `Onboarding/`, `Persistence/`, or `Auth/` individually if
you don't want TipKit, SwiftData, or Sign in with Apple.

## Usage

Minimal shell:

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

Search — just read the environment value, no extra `@State`:

```swift
struct SearchView: View {
    @Environment(\.appShellSearchQuery) private var query
    var body: some View { List(results(matching: query)) { ... } }
}
```

Loading / empty / error states for any backend call:

```swift
struct LibraryView: View {
    @State private var state: AppLoadState<[Album]> = .loading
    var body: some View {
        AppAsyncStateView(state, emptyTitle: "No Albums", emptySystemImage: "square.stack", retry: load) { albums in
            List(albums) { Text($0.title) }
        }
        .task { await load() }
    }
    private func load() async { /* set state = .loading / .loaded / .empty / .failed(error) */ }
}
```

Deep linking, own a shared navigator and drive it from `.onOpenURL`:

```swift
@StateObject private var navigator = AppShellNavigator()
// ...
AppShellView(tabs: tabs, navigator: navigator)
    .onOpenURL { url in
        navigator.navigate(to: "library", pushing: route(for: url))
    }
```

Persistence (SwiftData) and onboarding (TipKit), wired at the app root:

```swift
init() { AppShellTips.configure() }

var body: some Scene {
    WindowGroup { AppShellView(tabs: tabs) }
        .modelContainer(AppShellModelContainer.make(for: [Album.self]))
}
```

macOS menu bar tab-switching and a Settings window:

```swift
var body: some Scene {
    WindowGroup { AppShellView(tabs: tabs, navigator: navigator) }
        .commands { AppShellCommands(navigator: navigator, tabs: tabs) }
    Settings {
        AppShellSettingsView(panes: [
            AppShellSettingsPane(id: "general", title: "General", systemImage: "gearshape") { GeneralView() }
        ])
    }
}
```

Sign in with Apple:

```swift
AppShellSignInWithAppleButton { result in
    // result: Result<ASAuthorization, Error> — send the credential to your backend.
}
```

See `Examples/ShellExampleApp.swift` for all of the above wired together
in one runnable example app.

## Project layout

```
Package.swift
Sources/iOS18Shell/
  AppTab.swift               // AppTab, AppTabGroup, AppTabRole models
  AppShellView.swift         // the cross-platform shell itself
  AppShellNavigator.swift    // shared selection / push-path / search state
  Search/
    AppShellSearchEnvironment.swift
  States/
    AppLoadState.swift
    AppAsyncStateView.swift
  macOS/
    AppShellSettingsPane.swift
    AppShellCommands.swift
  Persistence/
    AppShellModelContainer.swift   // SwiftData
  Onboarding/
    AppShellTips.swift             // TipKit
  Auth/
    AppShellSignInWithAppleButton.swift // AuthenticationServices, iOS/macOS/visionOS only
Tests/iOS18ShellTests/
  AppTabTests.swift
  AppShellNavigatorTests.swift
Examples/
  ShellExampleApp.swift      // full usage example, every piece wired together
```

## Design notes

- Everything is chrome/plumbing only: `AppShellView` doesn't know or
  care what's inside each tab, so it sits in front of whatever backend
  networking/state layer your screens already use.
- Tabs are data-driven (`ForEach` inside `TabView`), so you can build
  the `[AppTab]` array dynamically — e.g. from a feature-flagged or
  role-based navigation config — without hand-writing a `switch`.
- `TabViewCustomization` is wired up so people can reorder or hide tabs
  on iPad/Mac/Vision Pro; their choices persist automatically.
- No third-party dependencies anywhere in this package — every piece is
  a first-party Apple framework (SwiftUI, SwiftData, TipKit,
  AuthenticationServices), so there's nothing extra to audit or update.
- Not affiliated with or endorsed by Apple Inc.
