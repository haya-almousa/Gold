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

    @Environment(\.dismiss) private var dismiss
    @ScaledMetric(relativeTo: .largeTitle) private var logoIconSize: CGFloat = 68
    @State private var showPrivacyPolicy = false

    var body: some View {
        ZStack {
            Color("background").ignoresSafeArea()

            VStack {
                Spacer().frame(height: 150)

                Image("RH")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140, height: 140)
                    .padding(.bottom, 40)

                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    auth.handleSignIn(result: result)
                    if auth.isSignedIn { dismiss() }
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 55)
                .cornerRadius(12)
                .padding(.horizontal, 32)
                .padding(.bottom, 20)

                HStack {
                    Rectangle().frame(height: 1).foregroundColor(Color("Light grey").opacity(0.3))
                    Text("أو").font(.caption).foregroundColor(Color("Grey"))
                    Rectangle().frame(height: 1).foregroundColor(Color("Light grey").opacity(0.3))
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 10)

                Button {
                    auth.skipSignIn()
                } label: {
                    Text("مجرد تصفح الآن - الدخول بدون حساب")
                        .font(.appSubheadline(.semibold))
                        .foregroundColor(Color("maincolor"))
                }

                Spacer()

                VStack(spacing: 6) {
                    Text("باستمرارك، أنت توافق على الشروط وسياسة الخصوصية")
                        .font(.appCaption())
                        .foregroundColor(Color("Light grey"))

                    Button { showPrivacyPolicy = true } label: {
                        Text("اقرأ سياسة الخصوصية قبل المتابعة")
                            .font(.appCaption(.medium))
                            .foregroundColor(Color("maincolor"))
                            .underline()
                    }
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 30)
            }
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyView()
        }
    }
}
#Preview {
    SignInView()
}
