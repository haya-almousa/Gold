//
//  AddGoldFormView.swift
//  Gold
//
//  Created by Rana Alqubaly on 25/11/1447 AH.
//


internal import SwiftUI
import _PhotosUI_SwiftUI

struct AddGoldFormView: View {
    @ObservedObject var vm: ComparisonListViewModel

    var body: some View {
        VStack(spacing: 0) {
            topBar
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)

            Divider()
                .overlay(Color(.navy).opacity(0.08))

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    formTitle
                    photoPickerSection
                    nameSection
                    weightSection
                    karatSection
                    shopPriceTaxRow
                    storeSection
                    errorBanner
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Top Bar

    @ViewBuilder
    private var topBar: some View {
        HStack {
            Button(action: {
                vm.isEditing ? vm.saveEdit() : vm.saveAndCompare()
            }) {
                Text("قارن")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color("background"))
                    .padding(.horizontal, 28)
                    .padding(.vertical, 10)
                    .background(Color("maincolor"))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            Spacer()

            Button(action: { vm.cancelForm() }) {
                Text("الغاء")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color("background"))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Color("Light grey"))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Title

    @ViewBuilder
    private var formTitle: some View {
        Text("مقارنة قطعة ذهب")
            .font(.system(size: 17, weight: .bold))
            .foregroundColor(Color("maincolor"))
            .frame(maxWidth: .infinity, alignment: .center)
    }

    // MARK: - Photo Picker

    @ViewBuilder
    private var photoPickerSection: some View {
        PhotosPicker(selection: $vm.pickerItem, matching: .images) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                    .foregroundColor(Color("Gold"))
                    .frame(height: 130)
                    .background(
                        RoundedRectangle(cornerRadius: 14).fill(Color("Lightest gold").opacity(0.4))
                    )

                if let img = vm.selectedImage {
                    Image(uiImage: img)
                        .resizable().scaledToFill()
                        .frame(height: 130).clipped()
                        .cornerRadius(14)
                } else {
                    VStack(spacing: 10) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Color("Light grey"))
                        Text("اضغط لاضافة صورة")
                            .font(.system(size: 13))
                            .foregroundColor(Color("Light grey"))
                    }
                }
            }
        }
        .onChange(of: vm.pickerItem) { _ in
            Task { await vm.loadSelectedImage() }
        }
    }

    // MARK: - Piece Name

    @ViewBuilder
    private var nameSection: some View {
        labeledField("اسم القطعة") {
            ThemedTextField(
                "مثال: اسوارة، خاتم",
                text: Binding(
                    get: { vm.form.name },
                    set: { vm.updateField(\.name, value: $0) }
                )
            )
        }
    }

    // MARK: - Weight

    @ViewBuilder
    private var weightSection: some View {
        labeledField("الوزن (جرام)*") {
            ThemedTextField(
                "مثال: 5.5",
                text: Binding(
                    get: { vm.form.gramsText },
                    set: { vm.updateField(\.gramsText, value: $0) }
                ),
                keyboardType: .decimalPad
            )
        }
    }

    // MARK: - Karat Selector

    @ViewBuilder
    private var karatSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("العيار*")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(Color("maincolor"))

            HStack(spacing: 8) {
                ForEach(Karat.allCases) { k in
                    karatButton(k)
                }
            }
        }
    }

    private func karatButton(_ k: Karat) -> some View {
        let selected = vm.form.karat == k
        return Button(action: { vm.updateField(\.karat, value: k) }) {
            Text(k.label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(selected ? Color("background") : Color("maincolor"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(selected ? Color("maincolor") : Color("Lightest gold"))
                .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Shop Price + Tax Badge

    @ViewBuilder
    private var shopPriceTaxRow: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 6) {
                Text("سعر المحل بدون الضريبة*")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color("maincolor"))
                ThemedTextField(
                    "مثال: 1500",
                    text: Binding(
                        get: { vm.form.shopPriceText },
                        set: { vm.updateField(\.shopPriceText, value: $0) }
                    ),
                    keyboardType: .decimalPad
                )
            }

            VStack(alignment: .center, spacing: 6) {
                Text("الضريبة")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color("Dark grey"))
                vatBadge
            }
            .frame(width: 92)
        }
    }

    @ViewBuilder
    private var vatBadge: some View {
        HStack(spacing: 5) {
            Image(systemName: "lock.fill")
                .font(.system(size: 13).bold())
                .foregroundColor(Color("Grey"))
            Text("15%")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(Color("Grey"))
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 10)
        .padding(.vertical, 12)
        .background(Color("Lightest grey"))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.navy).opacity(0.12), lineWidth: 1)
        )
    }

    // MARK: - Store Info

    @ViewBuilder
    private var storeSection: some View {
        labeledField("معلومات المحل") {
            ThemedTextField(
                "مثال: 05534XXXXX، الفياض للذهب",
                text: Binding(
                    get: { vm.form.store },
                    set: { vm.updateField(\.store, value: $0) }
                )
            )
        }
    }

    // MARK: - Error Banner

    @ViewBuilder
    private var errorBanner: some View {
        if let error = vm.formError {
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(Color("Red"))
                    .font(.system(size: 13))
                Text(error)
                    .font(.system(size: 13))
                    .foregroundColor(Color(.navy))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color("Light red").opacity(0.4))
            .cornerRadius(10)
        }
    }

    // MARK: - Helper

    @ViewBuilder
    private func labeledField<Content: View>(_ label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(Color("maincolor"))
            content()
        }
    }
}
