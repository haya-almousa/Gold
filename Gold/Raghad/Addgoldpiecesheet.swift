//
//  Addgoldpiecesheet.swift
//  Gold
//
//  Created by Raghad Alamoudi on 04/12/1447 AH.
//


internal import SwiftUI
import PhotosUI

extension UIImagePickerController.SourceType: @retroactive Identifiable {
    public var id: Int { rawValue }
}

// MARK: - AddGoldPieceSheet

struct AddGoldPieceSheet: View {

    var existingPiece: GoldPieceItem? = nil
    var onSave: (GoldPieceItem) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var name:           String            = ""
    @State private var weightText:     String            = ""
    @State private var karat:          GoldKarat         = .k18
    @State private var condition:      GoldCondition     = .worn
    @State private var purchaseText:   String            = ""
    @State private var ownershipDate:  Date?             = nil
    @State private var showCalendar:     Bool              = false
    @State private var photoItem:        PhotosPickerItem? = nil
    @State private var selectedImage:    UIImage?          = nil
    @State private var showConditionTip: Bool              = false
    @State private var showImageSource:  Bool              = false
    @State private var imageSourceType:  UIImagePickerController.SourceType? = nil
    @State private var nameError:        String?           = nil
    @State private var weightError:      String?           = nil
    @State private var priceError:       String?           = nil

