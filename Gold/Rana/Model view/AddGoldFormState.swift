//
//  AddGoldFormState.swift
//  Gold
//
//  Created by Rana Alqubaly on 25/11/1447 AH.
//


import Foundation
import UIKit

struct AddGoldFormState {
    var name:          String = ""
    var store:         String = ""
    var gramsText:     String = ""
    var karat:         Karat  = .k21
    var shopPriceText: String = ""

    static func empty() -> AddGoldFormState { AddGoldFormState() }

    var grams:     Double? { Double(gramsText) }
    var shopPrice: Double? { Double(shopPriceText) }
}

enum FormValidationError: LocalizedError {
    case emptyName, invalidGrams, invalidPrice
    var errorDescription: String? {
        switch self {
        case .emptyName:    return "الرجاء إدخال اسم القطعة."
        case .invalidGrams: return "الرجاء إدخال الوزن بالجرام."
        case .invalidPrice: return "الرجاء إدخال سعر المحل."
        }
    }
}

extension AddGoldFormState {
    func validated(image: UIImage?) throws -> GoldPiece {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty      else { throw FormValidationError.emptyName }
        guard let g = grams, g > 0     else { throw FormValidationError.invalidGrams }
        guard let p = shopPrice, p > 0 else { throw FormValidationError.invalidPrice }
        return GoldPiece(
            name:          trimmedName,
            store:         store.trimmingCharacters(in: .whitespaces),
            grams:         g,
            karat:         karat,
            mfgFeePercent: 0.0,
            shopPrice:     p,
            image:         image
        )
    }
}