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
            Color("background").ignoresSafeArea()

            VStack {
                Spacer().frame(height: 150) // مسافة من الأعلى

                // شعار تبرة
                Image("Image1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140, height: 140)
                    .padding(.bottom, 40)

                // زر تسجيل الدخول
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

                // فاصل "أو"
                HStack {
                    Rectangle().frame(height: 1).foregroundColor(Color("Light grey").opacity(0.3))
                    Text("أو").font(.caption).foregroundColor(Color("Grey"))
                    Rectangle().frame(height: 1).foregroundColor(Color("Light grey").opacity(0.3))
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 10)

                // رابط الدخول بدون حساب
                Button {
                    auth.skipSignIn()
                } label: {
                    Text("مجرد تصفح الآن - الدخول بدون حساب")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color("maincolor"))
                }

                Spacer()

                // نص الخصوصية
                Text("باستمرارك، أنت توافق على الشروط وسياسة الخصوصية الخاصة بنا")
                    .font(.footnote)
                    .foregroundColor(Color("Light grey"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 30)
            }

        }

    }
}
#Preview {
    SignInView()
}
