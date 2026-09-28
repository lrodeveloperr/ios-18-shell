import SwiftUI

/// Shared navigation state for ``AppShellView``: which tab is selected,
/// each tab's own push/pop stack, and each searchable tab's query text.
///
/// Create your own instance when you need to drive the shell from
/// outside — most commonly for deep linking:
///
/// ```swift
/// @main
/// struct MyApp: App {
///     @StateObject private var navigator = AppShellNavigator()
///
///     var body: some Scene {
///         WindowGroup {
///             AppShellView(tabs: tabs, navigator: navigator)
///                 .onOpenURL { url in
///                     // Map your own URL scheme to a tab + route.
///                     navigator.navigate(to: "library", pushing: route(for: url))
///                 }
///         }
///     }
/// }
/// ```
///
/// If you don't supply one, `AppShellView` creates and owns its own.
@MainActor
public final class AppShellNavigator: ObservableObject {
    /// The currently selected tab id. Empty until the shell resolves an
    /// initial selection on first appearance.
    @Published public var selection: String = ""

    @Published private var paths: [String: NavigationPath] = [:]
    @Published private var searchTexts: [String: String] = [:]

    public init() {}

    /// A `NavigationStack`-ready binding to the given tab's push/pop path.
    public func path(for tabID: String) -> Binding<NavigationPath> {
        Binding(
            get: { [weak self] in self?.paths[tabID] ?? NavigationPath() },
            set: { [weak self] in self?.paths[tabID] = $0 }
        )
    }

    /// A `.searchable(text:)`-ready binding to the given tab's query text.
    public func searchText(for tabID: String) -> Binding<String> {
        Binding(
            get: { [weak self] in self?.searchTexts[tabID] ?? "" },
            set: { [weak self] in self?.searchTexts[tabID] = $0 }
        )
    }

    /// Pops the given tab's navigation stack back to its root — the
    /// standard response to a repeat tap on an already-selected tab.
    public func popToRoot(_ tabID: String) {
        paths[tabID] = NavigationPath()
    }

    /// Selects a tab and, optionally, pushes a value onto its navigation
    /// stack. This is the building block for deep linking and push
    /// notification routing: map your incoming URL/payload to a tab id
    /// and a `Hashable` route your tab's content already handles via
    /// `.navigationDestination(for:)`, then call this.
    public func navigate<Route: Hashable>(to tabID: String, pushing route: Route? = nil) {
        selection = tabID
        if let route {
            paths[tabID, default: NavigationPath()].append(route)
        }
    }
}
