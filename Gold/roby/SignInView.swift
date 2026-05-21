//
//  SignInView.swift
//  Gold
//
//  Created by Raghad Alamoudi on 17/11/1447 AH.
//

//
//  SignInView.swift
//  Gold
//

internal import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @EnvironmentObject var auth: AuthenticationManager

    // لما تكون Sheet نحتاج dismiss
    @Environment(\.dismiss) private var dismiss
    @ScaledMetric(relativeTo: .largeTitle) private var logoIconSize: CGFloat = 68

    var body: some View {
        ZStack {
            Color("navy").ignoresSafeArea()

            VStack(spacing: 0) {

                // ─── زر إغلاق (لما تكون Sheet) ───
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.appCallout(.semibold))
                            .foregroundColor(Color("beige").opacity(0.7))
                            .padding(12)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                Spacer()

                // ─── Logo ───
                VStack(spacing: 14) {
                    Image(systemName: "circle.hexagonpath.fill")
                        .font(.system(size: logoIconSize))
                        .foregroundColor(Color("beige"))

                    Text("Gold")
                        .font(.custom("Georgia", size: 38, relativeTo: .largeTitle).weight(.bold))
                        .foregroundColor(Color("beige"))

                    Text("محفظتك الذهبية")
                        .font(.custom("Georgia", size: 17, relativeTo: .body))
                        .foregroundColor(Color("emarald"))
                }

                Spacer()

                // ─── نص توضيحي ───
                VStack(spacing: 8) {
                    Text("سجّل دخولك لحفظ بياناتك")
                        .font(.appBody(.semibold))
                        .foregroundColor(Color("beige"))

                    Text("محفظتك ومشترياتك محفوظة بأمان عبر iCloud\nوتزامن تلقائي على جميع أجهزتك")
                        .font(.appFootnote())
                        .foregroundColor(Color("emarald"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 32)

                Spacer().frame(height: 32)

                // ─── Sign In with Apple ───
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    auth.handleSignIn(result: result)
                    if auth.isSignedIn { dismiss() }
                }
                .signInWithAppleButtonStyle(.white)
                .frame(height: 54)
                .cornerRadius(12)
                .padding(.horizontal, 32)

                Spacer().frame(height: 48)
            }
        }
    }
}
