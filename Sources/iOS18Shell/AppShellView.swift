import SwiftUI

/// A ready-made application shell built entirely on official Apple
/// frameworks — the iOS 18 / Xcode 16 `TabView` APIs (`Tab`,
/// `TabSection`, `.sidebarAdaptable`, `TabViewCustomization`), plus
/// per-tab `NavigationStack`s, `.searchable` wiring, and scene-storage
/// selection restoration. No third-party dependencies.
///
/// Hand it your tabs; `AppShellView` picks the right chrome per platform:
///
/// - **iPhone**: the system bottom tab bar.
/// - **iPad & Mac**: `.sidebarAdaptable` — people can flip between a
///   compact tab bar and a full sidebar, and can drag to reorder or hide
///   tabs (persisted via `TabViewCustomization`).
/// - **Vision Pro**: same sidebar-adaptable behavior as iPad/Mac.
/// - **Apple Watch**: the standard vertical paging carousel.
/// - **Apple TV**: the standard top-aligned, focus-driven tab bar.
///
/// Every tab gets its own `NavigationStack` (push/pop history, deep-link
/// target) and the shell remembers which tab was selected across
/// scene restoration via `@SceneStorage`. Wrap your existing backend-driven
/// screens as ``AppTab`` content and drop this in at the root of your
/// `App`:
///
/// ```swift
/// @main
/// struct MyApp: App {
///     var body: some Scene {
///         WindowGroup {
///             AppShellView(tabs: [
///                 AppTab(id: "home", title: "Home", systemImage: "house") {
///                     HomeView() // your existing view
///                 },
///                 AppTab(id: "search", title: "Search", systemImage: "magnifyingglass", role: .search) {
///                     SearchView()
///                 }
///             ])
///         }
///     }
/// }
/// ```
public struct AppShellView: View {
    private let tabs: [AppTab]
    private let groups: [AppTabGroup]
    private let initialSelection: String?

    @StateObject private var navigator: AppShellNavigator
    @AppStorage("iOS18Shell.tabCustomization") private var customization = TabViewCustomization()
    @SceneStorage("iOS18Shell.selectedTab") private var storedSelection = ""

    /// - Parameters:
    ///   - tabs: Top-level tabs, shown ungrouped.
    ///   - groups: Optional labeled sections, shown as sidebar headers
    ///     on iPad/Mac/Vision Pro.
    ///   - navigator: Supply your own ``AppShellNavigator`` when you need
    ///     to drive tab selection or push navigation from outside the
    ///     shell (deep links, push notifications). Omit it to let the
    ///     shell own its own.
    ///   - initialSelection: The tab id selected when no valid scene
    ///     selection can be restored. Defaults to the first tab.
    public init(
        tabs: [AppTab],
        groups: [AppTabGroup] = [],
        navigator: AppShellNavigator? = nil,
        initialSelection: String? = nil
    ) {
        self.tabs = tabs
        self.groups = groups
        self.initialSelection = initialSelection
        _navigator = StateObject(wrappedValue: navigator ?? AppShellNavigator())
    }

    public var body: some View {
        TabView(selection: $navigator.selection) {
            ForEach(tabs) { tab in
                Tab(tab.title, systemImage: tab.systemImage, value: tab.id, role: tab.role.native) {
                    tabContent(for: tab)
                }
                .customizationID("shell.tab.\(tab.id)")
            }

            ForEach(groups) { group in
                TabSection(group.title) {
                    ForEach(group.tabs) { tab in
                        Tab(tab.title, systemImage: tab.systemImage, value: tab.id, role: tab.role.native) {
                            tabContent(for: tab)
                        }
                        .customizationID("shell.tab.\(tab.id)")
                    }
                }
                .customizationID("shell.group.\(group.id)")
                .defaultVisibility(group.hiddenFromCompactTabBar ? .hidden : .visible, for: .tabBar)
            }
        }
        .applySidebarAdaptableStyle(customization: $customization)
        .onAppear(perform: restoreSelectionIfNeeded)
        .onChange(of: navigator.selection) { _, newValue in
            guard !newValue.isEmpty else { return }
            guard allTabIDs().contains(newValue) else {
                navigator.selection = allTabIDs().first ?? ""
                return
            }
            storedSelection = newValue
        }
        .onChange(of: allTabIDs()) { _, knownIDs in
            if !knownIDs.contains(navigator.selection) {
                navigator.selection = knownIDs.first ?? ""
            }
        }
    }

    private func restoreSelectionIfNeeded() {
        let knownIDs = allTabIDs()
        if knownIDs.contains(navigator.selection) { return }
        if knownIDs.contains(storedSelection) {
            navigator.selection = storedSelection
        } else if let initialSelection, knownIDs.contains(initialSelection) {
            navigator.selection = initialSelection
        } else {
            navigator.selection = knownIDs.first ?? ""
        }
    }

    private func allTabIDs() -> [String] {
        tabs.map(\.id) + groups.flatMap { $0.tabs.map(\.id) }
    }

    @ViewBuilder
    private func tabContent(for tab: AppTab) -> some View {
        NavigationStack(path: navigator.path(for: tab.id)) {
            Group {
                if tab.role == .search {
                    tab.content()
                        .environment(\.appShellSearchQuery, navigator.searchText(for: tab.id).wrappedValue)
                        .searchable(text: navigator.searchText(for: tab.id), prompt: tab.title)
                } else {
                    tab.content()
                }
            }
        }
    }
}

private extension View {
    /// `.sidebarAdaptable` + `TabViewCustomization` only exist on
    /// platforms with a sidebar concept (iPad, Mac, Vision Pro). Apple
    /// Watch and Apple TV keep their platform-standard `TabView`
    /// presentation untouched.
    @ViewBuilder
    func applySidebarAdaptableStyle(customization: Binding<TabViewCustomization>) -> some View {
        #if os(iOS) || os(macOS) || os(visionOS)
        self
            .tabViewStyle(.sidebarAdaptable)
            .tabViewCustomization(customization)
        #else
        self
        #endif
    }
}
