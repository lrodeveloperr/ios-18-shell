import Foundation

/// The four states almost every backend-driven screen goes through.
/// Pair with ``AppAsyncStateView`` to render each one consistently
/// without hand-rolling `if/else` in every screen.
public enum AppLoadState<Value> {
    case loading
    case loaded(Value)
    case empty
    case failed(Error)
}
