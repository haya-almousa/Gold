//
//  Untitled.swift
//  Gold
//
//  Created by Raghad Alamoudi on 18/11/1447 AH.
//

internal import SwiftUI

struct ProfileView: View {
    @ObservedObject private var auth: AuthenticationManager = .shared
    @ObservedObject private var subscription = SubscriptionManager.shared
    @State private var showSignIn = false
    @State private var showPaywall = false

    var body: some View {
        ZStack {
            Color("background").ignoresSafeArea()

            if auth.isSignedIn {
                signedInView
            } else {
                guestView
            }
        }
        .sheet(isPresented: $showSignIn) {
            SignInView()
                .environmentObject(auth)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    // ─── حالة مسجل الدخول ───
    private var signedInView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .trailing, spacing: 0) {

                Text("الحساب")
                    .font(.appTitle2(.bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 20)

                // ─── معلومات المستخدم ───
                HStack(spacing: 14) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(auth.userName.isEmpty ? "مستخدم Gold" : auth.userName)
                            .font(.appBody(.bold))
                            .foregroundColor(.black)

                        if !auth.userEmail.isEmpty {
                            Text(auth.userEmail)
                                .font(.appFootnote(.regular))
                                .foregroundColor(Color("Grey"))
                        }
                    }

                    ZStack {
                        Circle()
                            .fill(Color("maincolor"))
                            .frame(width: 52, height: 52)
                        Image(systemName: "person.fill")
                            .font(.appTitle2())
                            .foregroundColor(Color("background"))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal, 20)
                .padding(.bottom, 24)

                // ─── الاشتراك ───
                Button { showPaywall = true } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "chevron.left")
                            .font(.appFootnote(.semibold))
                            .foregroundColor(Color("Grey"))

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text(subscription.isPremium ? "تبرة بلس" : "اشترك في تبرة بلس")
                                .font(.appCallout(.bold))
                                .foregroundColor(Color("maincolor"))
                            Text(subscription.isPremium ? "اشتراكك فعّال" : "فتح جميع المميزات")
                                .font(.appCaption())
                                .foregroundColor(Color("Grey"))
                        }

                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color("Gold").opacity(0.2))
                                .frame(width: 34, height: 34)
                            Image(systemName: "crown.fill")
                                .font(.appSubheadline(.medium))
                                .foregroundColor(Color("Dark gold"))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
                .buttonStyle(.plain)
                .background(Color("Lightest gold"))
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color("Gold"), lineWidth: 0.3))
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

                // ─── القائمة ───
                VStack(spacing: 0) {
                    profileRow(icon: "bell", title: "تنبيهات الأسعار")
                    Divider()
                    profileRow(icon: "gearshape", title: "التفضيلات")
                    Divider()
                    profileRow(icon: "info.circle", title: "عن التطبيق")
                }
                .background(Color("Lightest blue"))
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.maincolor), lineWidth: 0.1))
                .padding(.horizontal, 20)

                Spacer().frame(height: 32)

                // ─── تسجيل الخروج ───
                Button {
                    auth.signOut()
                } label: {
                    Text("تسجيل الخروج")
                        .font(.appSubheadline(.semibold))
                        .foregroundColor(.red.opacity(0.85))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.red.opacity(0.08))
                        .cornerRadius(14)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.red.opacity(0.2), lineWidth: 0.5))
                }
                .padding(.horizontal, 20)

                Spacer().frame(height: 100)
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }

    // ─── حالة الزائر (غير مسجل) ───
    private var guestView: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                Text("الحساب")
                    .font(.appTitle2(.bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal, 20)
                    .padding(.top, 24)

                Spacer()

                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Color("maincolor").opacity(0.1))
                            .frame(width: 80, height: 80)
                        Image(systemName: "person.fill")
                            .font(.appTitle())
                            .foregroundColor(Color("maincolor").opacity(0.6))
                    }

                    VStack(spacing: 8) {
                        Text("سجّل دخولك")
                            .font(.appTitle2(.bold))
                            .foregroundColor(.black)

                        Text("تزامن محفظتك وتاريخك وتفضيلاتك\nعلى جميع أجهزتك.")
                            .font(.appSubheadline(.regular))
                            .foregroundColor(Color("Grey"))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                }

                Spacer()

                VStack(spacing: 12) {
                    Button {
                        showSignIn = true
                    } label: {
                        Text("تسجيل الدخول")
                            .font(.appCallout(.bold))
                            .foregroundColor(Color("background"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color("maincolor"))
                            .cornerRadius(14)
                    }

                    Button {
                        showSignIn = true
                    } label: {
                        Text("إنشاء حساب")
                            .font(.appCallout(.semibold))
                            .foregroundColor(Color("maincolor"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color("Lightest blue"))
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color(.maincolor), lineWidth: 0.5)
                            )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 60)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .environment(\.layoutDirection, .rightToLeft)
        }
    }

    // ─── صف في القائمة ───
    private func profileRow(icon: String, title: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: "chevron.left")
                .font(.appFootnote(.semibold))
                .foregroundColor(Color("Grey"))

            Spacer()

            Text(title)
                .font(.appCallout(.medium))
                .foregroundColor(.black)

            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color("maincolor").opacity(0.1))
                    .frame(width: 34, height: 34)
                Image(systemName: icon)
                    .font(.appSubheadline(.medium))
                    .foregroundColor(Color("maincolor"))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    ProfileView()
}
