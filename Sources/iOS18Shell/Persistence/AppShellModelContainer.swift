import SwiftData

/// Builds the `ModelContainer` for your `@Model` types using Apple's own
/// SwiftData framework — no third-party persistence library needed.
///
/// See `Examples/ShellExampleApp.swift` for a root view that handles
/// container creation failure without replacing the user's stored data.
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
