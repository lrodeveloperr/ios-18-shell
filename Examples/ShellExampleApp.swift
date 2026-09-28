import SwiftUI
import iOS18Shell

/// Example wiring for `AppShellView`.
///
/// This file is not compiled into the `iOS18Shell` library target — copy
/// the parts you need into your own `App` file. `HomeView`, `LibraryView`,
/// etc. below are stand-ins for your existing backend-driven screens;
/// swap them for the real thing.
@main
struct ShellExampleApp: App {
    var body: some Scene {
        WindowGroup {
            AppShellView(
                tabs: [
                    AppTab(id: "home", title: "Home", systemImage: "house") {
                        HomeView()
                    },
                    AppTab(id: "search", title: "Search", systemImage: "magnifyingglass", role: .search) {
                        SearchView()
                    }
                ],
                groups: [
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
            )
        }
    }
}

// MARK: - Stand-ins for your backend-driven views

private struct HomeView: View {
    var body: some View {
        NavigationStack {
            Text("Wire this up to your existing home screen / view model.")
                .padding()
                .navigationTitle("Home")
        }
    }
}

private struct SearchView: View {
    var body: some View {
        NavigationStack {
            Text("Wire this up to your existing search screen.")
                .padding()
                .navigationTitle("Search")
        }
    }
}

private struct DownloadsView: View {
    var body: some View {
        NavigationStack {
            Text("Wire this up to your existing downloads screen.")
                .padding()
                .navigationTitle("Downloads")
        }
    }
}

private struct FavoritesView: View {
    var body: some View {
        NavigationStack {
            Text("Wire this up to your existing favorites screen.")
                .padding()
                .navigationTitle("Favorites")
        }
    }
}

private struct AccountView: View {
    var body: some View {
        NavigationStack {
            Text("Wire this up to your existing account/settings screen.")
                .padding()
                .navigationTitle("Account")
        }
    }
}
