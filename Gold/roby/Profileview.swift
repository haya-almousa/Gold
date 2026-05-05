//
//  Untitled.swift
//  Gold
//
//  Created by Raghad Alamoudi on 18/11/1447 AH.
//


internal import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var auth: AuthenticationManager
    @State private var showSignIn = false

    var body: some View {
        ZStack {
            Color("navy").ignoresSafeArea()

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
    }

    // ─── حالة مسجل الدخول ───
    private var signedInView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {

                Text("Profile")
                    .font(.custom("Georgia", size: 28).weight(.bold))
                    .foregroundColor(Color("beige"))
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 20)

                // ─── معلومات المستخدم ───
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color("beige").opacity(0.15))
                            .frame(width: 52, height: 52)
                        Image(systemName: "person.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Color("beige"))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(auth.userName.isEmpty ? "مستخدم Gold" : auth.userName)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(Color("beige"))

                        if !auth.userEmail.isEmpty {
                            Text(auth.userEmail)
                                .font(.system(size: 13, weight: .regular, design: .rounded))
                                .foregroundColor(Color("emarald"))
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)

                // ─── القائمة ───
                VStack(spacing: 0) {
                    profileRow(icon: "bell", title: "تنبيهات الأسعار")
                    Divider().background(Color("beige").opacity(0.1))
                    profileRow(icon: "gearshape", title: "التفضيلات")
                    Divider().background(Color("beige").opacity(0.1))
                    profileRow(icon: "info.circle", title: "عن التطبيق")
                }
                .background(Color.white.opacity(0.05))
                .cornerRadius(16)
                .padding(.horizontal, 20)

                Spacer().frame(height: 32)

                // ─── تسجيل الخروج ───
                Button {
                    auth.signOut()
                } label: {
                    Text("تسجيل الخروج")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.red.opacity(0.85))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.red.opacity(0.08))
                        .cornerRadius(14)
                }
                .padding(.horizontal, 20)

                Spacer().frame(height: 40)
            }
        }
    }

    // ─── حالة الزائر (غير مسجل) ───
    private var guestView: some View {
        VStack(spacing: 0) {
            Text("Profile")
                .font(.custom("Georgia", size: 28).weight(.bold))
                .foregroundColor(Color("beige"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 24)

            Spacer()

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color("beige").opacity(0.1))
                        .frame(width: 80, height: 80)
                    Image(systemName: "person.fill")
                        .font(.system(size: 34))
                        .foregroundColor(Color("beige").opacity(0.6))
                }

                VStack(spacing: 8) {
                    Text("Sign in to sync")
                        .font(.custom("Georgia", size: 22).weight(.bold))
                        .foregroundColor(Color("beige"))

                    Text("Access your portfolio, history, and preferences\nfrom any device.")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(Color("emarald"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
            }

            Spacer().frame(height: 40)

            // ─── أزرار ───
            VStack(spacing: 12) {
                Button {
                    showSignIn = true
                } label: {
                    Text("Sign In")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(Color("navy"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color("beige"))
                        .cornerRadius(14)
                }

                Button {
                    showSignIn = true
                } label: {
                    Text("Create account")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Color("beige"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white.opacity(0.07))
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color("beige").opacity(0.25), lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, 24)

            Spacer().frame(height: 60)
        }
    }

    // ─── صف في القائمة ───
    private func profileRow(icon: String, title: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color("beige").opacity(0.12))
                    .frame(width: 34, height: 34)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color("beige"))
            }

            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(Color("beige"))

            Spacer()

            Image(systemName: "arrow.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color("emarald"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}