    private var sheetTitle: String {
        existingPiece == nil ? "اضافة قطعة ذهب" : "تعديل قطعة ذهب"
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar
           
            formTitle
            formScroll
        }
        .background(Color("background"))
        .environment(\.layoutDirection, .leftToRight)
        .onTapGesture {
            if showConditionTip {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    showConditionTip = false
                }
            }
        }
        .confirmationDialog("اضافة صورة", isPresented: $showImageSource, titleVisibility: .visible) {
            Button("اختر من الصور") { imageSourceType = .photoLibrary }
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Button("التقاط صورة") { imageSourceType = .camera }
            }
            Button("الغاء", role: .cancel) {}
        }
        .sheet(item: Binding(
            get: { imageSourceType },
            set: { imageSourceType = $0 }
        )) { sourceType in
            ImagePickerView(selectedImage: $selectedImage, sourceType: sourceType)
        }
        .onAppear { prefillIfEditing() }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button(action: attemptSave) {
                Text("حفظ")
                    .font(.appBody(.semibold))
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
                    .font(.appBody(.semibold))
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

    

    private var formTitle: some View {
        Text(sheetTitle)
            .font(.appTitle3(.bold))
            .foregroundColor(Color("Dark green"))
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 12)
    }

    private var formScroll: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                imageArea
                nameField
                weightField
                karatField
                conditionField.zIndex(showConditionTip ? 10 : 0)
                purchaseField
                // ── تاريخ الامتلاك: يظهر فقط عند اختيار "غير ملبوسة" ──
                if condition == .unworn {
                    dateField
                        .transition(.opacity.combined(with: .scale(scale: 0.97, anchor: .top)))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 50)
            .animation(.spring(response: 0.3, dampingFraction: 0.85), value: condition)
        }
    }

    // MARK: - Image

    private var imageArea: some View {
        Button {
            showImageSource = true
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                    .foregroundColor(Color("Gold"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 140)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color("Lightest gold").opacity(0.4))
                    )

                if let img = selectedImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                } else {
                    VStack(spacing: 10) {
                        Image(systemName: "camera.fill")
                            .font(.appTitle2())
                            .foregroundColor(Color("Light grey"))
                        Text("اضغط لاضافة صورة")
                            .font(.appSubheadline())
                            .foregroundColor(Color("Light grey"))
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Fields

    private var nameField: some View {
        VStack(alignment: .leading, spacing: 6) {
            fieldLabel("اسم القطعة")
            TextField("مثال: اسوارة، خاتم", text: $name)
                .tajouriFieldStyle(hasError: nameError != nil)
                .onChange(of: name) { nameError = nil }
            if let e = nameError { inlineError(e) }
        }
    }

    private var weightField: some View {
        VStack(alignment: .leading, spacing: 6) {
            fieldLabel("الوزن (جرام)*")
            TextField("مثال: 5.5", text: $weightText)
                .keyboardType(.decimalPad)
                .tajouriFieldStyle(hasError: weightError != nil)
                .onChange(of: weightText) { weightError = nil }
            if let e = weightError { inlineError(e) }
        }
    }

    private var karatField: some View {
        VStack(alignment: .leading, spacing: 6) {
            fieldLabel("العيار*")
            HStack(spacing: 8) {
                ForEach(GoldKarat.allCases) { k in
                    karatButton(k)
                }
            }
        }
    }

    private var conditionField: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showConditionTip.toggle()
                    }
                } label: {
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(showConditionTip ? Color("Dark green") : Color("Grey"))
                        .font(.appCallout())
                }
                .buttonStyle(.plain)
                Text("حالة القطعة*")
                    .font(.appBody(.bold))
                    .foregroundColor(Color("Dark green"))
            }
            HStack(spacing: 10) {
                conditionButton(.unworn)
                conditionButton(.worn)
            }
        }
        .overlay(alignment: .topTrailing) {
            if showConditionTip {
                tooltipBubble
                    .offset(y: 32)
                    .transition(.scale(scale: 0.85, anchor: .topTrailing).combined(with: .opacity))
            }
        }
        .zIndex(showConditionTip ? 10 : 0)
    }

    private var tooltipBubble: some View {
        VStack(alignment: .trailing, spacing: 6) {

            VStack(alignment: .trailing, spacing: 5) {
                Label("ملبوسة", systemImage: "circle.fill")
                    .font(.appFootnote(.bold))
                    .foregroundColor(Color("Dark green"))
                    .labelStyle(ReversedLabelStyle())

                Text("الذهب الملبوس لا تجب فيه الزكاة")
                    .font(.appCaption())
                    .foregroundColor(Color("Dark grey"))
                    .multilineTextAlignment(.trailing)

                Divider().padding(.vertical, 2)

                Label("غير ملبوسة", systemImage: "circle.fill")
                    .font(.appFootnote(.bold))
                    .foregroundColor(Color("Dark green"))
                    .labelStyle(ReversedLabelStyle())

                Text("الذهب غير الملبوس تجب فيه الزكاة إذا بلغ النصاب")
                    .font(.appCaption())
                    .foregroundColor(Color("Dark grey"))
                    .multilineTextAlignment(.trailing)
            }
            .padding(16) // مساحة أكبر
            .background(Color("background"))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
            .frame(width: 290) // عرض أكبر

            Image(systemName: "arrowtriangle.down.fill")
                .font(.appCaption())
                .foregroundColor(Color("background"))
                .offset(x: 14, y: -2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 10)
        }
    }

    private var purchaseField: some View {
        VStack(alignment: .leading, spacing: 6) {
            fieldLabel("سعر الشراء (ر.س)*")
            TextField("مثال: 1500", text: $purchaseText)
                .keyboardType(.decimalPad)
                .tajouriFieldStyle(hasError: priceError != nil)
                .onChange(of: purchaseText) { priceError = nil }
            if let e = priceError { inlineError(e) }
        }
    }

    private var dateField: some View {
        VStack(alignment: .leading, spacing: 6) {
            fieldLabel("تاريخ الامتلاك (لحساب الزكاة)")
            dateRow
        }
    }

    // MARK: - Reusable Components

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.appBody(.bold))
            .foregroundColor(Color("Dark green"))
            .frame(maxWidth: .infinity, alignment: .trailing)
    }

    private func karatButton(_ k: GoldKarat) -> some View {
        let selected = karat == k
        return Button(action: { karat = k }) {
            Text(k.label)
                .font(.appBody(.semibold))
                .foregroundColor(selected ? Color("background") : Color("Dark green"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(selected ? Color("maincolor") : Color("Lightest gold"))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(.darkGold), lineWidth: 0.2)
                )
        }
        .buttonStyle(.plain)
    }

    private func conditionButton(_ c: GoldCondition) -> some View {
        let selected = condition == c
        return Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                condition = c
                if c == .worn {
                    ownershipDate = nil
                    showCalendar  = false
                }
            }
        }) {
            Text(c.rawValue)
                .font(.appBody(.bold))
                .foregroundColor(selected ? Color("background") : Color("Dark green"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(selected ? Color("Dark green") : Color("Lightest gold"))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(.darkGold), lineWidth: 0.2)
                )
        }
        .buttonStyle(.plain)
    }
    private var dateRow: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                showCalendar.toggle()
            }
        }) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(Color("Grey"))
                    .font(.appCallout())
                Spacer()
                Text(ownershipDate.map { formatDate($0) } ?? "يوم / شهر / سنة")
                    .font(.appBody())
                    .foregroundColor(ownershipDate == nil ? Color("Light grey") : Color("Dark grey"))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .background(Color("Lightest gold"))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(.darkGold), lineWidth: 0.2)
            )
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showCalendar) {
            calendarPopup
                .presentationDetents([.fraction(0.55)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(24)
        }
    }

    // MARK: - iOS Popup DatePicker
    struct iOSDatePickerPopup: UIViewControllerRepresentable {
        @Binding var selectedDate: Date?
        @Binding var isPresented: Bool

        func makeUIViewController(context: Context) -> UIViewController {
            let controller = UIViewController()
            controller.view.backgroundColor = .clear

            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            datePicker.preferredDatePickerStyle = .inline // نفس شكل iOS الحديث
            datePicker.maximumDate = Date()
            datePicker.tintColor = UIColor(named: "Dark green")
            datePicker.addTarget(context.coordinator, action: #selector(Coordinator.dateChanged(_:)), for: .valueChanged)

            controller.view.addSubview(datePicker)
            datePicker.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                datePicker.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor),
                datePicker.centerYAnchor.constraint(equalTo: controller.view.centerYAnchor)
            ])

            return controller
        }

        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }

        class Coordinator: NSObject {
            var parent: iOSDatePickerPopup
            init(_ parent: iOSDatePickerPopup) { self.parent = parent }

            @objc func dateChanged(_ sender: UIDatePicker) {
                parent.selectedDate = sender.date
                parent.isPresented = false // يغلق تلقائيًا بعد الاختيار
            }
        }
    }

    private var calendarPopup: some View {
        VStack(spacing: 0) {
            DatePicker(
                "",
                selection: Binding(
                    get: { ownershipDate ?? Date() },
                    set: {
                        ownershipDate = $0
                        showCalendar  = false
                    }
                ),
                in: ...Date(),
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .tint(Color("Dark green")) // لون التحديد داخل التقويم
            .environment(\.calendar, Calendar(identifier: .gregorian))
            .environment(\.locale, Locale(identifier: "en_US"))
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .background(Color("background").opacity(0.6)) // خلفية ناعمة متناسقة مع التطبيق
            .cornerRadius(16) // زوايا ناعمة للتقويم نفسه
            .shadow(color: Color("background").opacity(0.15), radius: 10, x: 0, y: 4) // ظل خفيف ذهبي
        }
        .padding(.vertical, 10)
        .background(Color("background")) // خلفية النافذة المنبثقة
        .cornerRadius(24)
        .environment(\.layoutDirection, .rightToLeft)
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
        nameError   = nil
        weightError = nil
        priceError  = nil

        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            nameError = "الرجاء إدخال اسم القطعة"
            return
        }
        let weight = Double(weightText.replacingOccurrences(of: ",", with: "."))
        if weight == nil || (weight ?? 0) <= 0 {
            weightError = "الرجاء إدخال الوزن بالجرام"
            return
        }
        let purchase = Double(purchaseText.replacingOccurrences(of: ",", with: "."))
        if purchase == nil || (purchase ?? 0) <= 0 {
            priceError = "الرجاء إدخال سعر الشراء"
            return
        }

        let piece = GoldPieceItem(
            id:            existingPiece?.id ?? UUID(),
            name:          name.trimmingCharacters(in: .whitespaces),
            weightGrams:   weight!,
            karat:         karat,
            condition:     condition,
            purchasePrice: purchase!,
            ownershipDate: condition == .unworn ? ownershipDate : nil,
            imageData:     selectedImage?.jpegData(compressionQuality: 0.75)
        )
        onSave(piece)
        dismiss()
    }

    private func formatDate(_ d: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d / M / yyyy"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: d)
    }
}

// MARK: - TextField Style

private extension View {
    func tajouriFieldStyle(hasError: Bool = false) -> some View {
        self
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .background(Color("Lightest gold"))
            .cornerRadius(20)
            .font(.appBody())
            .multilineTextAlignment(.trailing)
            .environment(\.layoutDirection, .leftToRight)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(hasError ? Color("Red") : Color(.darkGold), lineWidth: hasError ? 1.5 : 0.2)
            )
    }
}

private func inlineError(_ message: String) -> some View {
    HStack(spacing: 4) {
        Image(systemName: "exclamationmark.circle.fill")
            .font(.appCaption())
            .foregroundColor(Color("Red"))
        Text(message)
            .font(.appCaption())
            .foregroundColor(Color("Red"))
    }
    .frame(maxWidth: .infinity, alignment: .trailing)
    .padding(.horizontal, 4)
    .environment(\.layoutDirection, .leftToRight)
}

// MARK: - Reversed Label Style

struct ReversedLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 5) {
            configuration.title
            configuration.icon
                .font(.appCaption())
                .foregroundColor(Color("Gold"))
        }
    }
}
