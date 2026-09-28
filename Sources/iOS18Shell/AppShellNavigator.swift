import SwiftUI

/// Shared navigation state for ``AppShellView``: which tab is selected,
/// each tab's own push/pop stack, and each searchable tab's query text.
///
/// Pass the same instance to `AppShellView`, `appShellTab`, and any
/// deep-link handler. See `Examples/ShellExampleApp.swift` for wiring.
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

    /// Selects a tab without changing its navigation stack.
    public func navigate(to tabID: String) {
        selection = tabID
    }

    /// Selects a tab and optionally pushes a `Hashable` route that its
    /// content handles with `.navigationDestination(for:)`.
    public func navigate<Route: Hashable>(to tabID: String, pushing route: Route?) {
        selection = tabID
        if let route {
            paths[tabID, default: NavigationPath()].append(route)
        }
    }
}
