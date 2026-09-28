import SwiftData

/// Builds the `ModelContainer` for your `@Model` types using Apple's own
/// SwiftData framework — no third-party persistence library needed.
///
/// ```swift
/// var body: some Scene {
///     WindowGroup {
///         if let container = try? AppShellModelContainer.make(for: [Album.self, Track.self]) {
///             AppShellView(tabs: tabs).modelContainer(container)
///         } else {
///             ContentUnavailableView("Data Unavailable", systemImage: "externaldrive.badge.exclamationmark")
///         }
///     }
/// }
/// ```
@MainActor
public enum AppShellModelContainer {
    /// - Parameters:
    ///   - models: Every `@Model` type the container should manage.
    ///   - inMemory: Pass `true` for previews/tests so nothing is
    ///     written to disk. Defaults to `false` (persisted on disk).
    public static func make(for models: [any PersistentModel.Type], inMemory: Bool = false) throws -> ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: inMemory)
        return try ModelContainer(for: Schema(models), configurations: [configuration])
    }
}
