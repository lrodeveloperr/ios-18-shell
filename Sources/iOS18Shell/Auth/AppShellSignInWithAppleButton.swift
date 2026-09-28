#if os(iOS) || os(macOS) || os(visionOS)
import AuthenticationServices
import SwiftUI

/// A ready-to-use "Sign in with Apple" button using Apple's own
/// `AuthenticationServices` framework — no third-party auth SDK needed.
///
/// Only available on iOS, macOS, and visionOS, matching
/// `AuthenticationServices`' own `SignInWithAppleButton` availability
/// (there is no watchOS/tvOS SwiftUI button for this).
///
/// ```swift
/// AppShellSignInWithAppleButton { result in
///     switch result {
///     case .success(let authorization):
///         // Send authorization.credential to your backend.
///     case .failure(let error):
///         // Show the error.
///     }
/// }
/// ```
public struct AppShellSignInWithAppleButton: View {
    @Environment(\.colorScheme) private var colorScheme
    private let label: SignInWithAppleButton.Label
    private let requestedScopes: [ASAuthorization.Scope]
    private let onCompletion: (Result<ASAuthorization, Error>) -> Void

    public init(
        label: SignInWithAppleButton.Label = .signIn,
        requestedScopes: [ASAuthorization.Scope] = [],
        onCompletion: @escaping (Result<ASAuthorization, Error>) -> Void
    ) {
        self.label = label
        self.requestedScopes = requestedScopes
        self.onCompletion = onCompletion
    }

    public var body: some View {
        SignInWithAppleButton(label) { request in
            request.requestedScopes = requestedScopes
        } onCompletion: { result in
            onCompletion(result)
        }
        .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
        .frame(height: 44)
    }
}
#endif
