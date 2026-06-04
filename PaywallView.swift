//
//  PaywallView.swift
//  Gold
//

import StoreKit
internal import SwiftUI

struct PaywallView: View {

    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var subscription = SubscriptionManager.shared

    var body: some View {
        ZStack {
            Color("background").ignoresSafeArea()

            VStack(spacing: 0) {
                closeButton
                subscriptionContent
            }
        }
    }

    // MARK: - Close Button

    private var closeButton: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.appBody(.semibold))
                    .foregroundColor(Color("Grey"))
                    .frame(width: 36, height: 36)
                    .background(Color("Lightest blue"))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }

    // MARK: - Subscription Content

    private var subscriptionContent: some View {
        SubscriptionStoreView(groupID: SubscriptionManager.groupID) {
            VStack(spacing: 16) {
                Image("RH")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)

                Text("تبرة بلس")
                    .font(.appTitle(.bold))
                    .foregroundColor(Color("maincolor"))

                Text("فتح جميع مميزات التطبيق")
                    .font(.appSubheadline())
                    .foregroundColor(Color("Grey"))

                VStack(alignment: .trailing, spacing: 12) {
                    featureRow(icon: "bookmark.fill", text: "مقارنة غير محدودة لقطع الذهب")
                    featureRow(icon: "bell.fill", text: "تنبيهات أسعار الذهب")
                    featureRow(icon: "chart.line.uptrend.xyaxis", text: "تقارير وإحصائيات متقدمة")
                    featureRow(icon: "moon.fill", text: "حاسبة زكاة متقدمة")
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .padding(.top, 20)
        }
        .subscriptionStoreButtonLabel(.multiline)
        .storeButton(.visible, for: .restorePurchases)
        .tint(Color("maincolor"))
    }

    // MARK: - Feature Row

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Text(text)
                .font(.appCallout(.medium))
                .foregroundColor(Color("Dark green"))
                .frame(maxWidth: .infinity, alignment: .trailing)

            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color("maincolor").opacity(0.1))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.appFootnote(.semibold))
                    .foregroundColor(Color("maincolor"))
            }
        }
    }
}

#Preview {
    PaywallView()
}
