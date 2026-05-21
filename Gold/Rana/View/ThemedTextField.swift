//
//  ThemedTextField.swift
//  Gold
//
//  Created by Rana Alqubaly on 25/11/1447 AH.
//


internal import SwiftUI

struct ThemedTextField: View {
    private let placeholder:  String
    @Binding var text:        String
    private let keyboardType: UIKeyboardType

    init(_ placeholder: String, text: Binding<String>,
         keyboardType: UIKeyboardType = .default) {
        self.placeholder = placeholder; self._text = text
        self.keyboardType = keyboardType
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            if text.isEmpty {
                Text(placeholder)
                    .font(.appSubheadline())
                    .foregroundColor(Color("Light grey"))
                    .allowsHitTesting(false)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal, 16)
            }
            TextField("", text: $text)
                .keyboardType(keyboardType)
                .multilineTextAlignment(.trailing)
                .font(.appSubheadline(.bold))
                .foregroundColor(Color("maincolor"))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .onChange(of: text) {
                    guard keyboardType == .decimalPad else { return }
                    let filtered = text
                        .replacingOccurrences(of: ",", with: ".")
                        .filter { $0.isNumber || $0 == "." }
                    // allow only one decimal point
                    let parts = filtered.components(separatedBy: ".")
                    let clean = parts.count > 2
                        ? parts[0] + "." + parts[1...].joined()
                        : filtered
                    if clean != text { text = clean }
                }
        }
        .environment(\.layoutDirection, .leftToRight)
        .background(Color("Lightest gold"))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(.darkGold), lineWidth: 0.4))
    }
}

struct KaratPicker: View {
    @Binding var selection: Karat

    var body: some View {
        Menu {
            Picker("Karat", selection: $selection) {
                ForEach(Karat.allCases) { k in Text(k.label).tag(k) }
            }
        } label: {
            HStack {
                Text(selection.label)
                Spacer()
                Image(systemName: "chevron.up.chevron.down")
                    .font(.appCaption()).foregroundColor(Color("maincolor"))
            }
            .font(.appSubheadline()).foregroundColor(Color(.navy))
            .padding(.horizontal, 16).padding(.vertical, 12)
            .background(Color("Lightest gold")).cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("maincolor").opacity(0.08), lineWidth: 1))
        }
    }
}
