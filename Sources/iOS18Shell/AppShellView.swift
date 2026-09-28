import SwiftUI

/// A ready-made application shell built on the iOS 18 / Xcode 16
/// `TabView` APIs (`Tab`, `TabSection`, `.sidebarAdaptable`,
/// `TabViewCustomization`).
///
/// Hand it your tabs; `AppShellView` picks the right chrome per platform:
///
/// - **iPhone**: the floating, translucent bottom tab bar.
/// - **iPad & Mac**: `.sidebarAdaptable` — people can flip between a
///   compact tab bar and a full sidebar, and can drag to reorder or hide
///   tabs (persisted via `TabViewCustomization`).
/// - **Vision Pro**: same sidebar-adaptable behavior as iPad/Mac.
/// - **Apple Watch**: the standard vertical paging carousel.
/// - **Apple TV**: the standard top-aligned, focus-driven tab bar.
///
/// This type owns navigation chrome only — wrap your existing
/// backend-driven screens as ``AppTab`` content and drop this in at the
/// root of your `App`:
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

    @State private var selection: String
    @State private var customization = TabViewCustomization()

    /// - Parameters:
    ///   - tabs: Top-level tabs, shown ungrouped.
    ///   - groups: Optional labeled sections, shown as sidebar headers
    ///     on iPad/Mac/Vision Pro.
    ///   - initialSelection: The tab id selected on first appearance.
    ///     Defaults to the first tab (or the first tab of the first group).
    public init(
        tabs: [AppTab],
        groups: [AppTabGroup] = [],
        initialSelection: String? = nil
    ) {
        self.tabs = tabs
        self.groups = groups
        let firstID = tabs.first?.id ?? groups.first?.tabs.first?.id ?? ""
        _selection = State(initialValue: initialSelection ?? firstID)
    }

    public var body: some View {
        TabView(selection: $selection) {
            ForEach(tabs) { tab in
                Tab(tab.title, systemImage: tab.systemImage, value: tab.id, role: tab.role.native) {
                    tab.content()
                }
                .customizationID("shell.tab.\(tab.id)")
            }

            ForEach(groups) { group in
                TabSection(group.title) {
                    ForEach(group.tabs) { tab in
                        Tab(tab.title, systemImage: tab.systemImage, value: tab.id) {
                            tab.content()
                        }
                        .customizationID("shell.tab.\(tab.id)")
                    }
                }
                .customizationID("shell.group.\(group.id)")
                .defaultVisibility(group.hiddenFromCompactTabBar ? .hidden : .visible, for: .tabBar)
            }
        }
        .applySidebarAdaptableStyle(customization: $customization)
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
