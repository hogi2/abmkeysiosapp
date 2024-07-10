//
//  Models.swift
//  abmkeys
//
//  Created by Hogan Alkahlan on 7/3/24.
//

import Foundation

// Represents detailed information about a product
struct ProductDetail: Codable, Equatable {
    let id: Int
    let name: String
    let price: String
    let description: String
    let categories: [Category]
    let imageUrl: [ImageUrl]?

    enum CodingKeys: String, CodingKey {
        case id, name, price, description, categories
        case imageUrl = "images"
    }
}

// Represents a product category
struct Category: Codable, Equatable {
    let id: Int
    let name: String
}

// Represents an image URL
struct ImageUrl: Codable, Equatable {
    let src: String
}

// Represents an order
struct Order: Decodable, Equatable {
    let id: Int
    let status: String
    let total: String
}

// Represents a product
struct Product: Decodable, Equatable {
    let id: Int
    let name: String
    let price: String
}

// Represents a sales report
struct SalesReport: Decodable {
    let totalSales: String
}

// Represents detailed information about an order

struct OrderDetails: Decodable {
    let id: Int
    let status: String
    let total: String
    let items: [OrderItem]
    let customerName: String
    let email: String
    let phone: String
    var orderNotes: [OrderNote] // Changed from let to var

    enum CodingKeys: String, CodingKey {
        case id
        case status
        case total
        case items = "line_items"
        case billing
        case orderNotes = "order_notes" // Ensure this matches the actual key in your JSON response
    }

    enum BillingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case phone
    }

    struct OrderItem: Decodable, Identifiable {
        let id: Int
        let name: String
        let quantity: Int
        let total: String
    }

    struct Billing: Decodable {
        let firstName: String
        let lastName: String
        let email: String
        let phone: String
    }

    struct OrderNote: Decodable, Identifiable {
        let id: Int
        let note: String

        enum CodingKeys: String, CodingKey {
            case id
            case note
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        status = try container.decode(String.self, forKey: .status)
        total = try container.decode(String.self, forKey: .total)
        items = try container.decode([OrderItem].self, forKey: .items)
        orderNotes = try container.decodeIfPresent([OrderNote].self, forKey: .orderNotes) ?? []

        let billing = try container.nestedContainer(keyedBy: BillingKeys.self, forKey: .billing)
        let firstName = try billing.decode(String.self, forKey: .firstName)
        let lastName = try billing.decode(String.self, forKey: .lastName)
        customerName = "\(firstName) \(lastName)"
        email = try billing.decode(String.self, forKey: .email)
        phone = try billing.decode(String.self, forKey: .phone)
    }
}

