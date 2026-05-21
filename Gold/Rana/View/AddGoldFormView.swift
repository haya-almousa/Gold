//
//  AddGoldFormView.swift
//  Gold
//
//  Created by Rana Alqubaly on 25/11/1447 AH.
//


internal import SwiftUI

private enum ImageSource: Identifiable {
    case photoLibrary, camera
    var id: Self { self }
    var pickerSourceType: UIImagePickerController.SourceType {
        self == .camera ? .camera : .photoLibrary
    }
}

struct AddGoldFormView: View {
    @ObservedObject var vm: ComparisonListViewModel

    @State private var showSourceSheet  = false
    @State private var imageSource: ImageSource? = nil
    @State private var showCalculator   = false

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

                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .confirmationDialog("اضافة صورة", isPresented: $showSourceSheet, titleVisibility: .visible) {
            Button("اختر من الصور") { imageSource = .photoLibrary }
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Button("التقاط صورة") { imageSource = .camera }
            }
            Button("الغاء", role: .cancel) {}
        }
        .sheet(item: $imageSource) { source in
            ImagePickerView(selectedImage: $vm.selectedImage, sourceType: source.pickerSourceType)
        }
        .sheet(isPresented: $showCalculator) {
            GoldCalculatorView(
                initialKarat:  karatOption,
                initialWeight: Double(vm.form.gramsText) ?? 0,
                onBack:        { showCalculator = false }
            )
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
                    .font(.appSubheadline(.semibold))
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
                    .font(.appSubheadline(.medium))
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
            .font(.appBody(.bold))
            .foregroundColor(Color("maincolor"))
            .frame(maxWidth: .infinity, alignment: .center)
    }

    // MARK: - Photo Picker

    @ViewBuilder
    private var photoPickerSection: some View {
        Button { showSourceSheet = true } label: {
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
                            .font(.appTitle())
                            .foregroundColor(Color("Light grey"))
                        Text("اضغط لاضافة صورة")
                            .font(.appFootnote())
                            .foregroundColor(Color("Light grey"))
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Piece Name

    @ViewBuilder
    private var nameSection: some View {
        labeledField("اسم القطعة*") {
            ThemedTextField(
                "مثال: اسوارة، خاتم",
                text: Binding(
                    get: { vm.form.name },
                    set: { vm.updateField(\.name, value: $0) }
                )
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(vm.nameError != nil ? Color("Red") : Color.clear, lineWidth: 1.5)
            )
            if let error = vm.nameError {
                inlineError(error)
            }
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
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(vm.gramsError != nil ? Color("Red") : Color.clear, lineWidth: 1.5)
            )
            if let error = vm.gramsError {
                inlineError(error)
            }
        }
    }

    // MARK: - Karat Selector

    @ViewBuilder
    private var karatSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("العيار*")
                .font(.appFootnote(.bold))
                .foregroundColor(Color("maincolor"))

            HStack(spacing: 6) {
                ForEach(Karat.allCases.reversed()) { k in
                    karatButton(k)
                }
            }
        }
    }

    private func karatButton(_ k: Karat) -> some View {
        let selected = vm.form.karat == k
        return Button(action: { vm.updateField(\.karat, value: k) }) {
            Text(k.label)
                .font(.appSubheadline(.semibold))
                .foregroundColor(selected ? Color("background") : Color("maincolor"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(selected ? Color("maincolor") : Color("Lightest gold"))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(.darkGold).opacity(0.6), lineWidth: 0.4)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Calculator Sheet Helper

    private var karatOption: GoldCalculatorView.KaratOption {
        switch vm.form.karat {
        case .k24: return .k24
        case .k21: return .k21
        case .k18: return .k18
        }
    }

    // MARK: - Shop Price + Tax Badge
    @ViewBuilder
    private var shopPriceTaxRow: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 6) {
                Text("سعر المحل بدون الضريبة*")
                    .font(.appFootnote(.bold))
                    .foregroundColor(Color("maincolor"))

                HStack(spacing: 0) {
                    // Price text input
                    ZStack(alignment: .trailing) {
                        if vm.form.shopPriceText.isEmpty {
                            Text("مثال: 1500")
                                .font(.system(size: 14))
                                .foregroundColor(Color("Light grey"))
                                .allowsHitTesting(false)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.horizontal, 16)
                        }
                        TextField("", text: Binding(
                            get: { vm.form.shopPriceText },
                            set: { vm.updateField(\.shopPriceText, value: $0) }
                        ))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .font(.system(size: 14).bold())
                        .foregroundColor(Color("maincolor"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .environment(\.layoutDirection, .leftToRight)
                    .frame(maxWidth: .infinity)

                    // تأكد button on the right
                    Button(action: { showCalculator = true }) {
                        HStack(spacing: 2) {
                            Text("تأكد")
                                .font(.system(size: 11, weight: .semibold))
                            Image(systemName: "chevron.left")
                                .font(.system(size: 9, weight: .semibold))
                        }
                        .foregroundColor(Color("background"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(Color("maincolor"))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 8)
                }
                .background(Color("Lightest gold"))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(vm.priceError != nil ? Color("Red") : Color(.darkGold).opacity(0.6), lineWidth: vm.priceError != nil ? 1.5 : 0.4)
                )

                if let error = vm.priceError {
                    inlineError(error)
                }
            }
            

            VStack(alignment: .center, spacing: 6) {
                Text("الضريبة")
                    .font(.appFootnote(.bold))
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
                .font(.appFootnote(.bold))
                .foregroundColor(Color("Grey"))
            Text("15%")
                .font(.appFootnote(.bold))
                .foregroundColor(Color("Grey"))
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 10)
        .padding(.vertical, 12)
        .background(Color("Lightest grey"))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(.grey), lineWidth: 0.4)
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
            .cornerRadius(20)
        }
    }

    // MARK: - inlineError
    
    @ViewBuilder
    private func inlineError(_ message: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.appCaption())
                .foregroundColor(Color("Red"))
            Text(message)
                .font(.appCaption())
                .foregroundColor(Color("Red"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
    }

    // MARK: - Helper

    @ViewBuilder
    private func labeledField<Content: View>(_ label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.appFootnote(.bold))
                .foregroundColor(Color("maincolor"))
            content()
        }
    }
}
