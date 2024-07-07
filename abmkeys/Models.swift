//
//  Models.swift
//  abmkeys
//
//  Created by Hogan Alkahlan on 7/1/24.
//

import Foundation

struct Order: Decodable, Equatable {
    let id: Int
    let status: String
    let total: String?

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
    let total_sales: String
}

struct OrderDetails: Decodable {
    let id: Int
    let status: String
    let total: String
    let items: [OrderItem]
    let customerName: String
    let email: String
    let phone: String
    let orderNotes: String

    enum CodingKeys: String, CodingKey {
        case id
        case status
        case total
        case items = "line_items"
        case billing
        case orderNotes = "customer_note"
    }

    enum BillingKeys: String, CodingKey {
        case first_name
        case last_name
        case email
        case phone
    }

    struct OrderItem: Decodable {
        let id: Int
        let name: String
        let quantity: Int
        let total: String
    }

    struct Billing: Decodable {
        let first_name: String
        let last_name: String
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
        customerName = "\(try billing.decode(String.self, forKey: .first_name)) \(try billing.decode(String.self, forKey: .last_name))"
        email = try billing.decode(String.self, forKey: .email)
        phone = try billing.decode(String.self, forKey: .phone)
    }
}

struct ProductDetail: Decodable, Equatable {
    let id: Int
    let name: String
    let imageUrl: String
    let categoryStatus: String
    let type: String
    let totalSales: String
    let averageRating: String
    let regularPrice: String
    let salePrice: String
    let stockStatus: String
    let stockQuantity: String
    let category: String
    let description: String

    static func == (lhs: ProductDetail, rhs: ProductDetail) -> Bool {
        return lhs.id == rhs.id
    }
}
