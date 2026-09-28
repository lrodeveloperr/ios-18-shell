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
    private let navigator: AppShellNavigator
    private let tabs: [AppTab]

    public init(navigator: AppShellNavigator, tabs: [AppTab]) {
        self.navigator = navigator
        self.tabs = tabs
    }

    public var body: some Commands {
        CommandMenu("Go") {
            ForEach(Array(tabs.enumerated()), id: \.element.id) { index, tab in
                if index < 9 {
                    Button(tab.title) {
                        navigator.selection = tab.id
                    }
                    .keyboardShortcut(KeyEquivalent(Character("\(index + 1)")), modifiers: .command)
                } else {
                    Button(tab.title) {
                        navigator.selection = tab.id
                    }
                }
            }
        }
    }
}
