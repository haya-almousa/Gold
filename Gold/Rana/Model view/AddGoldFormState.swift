//
//  AddGoldFormState.swift
//  Gold
//
//  Created by Rana Alqubaly on 09/11/1447 AH.
//

import Foundation
import UIKit


struct AddGoldFormState {
    var name:       String = ""
    var store:      String = ""
    var gramsText:  String = ""
    var karat:      Karat  = .k21
    var mfgFeeText: String = "8"

    static func empty() -> AddGoldFormState { AddGoldFormState() }

    var grams:  Double? { Double(gramsText) }
    var mfgFee: Double  { Double(mfgFeeText) ?? 0 }
}

enum FormValidationError: LocalizedError {
    case emptyName, invalidGrams
    var errorDescription: String? {
        switch self {
        case .emptyName:    return "Please enter a piece name."
        case .invalidGrams: return "Please enter a valid weight in grams."
        }
    }
}

extension AddGoldFormState {
    func validated(image: UIImage?) throws -> GoldPiece {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty           else { throw FormValidationError.emptyName }
        guard let g = grams, g > 0           else { throw FormValidationError.invalidGrams }
        return GoldPiece(
            name: trimmedName,
            store: store.trimmingCharacters(in: .whitespaces),
            grams: g, karat: karat,
            mfgFeePercent: mfgFee, image: image
        )
    }
}
