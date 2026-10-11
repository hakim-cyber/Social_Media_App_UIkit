//
//  AppleSignInHelper.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/25/25.
//

import Foundation
import CryptoKit
import AuthenticationServices

@MainActor
protocol AppleSignInFlowPerforming {
    func start(
        presentationContextProvider: ASAuthorizationControllerPresentationContextProviding
    ) async throws -> (idToken: String, nonce: String)
}

@MainActor
final class AppleSignInHelper: NSObject, AppleSignInFlowPerforming {
    private var currentDelegate: AppleSignInDelegateWrapper? // strong reference

    func start(
        presentationContextProvider: ASAuthorizationControllerPresentationContextProviding
    ) async throws -> (idToken: String, nonce: String) {
        let nonce = randomNonceString()

        return try await withCheckedThrowingContinuation { continuation in
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = sha256(nonce)

            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            let delegateWrapper = AppleSignInDelegateWrapper(completion: { [weak self] result in
                self?.currentDelegate = nil
                continuation.resume(with: result)
            }, nonce: nonce)

            currentDelegate = delegateWrapper
            authorizationController.delegate = delegateWrapper
            authorizationController.presentationContextProvider = presentationContextProvider
            authorizationController.performRequests()
        }
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }

        let charset: [Character] =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }

        return String(nonce)
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }
}

// MARK: - Delegate Wrapper
private class AppleSignInDelegateWrapper: NSObject, ASAuthorizationControllerDelegate {
    let completion: (Result<(idToken: String, nonce: String), Error>) -> Void
    let nonce: String
    
    init(completion: @escaping (Result<(idToken: String, nonce: String), Error>) -> Void, nonce: String) {
        self.completion = completion
        self.nonce = nonce
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let identityToken = credential.identityToken,
              let idTokenString = String(data: identityToken, encoding: .utf8) else {
            completion(.failure(NSError(domain: "AppleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid ID Token"])))
            return
        }
        completion(.success((idToken: idTokenString, nonce: nonce)))
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        completion(.failure(error))
    }
}
