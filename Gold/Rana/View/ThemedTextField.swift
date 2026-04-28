//
//  ThemedTextField.swift
//  Gold
//
//  Created by Rana Alqubaly on 09/11/1447 AH.
//

internal import SwiftUI


struct ThemedTextField: View {
    private let placeholder:  String
    @Binding var text:         String
    private let keyboardType: UIKeyboardType

    init(_ placeholder: String, text: Binding<String>,
         keyboardType: UIKeyboardType = .default) {
        self.placeholder = placeholder; self._text = text
        self.keyboardType = keyboardType
    }

    var body: some View {
        TextField(placeholder, text: $text)
            .keyboardType(keyboardType)
            .font(.system(size: 14))
            .foregroundColor(Color(.navy))
            .padding(.horizontal, 16).padding(.vertical, 12)
            .background(Color(.beige))
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.beige), lineWidth: 1))
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
                    .font(.system(size: 11)).foregroundColor(Color(.emarald))
            }
            .font(.system(size: 14)).foregroundColor(Color(.navy))
            .padding(.horizontal, 16).padding(.vertical, 12)
            .background(Color(.beige)).cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.beige), lineWidth: 1))
        }
    }
}
