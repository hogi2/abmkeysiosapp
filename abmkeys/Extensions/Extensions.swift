// Extensions.swift
// abmkeys
// Created by Hogan Alkahlan on 7/1/24.

import Foundation

/// Extension for formatting integers.
extension Int {
    /// Formats the integer as a string.
    /// - Returns: The formatted string.
    func formatted() -> String {
        return String(self)
    }
}

/// Extension for formatting doubles as currency.
extension Double {
    /// Formats the double as a currency string.
    /// - Parameters:
    ///   - locale: The locale to use for formatting. Defaults to the current locale.
    ///   - currencyCode: The currency code to use for formatting. Defaults to "SAR".
    /// - Returns: The formatted currency string.
    func formattedAsCurrency(locale: Locale = Locale.current, currencyCode: String = "SAR") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        formatter.currencyCode = currencyCode
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

/// Extension for formatting dates.
extension Date {
    /// Formats the date as a string.
    /// - Parameters:
    ///   - format: The date format string. Defaults to "yyyy-MM-dd".
    ///   - locale: The locale to use for formatting. Defaults to the current locale.
    /// - Returns: The formatted date string.
    func formatted(as format: String = "yyyy-MM-dd", locale: Locale = Locale.current) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = locale
        return formatter.string(from: self)
    }
    
    /// Formats the date as a localized date string.
    /// - Parameters:
    ///   - dateStyle: The style to use for the date. Defaults to `.medium`.
    ///   - timeStyle: The style to use for the time. Defaults to `.none`.
    /// - Returns: The localized formatted date string.
    func formatted(dateStyle: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .none) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        formatter.locale = .current
        return formatter.string(from: self)
    }
}
