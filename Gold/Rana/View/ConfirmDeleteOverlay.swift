//
//  ConfirmDeleteOverlay.swift
//  Gold
//
//  Created by Rana Alqubaly on 25/11/1447 AH.
//


internal import SwiftUI

struct ConfirmDeleteOverlay: View {
    let title:     String
    let message:   String
    let onConfirm: () -> Void
    let onCancel:  () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture(perform: onCancel)

            VStack(spacing: 20) {
                Text(title)
                    .font(.appTitle2(.bold))
                    .foregroundColor(Color("maincolor"))

                Text(message)
                    .font(.appBody())
                    .foregroundColor(Color(.navy))
                    .multilineTextAlignment(.center)

                HStack {
                    
                    Spacer()

                    
                    Button(action: onCancel) {
                        Text("الغاء")
                            .font(.appSubheadline(.medium))
                            .foregroundColor(Color("background"))
                            .padding(.horizontal, 32)
                            .padding(.vertical, 14)
                            .background(Color("Light grey"))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    
                    Button(action: onConfirm) {
                        Text("حذف")
                            .font(.appSubheadline(.semibold))
                            .foregroundColor(Color("background"))
                            .padding(.horizontal, 36)
                            .padding(.vertical, 14)
                            .background(Color("Red"))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()

                }
            }
            .padding(24)
            .background(Color("background"))
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color(.maincolor), lineWidth: 0.6))
            .padding(.horizontal, 50)
            .environment(\.layoutDirection, .rightToLeft)
        }
        .transition(.opacity)
    }
}
