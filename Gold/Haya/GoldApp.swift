//
//  GoldApp.swift
//  Gold
//
//  Created by Haya almousa on 22/04/2026.
//

internal import SwiftUI


@main
struct GoldApp: App {
    @StateObject private var auth = AuthenticationManager.shared

    var body: some Scene {
        WindowGroup {
            if auth.isSignedIn {
                DashboardView()
                    .environmentObject(auth)
            }
        }
    }
}
