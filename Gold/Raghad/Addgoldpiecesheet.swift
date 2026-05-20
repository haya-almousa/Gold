//
//  Addgoldpiecesheet.swift
//  Gold
//
//  Created by Raghad Alamoudi on 04/12/1447 AH.
//


internal import SwiftUI
import PhotosUI

// MARK: - AddGoldPieceSheet

struct AddGoldPieceSheet: View {

    // ← جديد: اختياري للتعديل، nil للإضافة
    var existingPiece: GoldPieceItem? = nil
    var onSave: (GoldPieceItem) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var name:           String             = ""
    @State private var weightText:     String             = ""
    @State private var karat:          GoldKarat          = .k18
    @State private var condition:      GoldCondition      = .worn
    @State private var purchaseText:   String             = ""
    @State private var ownershipDate:  Date?              = nil
    @State private var showCalendar:   Bool               = false
    @State private var photoItem:      PhotosPickerItem?  = nil
    @State private var selectedImage:  UIImage?           = nil
    @State private var showValidation: Bool               = false

    @State private var showConditionTip: Bool = false

    // عنوان الشيت يتغير حسب الوضع
    private var sheetTitle: String {
        existingPiece == nil ? "اضافة قطعة ذهب" : "تعديل قطعة ذهب"
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar
            divider
            formTitle
            formScroll
        }
        .background(Color("background"))
        .environment(\.layoutDirection, .rightToLeft)
        // ← يقفل البالون إذا انضغط في أي مكان خارج العناصر
        .onTapGesture {
            if showConditionTip {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    showConditionTip = false
                }
            }
        }
        .photosPicker(
            isPresented: Binding(
                get: { photoItem != nil },
                set: { if !$0 { photoItem = nil } }
            ),
            selection: $photoItem,
            matching: .images
        )
        .onChange(of: photoItem) { _, item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self) {
                    selectedImage = UIImage(data: data)
                }
            }
        }
        .alert("تنبيه", isPresented: $showValidation) {
            Button("حسناً") {}
        } message: {
            Text("الرجاء تعبئة الاسم والوزن وسعر الشراء")
        }
        // ← تعبئة البيانات عند فتح شيت التعديل
        .onAppear { prefillIfEditing() }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button(action: attemptSave) {
                Text("حفظ")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color("background"))
                    .padding(.horizontal, 28)
                    .padding(.vertical, 10)
                    .background(Color("maincolor"))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            Spacer()

            Button(action: { dismiss() }) {
                Text("إلغاء")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color("background"))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Color("Light grey"))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    private var divider: some View {
        Divider()
            .overlay(Color(.navy).opacity(0.08))
    }

    private var formTitle: some View {
        Text(sheetTitle)
            .font(.system(size: 17, weight: .bold))
            .foregroundColor(Color("Dark green"))
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 12)
    }

    private var formScroll: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .trailing, spacing: 20) {
                imageArea
                nameField
                weightField
                karatField
                conditionField
                purchaseField
                dateField
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 50)
        }
    }

    // MARK: - Image

    private var imageArea: some View {
        Button {
            photoItem = PhotosPickerItem(itemIdentifier: UUID().uuidString)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                    .foregroundColor(Color("Light grey"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 140)

                if let img = selectedImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "camera")
                            .font(.system(size: 26))
                            .foregroundColor(Color("Grey"))
                        Text("اضغط لاضافة صورة")
                            .font(.system(size: 14))
                            .foregroundColor(Color("Grey"))
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Fields

    private var nameField: some View {
        VStack(alignment: .trailing, spacing: 6) {
            fieldLabel("اسم القطعة")
            TextField("مثال: اسوارة، خاتم", text: $name)
                .tajouriFieldStyle()
        }
    }

    private var weightField: some View {
        VStack(alignment: .trailing, spacing: 6) {
            fieldLabel("الوزن (جرام)*")
            TextField("مثال: 5.5", text: $weightText)
                .keyboardType(.decimalPad)
                .tajouriFieldStyle()
        }
    }

    private var karatField: some View {
        VStack(alignment: .trailing, spacing: 6) {
            fieldLabel("العيار*")
            HStack(spacing: 8) {
                ForEach(GoldKarat.allCases) { k in
                    karatButton(k)
                }
            }
        }
    }

    private var conditionField: some View {
        VStack(alignment: .trailing, spacing: 6) {
            HStack {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showConditionTip.toggle()
                    }
                } label: {
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(showConditionTip ? Color("Dark green") : Color("Grey"))
                        .font(.system(size: 16))
                }
                .buttonStyle(.plain)
                .overlay(alignment: .topLeading) {
                    if showConditionTip {
                        tooltipBubble
                            .offset(x: -10, y: -90)
                            .transition(.scale(scale: 0.85, anchor: .bottomLeading).combined(with: .opacity))
                            .zIndex(10)
                    }
                }

                Spacer()
                fieldLabel("حالة القطعة*")
            }
            HStack(spacing: 10) {
                conditionButton(.unworn)
                conditionButton(.worn)
            }
        }
    }

    private var tooltipBubble: some View {
        VStack(alignment: .trailing, spacing: 6) {
            VStack(alignment: .trailing, spacing: 5) {
                Label("ملبوسة", systemImage: "circle.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color("Dark green"))
                    .labelStyle(ReversedLabelStyle())
                Text("الذهب الملبوس لا تجب فيه الزكاة")
                    .font(.system(size: 12))
                    .foregroundColor(Color("Dark grey"))
                    .multilineTextAlignment(.trailing)

                Divider().padding(.vertical, 2)

                Label("غير ملبوسة", systemImage: "circle.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color("Dark green"))
                    .labelStyle(ReversedLabelStyle())
                Text("الذهب غير الملبوس تجب فيه الزكاة إذا بلغ النصاب")
                    .font(.system(size: 12))
                    .foregroundColor(Color("Dark grey"))
                    .multilineTextAlignment(.trailing)
            }
            .padding(12)
            .background(Color("background"))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
            .frame(width: 280) // ← توسعة العرض لعرض النص كامل
        }
        // ← يمنع إغلاق البالون عند الضغط داخله (يستهلك التاب)
        .onTapGesture { }
        .overlay(
            // المثلث الصغير
            VStack {
                Spacer()
                HStack {
                    Image(systemName: "arrowtriangle.down.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Color("background"))
                        .offset(x: 14, y: 6)
                    Spacer()
                }
            }
        )
    }

    private var purchaseField: some View {
        VStack(alignment: .trailing, spacing: 6) {
            fieldLabel("سعر الشراء (ر.س)*")
            TextField("مثال: 1500", text: $purchaseText)
                .keyboardType(.decimalPad)
                .tajouriFieldStyle()
        }
    }

    private var dateField: some View {
        VStack(alignment: .trailing, spacing: 6) {
            fieldLabel("تاريخ الامتلاك (لحساب الزكاة)")
            dateRow
        }
    }

    // MARK: - Reusable Components

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 15, weight: .bold))
            .foregroundColor(Color("Dark green"))
            .frame(maxWidth: .infinity, alignment: .trailing)
    }

    private func karatButton(_ k: GoldKarat) -> some View {
        let selected = karat == k
        return Button(action: { karat = k }) {
            Text(k.label)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(selected ? Color("background") : Color("Dark green"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(selected ? Color("maincolor") : Color("Lightest gold"))
                .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }

    private func conditionButton(_ c: GoldCondition) -> some View {
        let selected = condition == c
        return Button(action: { condition = c }) {
            Text(c.rawValue)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(selected ? Color("background") : Color("Dark green"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(selected ? Color("Dark green") : Color("Lightest gold"))
                .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }

    private var dateRow: some View {
        VStack(alignment: .trailing, spacing: 8) {
            Button(action: { withAnimation { showCalendar.toggle() } }) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(Color("Grey"))
                        .font(.system(size: 16))
                    Spacer()
                    Text(ownershipDate.map { formatDate($0) } ?? "يوم / شهر / سنة")
                        .font(.system(size: 15))
                        .foregroundColor(ownershipDate == nil ? Color("Light grey") : Color("Dark grey"))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 13)
                .background(Color("Lightest gold"))
                .cornerRadius(10)
            }
            .buttonStyle(.plain)

            if showCalendar {
                DatePicker(
                    "",
                    selection: Binding(
                        get: { ownershipDate ?? Date() },
                        set: { ownershipDate = $0 }
                    ),
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .tint(Color("Dark green"))
                .background(Color("background"))
                .cornerRadius(12)
            }
        }
    }

    // MARK: - Prefill for Edit Mode

    private func prefillIfEditing() {
        guard let piece = existingPiece else { return }
        name          = piece.name
        weightText    = String(piece.weightGrams)
        karat         = piece.karat
        condition     = piece.condition
        purchaseText  = String(piece.purchasePrice)
        ownershipDate = piece.ownershipDate
        if let data = piece.imageData {
            selectedImage = UIImage(data: data)
        }
    }

    // MARK: - Save Logic

    private func attemptSave() {
        guard
            !name.isEmpty,
            let weight   = Double(weightText), weight > 0,
            let purchase = Double(purchaseText), purchase > 0
        else {
            showValidation = true
            return
        }

        // ← إذا تعديل نحتفظ بنفس الـ id، وإلا نولد id جديد
        let piece = GoldPieceItem(
            id:            existingPiece?.id ?? UUID(),
            name:          name,
            weightGrams:   weight,
            karat:         karat,
            condition:     condition,
            purchasePrice: purchase,
            ownershipDate: ownershipDate,
            imageData:     selectedImage?.jpegData(compressionQuality: 0.75)
        )
        onSave(piece)
        dismiss()
    }

    private func formatDate(_ d: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ar")
        return formatter.string(from: d)
    }
}

// MARK: - TextField Style

private extension View {
    func tajouriFieldStyle() -> some View {
        self
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .background(Color("Lightest gold"))
            .cornerRadius(10)
            .font(.system(size: 15))
            .multilineTextAlignment(.trailing)
    }
}

// MARK: - Reversed Label Style (icon على اليمين)

struct ReversedLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 5) {
            configuration.title
            configuration.icon
                .font(.system(size: 7))
                .foregroundColor(Color("Gold"))
        }
    }
}
