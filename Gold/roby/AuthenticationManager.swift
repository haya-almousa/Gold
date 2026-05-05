//
//  AuthenticationManager.swift
//  Gold
//
//  Created by Raghad Alamoudi on 17/11/1447 AH.
//


import AuthenticationServices
import CloudKit
import Combine

@MainActor
final class AuthenticationManager: ObservableObject {

    @Published var isSignedIn: Bool = false
    @Published var userID: String    = ""
    @Published var userName: String  = ""
    @Published var userEmail: String = ""

    static let shared = AuthenticationManager()

    private init() {
        checkExistingSession()
    }

    // ─── تحقق إذا المستخدم سجل دخول قبل ───
    func checkExistingSession() {
        guard let savedID = UserDefaults.standard.string(forKey: "userID") else { return }

        let provider = ASAuthorizationAppleIDProvider()
        provider.getCredentialState(forUserID: savedID) { [weak self] state, _ in
            Task { @MainActor in
                guard let self else { return }
                self.isSignedIn = (state == .authorized)
                if self.isSignedIn {
                    self.userID    = savedID
                    self.userName  = UserDefaults.standard.string(forKey: "userName")  ?? ""
                    self.userEmail = UserDefaults.standard.string(forKey: "userEmail") ?? ""
                }
            }
        }
    }

    // ─── بعد نجاح Sign In with Apple ───
    func handleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            guard let credential = auth.credential as? ASAuthorizationAppleIDCredential
            else { return }

            let id    = credential.user
            let name  = [credential.fullName?.givenName,
                         credential.fullName?.familyName]
                        .compactMap { $0 }.joined(separator: " ")
            let email = credential.email ?? ""

            // حفظ البيانات محلياً
            UserDefaults.standard.set(id,    forKey: "userID")
            UserDefaults.standard.set(name,  forKey: "userName")
            UserDefaults.standard.set(email, forKey: "userEmail")

            self.userID    = id
            self.userName  = name
            self.userEmail = email
            self.isSignedIn = true

        case .failure(let error):
            print("Sign in failed: \(error.localizedDescription)")
        }
    }

    // ─── تسجيل الخروج ───
    func signOut() {
        UserDefaults.standard.removeObject(forKey: "userID")
        UserDefaults.standard.removeObject(forKey: "userName")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        isSignedIn = false
        userID     = ""
        userName   = ""
        userEmail  = ""
    }

    // ─── يُستدعى لما يحاول يستخدم خدمة تحتاج حساب ───
    // أرجع true إذا المستخدم مسجل، false إذا محتاج يسجل
    var requiresSignIn: Bool {
        !isSignedIn
    }
}
