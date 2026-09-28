import SwiftUI
import SwiftData
import iOS18Shell

/// Example wiring for the full `iOS18Shell` package. This file is not
/// compiled into the `iOS18Shell` library target — copy the parts you
/// need into your own app. Every view below is a stand-in for a real,
/// backend-driven screen; swap them for the real thing.
@main
struct ShellExampleApp: App {
    @StateObject private var navigator = AppShellNavigator()

    init() {
        // Apple's own TipKit onboarding tips — one-time setup.
        AppShellTips.configure()
    }

    private var tabs: [AppTab] {
        [
            AppTab(id: "home", title: "Home", systemImage: "house") {
                HomeView()
            },
            AppTab(id: "search", title: "Search", systemImage: "magnifyingglass", role: .search) {
                SearchView()
            }
        ]
    }

    private var groups: [AppTabGroup] {
        [
            AppTabGroup(
                id: "library",
                title: "Library",
                tabs: [
                    AppTab(id: "downloads", title: "Downloads", systemImage: "arrow.down.circle") {
                        DownloadsView()
                    },
                    AppTab(id: "favorites", title: "Favorites", systemImage: "star") {
                        FavoritesView()
                    }
                ]
            ),
            AppTabGroup(
                id: "settings",
                title: "Settings",
                tabs: [
                    AppTab(id: "account", title: "Account", systemImage: "person.crop.circle") {
                        AccountView()
                    }
                ],
                hiddenFromCompactTabBar: true
            )
        ]
    }

    var body: some Scene {
        WindowGroup {
            AppShellView(tabs: tabs, groups: groups, navigator: navigator)
                .onOpenURL { url in
                    // Map your own URL scheme to a tab (and, via
                    // navigator.navigate(to:pushing:), a pushed route).
                    // e.g. myapp://downloads -> select the "downloads" tab.
                    guard let tabID = url.host else { return }
                    navigator.navigate(to: tabID)
                }
        }
        .modelContainer(AppShellModelContainer.make(for: [DownloadRecord.self]))
        #if os(macOS)
        .commands {
            AppShellCommands(navigator: navigator, tabs: tabs)
        }
        #endif

        #if os(macOS)
        Settings {
            AppShellSettingsView(panes: [
                AppShellSettingsPane(id: "general", title: "General", systemImage: "gearshape") {
                    Text("General settings go here.").padding()
                },
                AppShellSettingsPane(id: "account", title: "Account", systemImage: "person.crop.circle") {
                    Text("Account settings go here.").padding()
                }
            ])
        }
        #endif
    }
}

// MARK: - SwiftData model (Apple's own persistence, no third-party ORM)

@Model
final class DownloadRecord {
    var title: String
    var downloadedAt: Date

    init(title: String, downloadedAt: Date = .now) {
        self.title = title
        self.downloadedAt = downloadedAt
    }
}

// MARK: - Stand-ins for your backend-driven views
//
// AppShellView already wraps every tab in its own NavigationStack, so
// none of these create their own.

private struct HomeView: View {
    var body: some View {
        Text("Wire this up to your existing home screen / view model.")
            .padding()
            .navigationTitle("Home")
    }
}

private struct SearchView: View {
    // AppShellView wires .searchable(text:) for the search-role tab
    // automatically; read the live query here instead of owning @State.
    @Environment(\.appShellSearchQuery) private var query

    var body: some View {
        Group {
            if query.isEmpty {
                Text("Type to search.")
            } else {
                Text("Results for \u{201c}\(query)\u{201d}")
            }
        }
        .padding()
        .navigationTitle("Search")
    }
}

private struct DownloadsView: View {
    @State private var state: AppLoadState<[String]> = .loading

    var body: some View {
        AppAsyncStateView(
            state,
            emptyTitle: "No Downloads",
            emptySystemImage: "arrow.down.circle",
            retry: retryLoad
        ) { downloads in
            List(downloads, id: \.self) { Text($0) }
        }
        .navigationTitle("Downloads")
        .task { await load() }
    }

    private func load() async {
        state = .loading
        // Stand-in for your real backend call.
        try? await Task.sleep(for: .seconds(1))
        let downloads = ["Episode 1", "Episode 2"]
        state = downloads.isEmpty ? .empty : .loaded(downloads)
    }

    private func retryLoad() {
        Task { await load() }
    }
}

private struct FavoritesView: View {
    var body: some View {
        Text("Wire this up to your existing favorites screen.")
            .padding()
            .navigationTitle("Favorites")
    }
}

private struct AccountView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Wire this up to your existing account/settings screen.")
            #if os(iOS) || os(macOS) || os(visionOS)
            AppShellSignInWithAppleButton { result in
                switch result {
                case .success:
                    break // Send credential to your backend.
                case .failure:
                    break // Show the error.
                }
            }
            .frame(maxWidth: 280)
            #endif
        }
        .padding()
        .navigationTitle("Account")
    }
}
