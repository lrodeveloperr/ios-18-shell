import SwiftData

/// Builds the `ModelContainer` for your `@Model` types using Apple's own
/// SwiftData framework — no third-party persistence library needed.
///
/// ```swift
/// var body: some Scene {
///     WindowGroup {
///         AppShellView(tabs: tabs)
///     }
///     .modelContainer(AppShellModelContainer.make(for: [Album.self, Track.self]))
/// }
/// ```
@MainActor
public enum AppShellModelContainer {
    /// - Parameters:
    ///   - models: Every `@Model` type the container should manage.
    ///   - inMemory: Pass `true` for previews/tests so nothing is
    ///     written to disk. Defaults to `false` (persisted on disk).
    public static func make(for models: [any PersistentModel.Type], inMemory: Bool = false) -> ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: inMemory)
        do {
            return try ModelContainer(for: Schema(models), configurations: [configuration])
        } catch {
            fatalError("Failed to create SwiftData ModelContainer: \(error)")
        }
    }
}
