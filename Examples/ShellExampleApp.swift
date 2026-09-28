import SwiftUI
import SwiftData
import iOS18Shell

/// Example wiring for the full `iOS18Shell` package. This file is not
/// compiled into the `iOS18Shell` library target — copy the parts you
/// need into your own app. Every view below is a stand-in for a real,
/// backend-driven screen; swap them for the real thing.
@main
struct ShellExampleApp: App {
    private let container: Result<ModelContainer, Error>

    init() {
        container = Result { try AppShellModelContainer.make(for: [DownloadRecord.self]) }
        // Apple's own TipKit onboarding tips — one-time setup.
        do {
            try AppShellTips.configure()
        } catch {
            print("TipKit setup failed: \(error)")
        }
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
                ]
            )
        ]
    }

    var body: some Scene {
        WindowGroup {
            switch container {
            case .success(let modelContainer):
                ShellExampleTabs(tabs: tabs, groups: groups)
                    .modelContainer(modelContainer)
            case .failure:
                ContentUnavailableView("Data Unavailable", systemImage: "externaldrive.badge.exclamationmark", description: Text("Please reopen the app or contact support if this continues."))
            }
        }
        #if os(macOS)
        .commands {
            AppShellCommands(tabs: tabs, groups: groups)
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

private enum LibraryRoute: Hashable {
    case downloads
    case favorites
}

private struct ShellExampleTabs: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @StateObject private var navigator = AppShellNavigator()
    let tabs: [AppTab]
    let groups: [AppTabGroup]

    private var isCompact: Bool { horizontalSizeClass == .compact }

    var body: some View {
        AppShellView(
            tabIDs: isCompact
                ? ["home", "search", "library", "account"]
                : tabs.map(\.id) + groups.flatMap { $0.tabs.map(\.id) },
            navigator: navigator
        ) {
            appShellTab(tabs[0], navigator: navigator)
            appShellTab(tabs[1], navigator: navigator)
            if isCompact {
                appShellTab(AppTab(id: "library", title: "Library", systemImage: "books.vertical") {
                    List {
                        NavigationLink("Downloads", value: LibraryRoute.downloads)
                        NavigationLink("Favorites", value: LibraryRoute.favorites)
                    }
                    .navigationTitle("Library")
                    .navigationDestination(for: LibraryRoute.self) { route in
                        switch route {
                        case .downloads: DownloadsView()
                        case .favorites: FavoritesView()
                        }
                    }
                }, navigator: navigator)
                appShellTab(groups[1].tabs[0], navigator: navigator)
            } else {
                TabSection("Library") {
                    appShellTab(groups[0].tabs[0], navigator: navigator)
                    appShellTab(groups[0].tabs[1], navigator: navigator)
                }
                .customizationID("shell.group.library")
                TabSection("Settings") {
                    appShellTab(groups[1].tabs[0], navigator: navigator)
                }
                .customizationID("shell.group.settings")
                .defaultVisibility(.hidden, for: .tabBar)
            }
        }
        .onOpenURL { url in
            guard let tabID = url.host else { return }
            switch tabID {
            case "home", "search", "account":
                navigator.navigate(to: tabID)
            case "downloads":
                if isCompact { navigator.navigate(to: "library", pushing: LibraryRoute.downloads) }
                else { navigator.navigate(to: tabID) }
            case "favorites":
                if isCompact { navigator.navigate(to: "library", pushing: LibraryRoute.favorites) }
                else { navigator.navigate(to: tabID) }
            case "library":
                navigator.navigate(to: isCompact ? "library" : "downloads")
            default:
                break
            }
        }
        #if os(macOS)
        .focusedSceneObject(navigator)
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
            .accessibilityIdentifier("shell.home.content")
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
                    .accessibilityIdentifier("shell.search.content")
            } else {
                Text("Results for \u{201c}\(query)\u{201d}")
                    .accessibilityIdentifier("shell.search.content")
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
            List {
                Text("Your Downloads")
                    .accessibilityIdentifier("shell.downloads.content")
                ForEach(downloads, id: \.self) { Text($0) }
            }
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
                .accessibilityIdentifier("shell.account.content")
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
