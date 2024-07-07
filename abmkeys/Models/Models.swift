//
//  Models.swift
//  abmkeys
//
//  Created by Hogan Alkahlan on 7/3/24.
//

import Foundation

struct ProductDetail: Codable, Equatable {
    let id: Int
    let name: String
    let price: String
    let description: String
    let categories: [Category]
    let imageUrl: [ImageUrl]?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case price
        case description
        case categories
        case imageUrl = "images"
    }

    static func == (lhs: ProductDetail, rhs: ProductDetail) -> Bool {
        return lhs.id == rhs.id
    }
}

struct Category: Codable, Equatable {
    let id: Int
    let name: String

    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.id == rhs.id
    }
}

struct ImageUrl: Codable, Equatable {
    let src: String

    static func == (lhs: ImageUrl, rhs: ImageUrl) -> Bool {
        return lhs.src == rhs.src
    }
}

struct Order: Decodable, Equatable {
    let id: Int
    let status: String
    let total: String

    static func == (lhs: Order, rhs: Order) -> Bool {
        return lhs.id == rhs.id
    }
}

struct Product: Decodable, Equatable {
    let id: Int
    let name: String
    let price: String

    static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs.id == rhs.id
    }
}

struct SalesReport: Decodable {
    let totalSales: String
}

struct OrderDetails: Decodable {
    let id: Int
    let status: String
    let total: String
    let items: [OrderItem]
    let customerName: String
    let email: String
    let phone: String
    let orderNotes: String?

    enum CodingKeys: String, CodingKey {
        case id
        case status
        case total
        case items = "line_items"
        case billing
        case orderNotes = "customer_note"
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

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        status = try container.decode(String.self, forKey: .status)
        total = try container.decode(String.self, forKey: .total)
        items = try container.decode([OrderItem].self, forKey: .items)
        orderNotes = try container.decodeIfPresent(String.self, forKey: .orderNotes) ?? ""

        let billing = try container.nestedContainer(keyedBy: BillingKeys.self, forKey: .billing)
        customerName = "\(try billing.decode(String.self, forKey: .firstName)) \(try billing.decode(String.self, forKey: .lastName))"
        email = try billing.decode(String.self, forKey: .email)
        phone = try billing.decode(String.self, forKey: .phone)
    }
}
