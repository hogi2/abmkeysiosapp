// Extensions.swift
// abmkeys
// Created by Hogan Alkahlan on 7/1/24.

import Foundation

// Extension for formatting integers
extension Int {
    func formatted() -> String {
        return String(self)
    }
}

// Extension for formatting currency
extension Double {
    func formattedAsCurrency(locale: Locale = Locale.current, currencyCode: String = "SAR") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        formatter.currencyCode = currencyCode
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

// Extension for formatting dates
extension Date {
    func formatted(as format: String = "yyyy-MM-dd", locale: Locale = Locale.current) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = locale
        return formatter.string(from: self)
    }
}
