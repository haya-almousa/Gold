// The body is deliberately split into named @ViewBuilder sub-properties.
// This avoids the "Failed to produce diagnostic for expression" compiler crash
// that Swift triggers when a single body closure exceeds its type-checking limit.

internal import SwiftUI
import _PhotosUI_SwiftUI

struct AddGoldFormView: View {
    @ObservedObject var vm: TojoryViewModel

    // ── body: lean — just stacks the named sub-sections ──────────────────────
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            formHeader
            photoPicker
            nameAndStoreFields
            weightKaratRow
            mfgVatRow
            errorBanner
            actionButtons
        }
        .padding(18)
        .background(Color(.beige))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.navy), lineWidth: 1))
    }

    // ── Sub-section 1: title ──────────────────────────────────────────────────
    @ViewBuilder
    private var formHeader: some View {
        Text(vm.isEditing ? "Edit Gold Piece" : "Add Gold Piece")
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(Color(.navy))
    }

    // ── Sub-section 2: photo picker ───────────────────────────────────────────
    @ViewBuilder
    private var photoPicker: some View {
        PhotosPicker(selection: $vm.pickerItem, matching: .images) {
            photoPickerLabel
        }
        .onChange(of: vm.pickerItem) { _ in
            Task { await vm.loadSelectedImage() }
        }
    }

    @ViewBuilder
    private var photoPickerLabel: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [6]))
                .foregroundColor(Color(.beige))
                .frame(height: 110)
                .background(
                    vm.selectedImage == nil ? Color(.beige) : Color.clear,
                    in: RoundedRectangle(cornerRadius: 12)
                )
            if let img = vm.selectedImage {
                Image(uiImage: img).resizable().scaledToFill()
                    .frame(height: 110).clipped().cornerRadius(12)
            } else {
                VStack(spacing: 7) {
                    Image(systemName: "camera")
                        .font(.system(size: 26)).foregroundColor(Color.navy)
                    Text("Tap to add photo")
                        .font(.system(size: 12)).foregroundColor(Color.navy)
                }
            }
        }
    }

    // ── Sub-section 3: name + store ───────────────────────────────────────────
    @ViewBuilder
    private var nameAndStoreFields: some View {
        var textColor: Color = Color(.navy)
        ThemedTextField(
            "Piece name (e.g. Gold Bracelet)",
            text: Binding(
                get: { vm.form.name },
                set: { vm.updateField(\.name, value: $0) }
            )
        )
        ThemedTextField(
            "Store / Jeweler (optional)",
            text: Binding(
                get: { vm.form.store },
                set: { vm.updateField(\.store, value: $0) }
            )
        )
        .foregroundColor(Color(.navy))
    }

    // ── Sub-section 4: weight + karat ─────────────────────────────────────────
    @ViewBuilder
    private var weightKaratRow: some View {
        HStack(spacing: 10) {
            ThemedTextField(
                "Grams",
                text: Binding(
                    get: { vm.form.gramsText },
                    set: { vm.updateField(\.gramsText, value: $0) }
                ),
                keyboardType: .decimalPad,
            )
            KaratPicker(
                selection: Binding(
                    get: { vm.form.karat },
                    set: { vm.updateField(\.karat, value: $0) }
                )
            )
            .foregroundColor(Color(.navy))
        }
    }

    // ── Sub-section 5: manufacturing fee + VAT badge ──────────────────────────
    @ViewBuilder
    private var mfgVatRow: some View {
        HStack(spacing: 10) {
            ThemedTextField(
                "Manufacturing fee %",
                text: Binding(
                    get: { vm.form.mfgFeeText },
                    set: { vm.updateField(\.mfgFeeText, value: $0) }
                ),
                keyboardType: .decimalPad
            )
            vatBadge
        }
    }

    @ViewBuilder
    private var vatBadge: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("VAT")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(Color(.navy))
            HStack(spacing: 4) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 9))
                    .foregroundColor(Color(.emarald))
                Text("15%")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(.emarald))
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(Color(.beige))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.beige).opacity(0.5), lineWidth: 1)
            )
        }
        .frame(width: 80)
    }

    // ── Sub-section 6: validation error ──────────────────────────────────────
    @ViewBuilder
    private var errorBanner: some View {
        if let error = vm.formError {
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(Color(.emarald))
                    .font(.system(size: 13))
                Text(error)
                    .font(.system(size: 12))
                    .foregroundColor(Color(.navy))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.beige))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.beige).opacity(0.4), lineWidth: 1)
            )
            .cornerRadius(8)
        }
    }

    // ── Sub-section 7: primary CTA + cancel ──────────────────────────────────
    @ViewBuilder
    private var actionButtons: some View {
        Button(action: {
            if vm.isEditing {
                vm.saveEdit()
            } else {
                vm.saveAndCompare()
            }
        }) {
            Group {
                if vm.isEditing {
                    Text("Update Piece")
                } else {
                    Text("Save & Compare")
                }
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(Color.navy)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(Color.emarald)
            .cornerRadius(10)
        }
        if vm.isEditing {
            Button(action: { withAnimation { vm.toggleForm() } }) {
                Text("Cancel")
                    .font(.system(size: 13))
                    .foregroundColor(Color(.navy))
                    .frame(maxWidth: .infinity)
            }
        }
    }
}
