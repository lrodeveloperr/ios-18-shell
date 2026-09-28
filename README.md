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
| iPhone | System bottom tab bar (appearance follows the installed OS) |
| iPad | `.sidebarAdaptable` — tab bar or full sidebar, user-toggleable |
| Mac | `.sidebarAdaptable` sidebar (no bottom tab bar, per macOS HIG) |
| Vision Pro | Same sidebar-adaptable behavior as iPad/Mac |
| Apple Watch | Standard vertical paging carousel |
| Apple TV | Standard top-aligned, focus-driven tab bar |

`AppShellView` owns sidebar/tab-bar adaptation, customization and scene
selection. Declare tabs statically with `appShellTab` and `TabSection`;
the helper supplies each destination's navigation stack and search.

## What's included

| Piece | What it gives you | Built on |
|---|---|---|
| `AppShellView` / `appShellTab` | Native tab bar/sidebar, per-tab `NavigationStack`, best-effort scene selection restoration | `TabView`, `Tab`, `TabSection`, `NavigationStack`, `@SceneStorage` |
| `AppShellNavigator` | Shared state for selected tab + per-tab push path + per-tab search text; the hook for deep linking (`navigate(to:pushing:)`) | `ObservableObject`, `NavigationPath` |
| `appShellSearchQuery` environment key | The search-role tab gets `.searchable()` wired automatically; read the live query with `@Environment(\.appShellSearchQuery)` | `.searchable(text:)` |
| `AppLoadState` / `AppAsyncStateView` | Consistent loading / empty / error UI for any backend call, no hand-rolled `if/else` per screen | `ContentUnavailableView`, `ProgressView` |
| `AppShellSettingsView` / `AppShellSettingsPane` | A multi-pane macOS Settings window | `TabView` + `.tabItem` |
| `AppShellCommands` | ⌘1…⌘9 shortcuts for the first nine top-level and grouped destinations (unavailable on watchOS) | `Commands`, `CommandMenu` |
| `AppShellModelContainer` | Throwing `ModelContainer` setup so storage failures can be handled | SwiftData |
| `AppShellTips` | Throwing TipKit configuration for contextual tips | TipKit |
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
        WindowGroup { RootView() }
    }
}

struct RootView: View {
    @StateObject private var navigator = AppShellNavigator()
    private let home = AppTab(id: "home", title: "Home", systemImage: "house") { HomeView() }
    private let search = AppTab(id: "search", title: "Search", systemImage: "magnifyingglass", role: .search) { SearchView() }

    var body: some View {
        AppShellView(tabIDs: ["home", "search"], navigator: navigator) {
            appShellTab(home, navigator: navigator)
            appShellTab(search, navigator: navigator)
        }
    }
}
```

Grouped tabs (shown as a labeled sidebar section on iPad/Mac/Vision Pro):

```swift
AppShellView(tabIDs: ["home", "downloads", "favorites"], navigator: navigator) {
    appShellTab(home, navigator: navigator)
    TabSection("Library") {
        appShellTab(downloads, navigator: navigator)
        appShellTab(favorites, navigator: navigator)
    }
    .customizationID("shell.group.library")
}
```

On iPhone, `TabSection` destinations are hidden from the compact tab
bar by default. Provide a visible top-level tab with links to those
destinations, or present a different compact tab structure. The full
example switches to a visible Library tab and Account tab in compact
layouts, while keeping sections in regular layouts.

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
AppShellView(tabIDs: tabs.map(\.id), navigator: navigator) {
    appShellTab(tabs[0], navigator: navigator)
    appShellTab(tabs[1], navigator: navigator)
}
    .onOpenURL { url in
        navigator.navigate(to: "home") // Validate and map the URL to a declared tab ID.
    }
```

Persistence (SwiftData) and onboarding (TipKit), wired at the app root:

```swift
init() {
    do { try AppShellTips.configure() }
    catch { print("TipKit setup failed: \(error)") }
}

var body: some Scene {
    WindowGroup {
        if let container = try? AppShellModelContainer.make(for: [Album.self]) {
            AppShellView(tabIDs: tabs.map(\.id), navigator: navigator) {
                appShellTab(tabs[0], navigator: navigator)
            }.modelContainer(container)
        } else {
            ContentUnavailableView("Data Unavailable", systemImage: "externaldrive.badge.exclamationmark")
        }
    }
}
```

macOS menu bar tab-switching and a Settings window:

```swift
var body: some Scene {
    WindowGroup {
        AppShellView(tabIDs: tabs.map(\.id), navigator: navigator) {
            appShellTab(tabs[0], navigator: navigator)
        }
    }
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
AppShellSignInWithAppleButton(requestedScopes: [.email]) { result in
    // result: Result<ASAuthorization, Error> — send the credential to your backend.
}
```

See `Examples/ShellExampleApp.swift` for integration wiring. The example
is source-only rather than a runnable app target; CI typechecks it for
macOS and iOS Simulator.

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
- Declare `appShellTab` calls and `TabSection` structure in the native
  tab content builder. Xcode 16's `ForEach` view builder cannot emit
  the new `Tab` content type; apps with different destinations compose
  their static structure from the app's frozen flow.
- `TabViewCustomization` uses `@AppStorage` so sidebar and tab-bar
  choices persist. `@SceneStorage` restores a tab selection when the
  system restores that scene; it is not a permanent launch preference.
- `initialSelection` is used only when no valid scene selection exists.
  A hidden compact tab needs an explicit in-app route on iPhone; don't
  depend on SwiftUI supplying a "More" tab.
- A repeated tap does not automatically pop a navigation stack; use
  `navigator.popToRoot(_:)` when your app explicitly offers that action.
- No third-party dependencies anywhere in this package — every piece is
  a first-party Apple framework (SwiftUI, SwiftData, TipKit,
  AuthenticationServices), so there's nothing extra to audit or update.
- Not affiliated with or endorsed by Apple Inc.
