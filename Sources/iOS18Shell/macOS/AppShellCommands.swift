#if !os(watchOS)
import SwiftUI

/// Menu bar commands that jump between the shell's tabs, with ⌘1…⌘9
/// shortcuts — the standard macOS pattern for primary navigation (see
/// Mail, Music, and Apple's own multiplatform sample apps). Harmless to
/// include on other platforms; a hardware keyboard on iPad honors the
/// same shortcuts, and it's simply unused on watchOS/tvOS.
///
/// ```swift
/// var body: some Scene {
///     WindowGroup {
///         AppShellView(tabs: tabs, navigator: navigator)
///     }
///     .commands {
///         AppShellCommands(navigator: navigator, tabs: tabs)
///     }
/// }
/// ```
public struct AppShellCommands: Commands {
    private let navigator: AppShellNavigator?
    private let tabs: [AppTab]
    #if os(macOS)
    @FocusedObject private var focusedNavigator: AppShellNavigator?
    #endif

    public init(navigator: AppShellNavigator, tabs: [AppTab], groups: [AppTabGroup] = []) {
        self.navigator = navigator
        self.tabs = tabs + groups.flatMap(\.tabs)
    }

    #if os(macOS)
    /// Uses the active window's navigator when each window installs it
    /// with `.focusedSceneObject(navigator)`.
    public init(tabs: [AppTab], groups: [AppTabGroup] = []) {
        self.navigator = nil
        self.tabs = tabs + groups.flatMap(\.tabs)
    }
    #endif

    private var activeNavigator: AppShellNavigator? {
        #if os(macOS)
        navigator ?? focusedNavigator
        #else
        navigator
        #endif
    }

    public var body: some Commands {
        CommandMenu("Go") {
            ForEach(Array(tabs.enumerated()), id: \.element.id) { index, tab in
                if index < 9 {
                    Button(tab.title) {
                        activeNavigator?.navigate(to: tab.id)
                    }
                    .disabled(activeNavigator == nil)
                    .keyboardShortcut(KeyEquivalent(Character("\(index + 1)")), modifiers: .command)
                } else {
                    Button(tab.title) {
                        activeNavigator?.navigate(to: tab.id)
                    }
                    .disabled(activeNavigator == nil)
                }
            }
        }
    }
}
#endif
