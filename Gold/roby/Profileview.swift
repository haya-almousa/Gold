internal import SwiftUI

struct ProfileView: View {
    @ObservedObject private var auth: AuthenticationManager = .shared
    @ObservedObject private var subscription = SubscriptionManager.shared
    @State private var showSignIn = false
    @State private var showPaywall = false
    @State private var showPrivacyPolicy = false

    var body: some View {
        ZStack {
            Color("background").ignoresSafeArea()

            if auth.isSignedIn {
                signedInView
            } else {
                guestView
            }
        }
        // 🌟 نضع الفرض هنا مرة واحدة ليمشي على كامل الصفحة بجميع حالاتها بشكل نظامي
        .environment(\.layoutDirection, .rightToLeft)
        .sheet(isPresented: $showSignIn) {
            SignInView()
                .environmentObject(auth)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyView()
        }
    }

    // ─── حالة مسجل الدخول ───
    private var signedInView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {

                Text("الحساب")
                    .font(.appTitle2(.bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 20)

                // معلومات المستخدم
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color("maincolor"))
                            .frame(width: 52, height: 52)
                        Image(systemName: "person.fill")
                            .font(.appTitle2())
                            .foregroundColor(Color("background"))
                    }

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
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)

                // بطاقة الاشتراك
                Button { showPaywall = true } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color("Gold").opacity(0.2))
                                .frame(width: 34, height: 34)
                            Image(systemName: "crown.fill")
                                .font(.appSubheadline(.medium))
                                .foregroundColor(Color("Dark gold"))
                        }

                        VStack(alignment: .trailing, spacing: 4) {
                            Text(subscription.isPremium ? "تبرة بلس" : "اشترك في تبرة بلس")
                                .font(.appCallout(.bold))
                                .foregroundColor(Color("maincolor"))
                            Text(subscription.isPremium ? "اشتراكك فعّال" : "فتح جميع المميزات")
                                .font(.appCaption())
                                .foregroundColor(Color("Grey"))
                        }

                        Spacer()

                        Image(systemName: "chevron.left")
                            .font(.appFootnote(.semibold))
                            .foregroundColor(Color("Grey"))
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

                // القائمة
                VStack(spacing: 0) {
                    Button { showPrivacyPolicy = true } label: {
                        profileRow(icon: "lock.shield", title: "سياسة الخصوصية")
                    }
                    .buttonStyle(.plain)
                    Divider()
                    profileRow(icon: "info.circle", title: "عن التطبيق")
                }
                .background(Color("Lightest blue"))
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.maincolor), lineWidth: 0.1))
                .padding(.horizontal, 20)

                Spacer().frame(height: 32)

                // تسجيل الخروج
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
    }

    // ─── حالة الزائر (غير مسجل) ───
        private var guestView: some View {
            GeometryReader { geo in
                VStack(spacing: 0) {
                    
                    // كلمة الحساب ثابتة في اليمين فوق
                    Text("الحساب")
                        .font(.appTitle2(.bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 24)

                    Spacer()

                    // الحاوية الوسطية (الأيقونة والكلام في منتصف الشاشة تماماً)
                    VStack(alignment: .center, spacing: 20) {
                        
                        // الأيقونة في المنتصف
                        ZStack {
                            Circle()
                                .fill(Color("maincolor").opacity(0.1))
                                .frame(width: 80, height: 80)
                            Image(systemName: "person.fill")
                                .font(.appTitle())
                                .foregroundColor(Color("maincolor").opacity(0.6))
                        }

                        // النصوص مجمعة ومسنترة ككتلة كاملة، ولكن الأسطر تبدأ من اليمين
                        VStack(alignment: .center, spacing: 8) {
                            Text("سجّل دخولك")
                                .font(.appTitle2(.bold))
                                .foregroundColor(.black)

                            Text("سجّل دخولك لحفظ بيانات تجوريك،\nوحماية عملياتك وتفضيلاتك من الضياع")
                                .font(.appSubheadline(.regular))
                                .foregroundColor(Color("Grey"))
                                .multilineTextAlignment(.center) // لجعل النص متناسق في المنتصف، أو غيره لـ .trailing إذا تفضل الأسطر تبدأ يمين
                                .lineSpacing(4)
                        }
                        .padding(.horizontal, 32) // إعطاء مساحة مريحة على الجوانب للنص
                    }
                    .frame(maxWidth: .infinity) // تضمن أن الحاوية تأخذ العرض كامل لتتوسط تلقائياً

                    Spacer()

                    // الأزرار السفلية
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
                    .padding(.bottom, 20)

                    Button { showPrivacyPolicy = true } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "lock.shield")
                                .font(.appCaption(.medium))
                            Text("سياسة الخصوصية")
                                .font(.appCaption(.medium))
                                .underline()
                        }
                        .foregroundColor(Color("Grey"))
                    }
                    .padding(.bottom, 40)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
    // ─── صف في القائمة ───
    private func profileRow(icon: String, title: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color("maincolor").opacity(0.1))
                    .frame(width: 34, height: 34)
                Image(systemName: icon)
                    .font(.appSubheadline(.medium))
                    .foregroundColor(Color("maincolor"))
            }

            Text(title)
                .font(.appCallout(.medium))
                .foregroundColor(.black)

            Spacer()

            Image(systemName: "chevron.left")
                .font(.appFootnote(.semibold))
                .foregroundColor(Color("Grey"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}
#Preview {
    ProfileView()
}
