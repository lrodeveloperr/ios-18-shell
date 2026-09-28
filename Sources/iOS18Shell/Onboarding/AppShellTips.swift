import TipKit

/// One-line setup for Apple's own TipKit onboarding tips.
///
/// Call once, as early as possible (typically your `App`'s `init`):
///
/// ```swift
/// @main
/// struct MyApp: App {
///     init() {
///         AppShellTips.configure()
///     }
///     ...
/// }
/// ```
///
/// After that, define your own `Tip` types per screen and show them
/// with `TipView(myTip)` or `.popoverTip(myTip)` — TipKit (not this
/// package) owns display frequency, dismissal, and storage.
public enum AppShellTips {
    public static func configure() {
        try? Tips.configure([
            .displayFrequency(.immediate),
            .datastoreLocation(.applicationDefault)
        ])
    }
}
