//
//  SignInWithApple.swift
//  Fitplay
//
//  Created by Samuel Vulakh on 5/9/23.
//

import AuthenticationServices
import Foundation
import CryptoKit
import Firebase
import SwiftUI

class SignInWithApple: NSObject, ObservableObject, ASAuthorizationControllerPresentationContextProviding {

    private var onSignedIn: ((_ email: String, _ name: String) -> Void)?

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor { UIApplication.shared.windows.first! }
    
    @AppStorage("status") var IsLoggedIn = false
    
    // Unhashed nonce.
    fileprivate var currentNonce: String?
    
    @available(iOS 13, *)
    func startSignInWithAppleFlow(onSignedIn: @escaping (String, String) -> Void) {
        self.onSignedIn = onSignedIn
        
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}
@available(iOS 13.0, *)
extension SignInWithApple: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let callback = self.onSignedIn, let first = appleIDCredential.fullName?.givenName, let last = appleIDCredential.fullName?.familyName {
                    self.IsLoggedIn = true
                    callback(appleIDCredential.email ?? "", "\(first) \(last)")
                }
            }
            
//            Auth.auth().currentUser?.link(with: credential) { (authResult, error) in
//                if let error = error, (error as NSError).code == AuthErrorCode.credentialAlreadyInUse.rawValue {
//                    print("The user you're trying to sign in with has alredy been linked")
//                    if let updatedCredential = (error as NSError).userInfo[AuthErrorUserInfoUpdatedCredentialKey] as? OAuthCredential {
//                        print("Signing in using the updated credentials")
//
//                    }
//                } else {
//                    if let callback = self.onSignedIn {
//                        self.IsLoggedIn = true
//                        callback()
//                    }
//                }
//            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
    
}


// Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
private func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: [Character] =
    Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length
    
    while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if errorCode != errSecSuccess {
                fatalError(
                    "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                )
            }
            return random
        }
        
        randoms.forEach { random in
            if remainingLength == 0 {
                return
            }
            
            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }
    }
    
    return result
}
