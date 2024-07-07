//
//  KeychainHelper.swift
//  abmkeys
//
//  Created by Hogan Alkahlan on 7/8/24.
//

import Foundation
import Security

struct WooCommerceCredentials: Codable {  // Declare only once
    let consumerKey: String
    let consumerSecret: String
}

class KeychainHelper {

    static func save(credentials: WooCommerceCredentials) throws {
        let data = try JSONEncoder().encode(credentials)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "WooCommerceCredentials",
            kSecValueData as String: data
        ]

        // Delete any existing item with the same account
        SecItemDelete(query as CFDictionary)
        
        // Add the new item to the keychain
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil) }
    }

    static func getCredentials() -> WooCommerceCredentials? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "WooCommerceCredentials",
            kSecReturnData as String: true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else { return nil }
        guard let data = item as? Data else { return nil }

        return try? JSONDecoder().decode(WooCommerceCredentials.self, from: data)
    }

    static func deleteCredentials() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "WooCommerceCredentials"
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil) }
    }
}
