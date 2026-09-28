import SwiftUI

/// Renders an ``AppLoadState`` using Apple's own `ContentUnavailableView`
/// for the empty and error cases, so every screen backed by your API
/// gets a consistent loading spinner, empty state, and error state for
/// free.
///
/// ```swift
/// struct LibraryView: View {
///     @State private var state: AppLoadState<[Album]> = .loading
///
///     var body: some View {
///         AppAsyncStateView(state, emptyTitle: "No Albums", emptySystemImage: "square.stack", retry: load) { albums in
///             List(albums) { album in Text(album.title) }
///         }
///         .task { await load() }
///     }
///
///     private func load() async {
///         state = .loading
///         do {
///             let albums = try await api.fetchAlbums()
///             state = albums.isEmpty ? .empty : .loaded(albums)
///         } catch {
///             state = .failed(error)
///         }
///     }
/// }
/// ```
public struct AppAsyncStateView<Value, Content: View>: View {
    private let state: AppLoadState<Value>
    private let emptyTitle: String
    private let emptySystemImage: String
    private let emptyDescription: String?
    private let retry: (() -> Void)?
    private let content: (Value) -> Content

    public init(
        _ state: AppLoadState<Value>,
        emptyTitle: String = "No Content",
        emptySystemImage: String = "tray",
        emptyDescription: String? = nil,
        retry: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Value) -> Content
    ) {
        self.state = state
        self.emptyTitle = emptyTitle
        self.emptySystemImage = emptySystemImage
        self.emptyDescription = emptyDescription
        self.retry = retry
        self.content = content
    }

    public var body: some View {
        switch state {
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .loaded(let value):
            content(value)

        case .empty:
            if let emptyDescription {
                ContentUnavailableView(emptyTitle, systemImage: emptySystemImage, description: Text(emptyDescription))
            } else {
                ContentUnavailableView(emptyTitle, systemImage: emptySystemImage)
            }

        case .failed(let error):
            ContentUnavailableView {
                Label("Something Went Wrong", systemImage: "exclamationmark.triangle")
            } description: {
                Text(error.localizedDescription)
            } actions: {
                if let retry {
                    Button("Try Again", action: retry)
                }
            }
        }
    }
}
