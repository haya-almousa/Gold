//
//  GoldApp.swift
//  Gold
//
//  Created by Haya almousa on 22/04/2026.
//

import SwiftData
internal import SwiftUI

@main
struct GoldApp: App {
    @StateObject private var auth = AuthenticationManager.shared
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    @State private var showSplash = true
    @State private var showOnboarding = false
    @State private var showSignIn = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashScreenView {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            showSplash = false
                            if hasSeenOnboarding {
                                // skip straight to app (auth decides sign-in)

                            } else {
                                showOnboarding = true
                            }
                        }
                    }
                    .transition(.opacity)
                } else if showOnboarding {
                    OnboardingView {
                        hasSeenOnboarding = true
                        withAnimation(.easeInOut(duration: 0.4)) {
                            showOnboarding = false
                            showSignIn = true
                        }
                    }
                    .transition(.opacity)
                } else if showSignIn && !auth.isSignedIn {
                    SignInView()
                        .environmentObject(auth)
                        .transition(.opacity)
                        .onChange(of: auth.isSignedIn) { signedIn in
                            if signedIn {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showSignIn = false
                                }
                            }
                        }
                } else {
                    MainTabView()
                        .environmentObject(auth)
                        .transition(.opacity)
                }
            }
            .modelContainer(DataStore.shared)
        }
    }
}
