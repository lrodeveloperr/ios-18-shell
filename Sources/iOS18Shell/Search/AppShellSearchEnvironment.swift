import SwiftUI

private struct AppShellSearchQueryKey: EnvironmentKey {
    static let defaultValue: String = ""
}

public extension EnvironmentValues {
    /// The live query text for whichever tab has `role: .search`.
    ///
    /// `AppShellView` wires `.searchable(text:)` up automatically for
    /// the search-role tab; read this from inside that tab's content to
    /// react to what the person typed, with no extra state of your own:
    ///
    /// ```swift
    /// struct SearchView: View {
    ///     @Environment(\.appShellSearchQuery) private var query
    ///
    ///     var body: some View {
    ///         List(results(matching: query)) { result in ... }
    ///     }
    /// }
    /// ```
    var appShellSearchQuery: String {
        get { self[AppShellSearchQueryKey.self] }
        set { self[AppShellSearchQueryKey.self] = newValue }
    }
}
