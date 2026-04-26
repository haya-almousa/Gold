//
//  AddGoldFormView.swift
//  Gold
//
//  Created by Rana Alqubaly on 09/11/1447 AH.
//

internal import SwiftUI
import _PhotosUI_SwiftUI



struct AddGoldFormView: View {
    @ObservedObject var vm: TojoryViewModel
    @Environment(\.theme) private var G

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Add Gold Piece")
                .font(.system(size: 14, weight: .semibold)).foregroundColor(G.goldLight)

            // Photo picker
            PhotosPicker(selection: $vm.pickerItem, matching: .images) {
                photoPickerLabel
            }
            .onChange(of: vm.pickerItem) { _ in Task { await vm.loadSelectedImage() } }

            // Name
            ThemedTextField("Piece name (e.g. Gold Bracelet)", text: Binding(
                get: { vm.form.name },
                set: { vm.updateField(\.name, value: $0) }
            ))

            // Store
            ThemedTextField("Store / Jeweler (optional)", text: Binding(
                get: { vm.form.store },
                set: { vm.updateField(\.store, value: $0) }
            ))

            // Weight + Karat
            HStack(spacing: 10) {
                ThemedTextField("Grams", text: Binding(
                    get: { vm.form.gramsText },
                    set: { vm.updateField(\.gramsText, value: $0) }
                ), keyboardType: .decimalPad)

                KaratPicker(selection: Binding(
                    get: { vm.form.karat },
                    set: { vm.updateField(\.karat, value: $0) }
                ))
            }

            // Manufacturing fee + VAT constant badge side by side
            HStack(spacing: 10) {
                ThemedTextField("Manufacturing fee %", text: Binding(
                    get: { vm.form.mfgFeeText },
                    set: { vm.updateField(\.mfgFeeText, value: $0) }
                ), keyboardType: .decimalPad)

                // VAT — constant, not editable
                VStack(alignment: .leading, spacing: 3) {
                    Text("VAT")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(G.textMuted)
                    HStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 9))
                            .foregroundColor(G.textFaint)
                        Text("15%")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(G.textMuted)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 12).padding(.vertical, 12)
                    .background(G.surface3)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(G.border.opacity(0.5), lineWidth: 1)
                    )
                }
                .frame(width: 80)
            }

            // Validation error
            if let error = vm.formError {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(G.warn).font(.system(size: 13))
                    Text(error).font(.system(size: 12)).foregroundColor(G.warn)
                }
                .padding(.horizontal, 12).padding(.vertical, 8)
                .background(G.warnBg)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(G.warn.opacity(0.4), lineWidth: 1))
                .cornerRadius(8)
            }

            // Save & Compare
            Button(action: vm.saveAndCompare) {
                Text("Save & Compare")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(G.bg)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(G.buttonGradient)
                    .cornerRadius(10)
            }
        }
        .padding(18)
        .background(G.surface).cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(G.border, lineWidth: 1))
    }

    @ViewBuilder
    private var photoPickerLabel: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [6]))
                .foregroundColor(G.border).frame(height: 110)
                .background(
                    vm.selectedImage == nil ? G.surface2 : Color.clear,
                    in: RoundedRectangle(cornerRadius: 12)
                )
            if let img = vm.selectedImage {
                Image(uiImage: img).resizable().scaledToFill()
                    .frame(height: 110).clipped().cornerRadius(12)
            } else {
                VStack(spacing: 7) {
                    Image(systemName: "camera").font(.system(size: 26)).foregroundColor(G.textMuted)
                    Text("Tap to add photo").font(.system(size: 12)).foregroundColor(G.textMuted)
                }
            }
        }
    }
}
