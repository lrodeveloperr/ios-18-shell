import TipKit

/// One-line setup for Apple's own TipKit onboarding tips.
///
/// Call once, as early as possible (typically your `App`'s `init`):
///
/// ```swift
/// @main
/// struct MyApp: App {
///     init() {
///         do { try AppShellTips.configure() }
///         catch { print("TipKit setup failed: \(error)") }
///     }
///     ...
/// }
/// ```
///
/// The call throws when TipKit cannot initialize. After that, define your own `Tip` types per screen and show them
/// with `TipView(myTip)` or `.popoverTip(myTip)` — TipKit (not this
/// package) owns display frequency, dismissal, and storage.
public enum AppShellTips {
    public static func configure() throws {
        try Tips.configure()
    }
}
