import SwiftUI

/// One pane of a multi-pane Settings window (General, Account, Advanced…).
public struct AppShellSettingsPane: Identifiable {
    public let id: String
    public let title: String
    public let systemImage: String
    public let content: () -> AnyView

    public init<Content: View>(
        id: String,
        title: String,
        systemImage: String,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.id = id
        self.title = title
        self.systemImage = systemImage
        self.content = { AnyView(content()) }
    }
}

/// A standard multi-pane Settings layout, in the same `TabView` +
/// `.tabItem` style macOS's own System Settings and most first-party
/// Apple apps use. Plug straight into a `Settings` scene:
///
/// ```swift
/// var body: some Scene {
///     WindowGroup { AppShellView(tabs: tabs) }
///     #if os(macOS)
///     Settings {
///         AppShellSettingsView(panes: [
///             AppShellSettingsPane(id: "general", title: "General", systemImage: "gearshape") {
///                 GeneralSettingsView()
///             },
///             AppShellSettingsPane(id: "account", title: "Account", systemImage: "person.crop.circle") {
///                 AccountSettingsView()
///             }
///         ])
///     }
///     #endif
/// }
/// ```
public struct AppShellSettingsView: View {
    private let panes: [AppShellSettingsPane]

    public init(panes: [AppShellSettingsPane]) {
        self.panes = panes
    }

    public var body: some View {
        TabView {
            ForEach(panes) { pane in
                pane.content()
                    .tabItem {
                        Label(pane.title, systemImage: pane.systemImage)
                    }
                    .tag(pane.id)
            }
        }
        .frame(width: 500, height: 300)
    }
}
