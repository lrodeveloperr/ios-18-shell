import SwiftUI

/// Metadata and content for a destination declared with `appShellTab`.
///
/// `AppTab` only owns navigation chrome — the id, title, icon, and an
/// optional role (such as `.search`). The `content` closure is where your
/// own backend-driven view goes, so existing screens can be wrapped
/// without modification.
public struct AppTab: Identifiable {
    public let id: String
    public let title: String
    public let systemImage: String
    public let role: AppTabRole
    public let content: () -> AnyView

    public init<Content: View>(
        id: String,
        title: String,
        systemImage: String,
        role: AppTabRole = .none,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.id = id
        self.title = title
        self.systemImage = systemImage
        self.role = role
        self.content = { AnyView(content()) }
    }
}

/// A labeled group of tabs.
///
/// Metadata for related destinations. Declare a corresponding native
/// `TabSection` in `AppShellView`'s content builder to show a sidebar
/// section on platforms that support one.
public struct AppTabGroup: Identifiable {
    public let id: String
    public let title: String
    public let tabs: [AppTab]

    /// `TabSection` controls native presentation independently of this
    /// metadata. Section destinations are hidden from the compact tab
    /// bar; provide a visible route in your compact layout.
    public init(id: String, title: String, tabs: [AppTab]) {
        self.id = id
        self.title = title
        self.tabs = tabs
    }
}

/// Mirrors `SwiftUI.TabRole` so call sites don't need to import
/// platform-conditional availability just to build an ``AppTab``.
public enum AppTabRole: Equatable {
    case none
    case search

    var native: TabRole? {
        switch self {
        case .none: return nil
        case .search: return .search
        }
    }
}
