//
//  WooCommerceService.swift
//  abmkeys
//
//  Created by Hogan Alkahlan on 6/30/24.
//

import Foundation

class WooCommerceService {
    static var credentials: WooCommerceCredentials?

    let baseUrl = "https://www.abmkeys.com/wp-json/wc/v3"

    private func makeURL(endpoint: String, parameters: [String: String]) -> URL? {
        guard let credentials = WooCommerceService.credentials else { return nil }

        var urlComponents = URLComponents(string: "\(baseUrl)/\(endpoint)")
        var queryItems = [
            URLQueryItem(name: "consumer_key", value: credentials.consumerKey),
            URLQueryItem(name: "consumer_secret", value: credentials.consumerSecret)
        ]

        for (key, value) in parameters {
            queryItems.append(URLQueryItem(name: key, value: value))
        }

        urlComponents?.queryItems = queryItems
        #if DEBUG
        print("API URL: \(urlComponents?.url?.absoluteString ?? "Invalid URL")")
        #endif
        return urlComponents?.url
    }

    private func logResponse(_ data: Data?, _ response: URLResponse?, _ error: Error?) {
        #if DEBUG
        if let error = error {
            print("Error: \(error.localizedDescription)")
        }
        if let httpResponse = response as? HTTPURLResponse {
            print("HTTP Status Code: \(httpResponse.statusCode)")
        }
        if let data = data, let jsonString = String(data: data, encoding: .utf8) {
            print("Response data: \(jsonString)")
        }
        #endif
    }

    func getOrders(page: Int, search: String, status: String? = nil) async throws -> [Order] {
        var parameters: [String: String] = ["page": "\(page)", "search": search]
        if let status = status {
            parameters["status"] = status
        }

        guard let url = makeURL(endpoint: "orders", parameters: parameters) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        logResponse(data, response, nil)

        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw URLError(.badServerResponse)
        }

        do {
            let orders = try JSONDecoder().decode([Order].self, from: data)
            return orders
        } catch {
            print("Failed to decode JSON for orders: \(error.localizedDescription)")
            logResponse(data, response, error)
            throw error
        }
    }

    func getProducts(page: Int, search: String) async throws -> [Product] {
        guard let url = makeURL(endpoint: "products", parameters: ["page": "\(page)", "search": search]) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        logResponse(data, response, nil)

        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw URLError(.badServerResponse)
        }

        do {
            let products = try JSONDecoder().decode([Product].self, from: data)
            return products
        } catch {
            print("Failed to decode JSON for products: \(error.localizedDescription)")
            logResponse(data, response, error)
            throw error
        }
    }

    func getProductDetails(productId: Int) async throws -> ProductDetail {
        guard let url = makeURL(endpoint: "products/\(productId)", parameters: [:]) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        logResponse(data, response, nil)

        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw URLError(.badServerResponse)
        }

        do {
            let productDetail = try JSONDecoder().decode(ProductDetail.self, from: data)
            return productDetail
        } catch {
            print("Failed to decode JSON for product details: \(error.localizedDescription)")
            logResponse(data, response, error)
            throw error
        }
    }

    func getOrderDetails(orderId: Int) async throws -> OrderDetails {
        guard let url = makeURL(endpoint: "orders/\(orderId)", parameters: [:]) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        logResponse(data, response, nil)

        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw URLError(.badServerResponse)
        }

        do {
            let orderDetails = try JSONDecoder().decode(OrderDetails.self, from: data)
            return orderDetails
        } catch {
            print("Failed to decode JSON for order details: \(error.localizedDescription)")
            logResponse(data, response, error)
            throw error
        }
    }

    func checkForCompletedOrders(previousOrders: [Order]) async throws {
        do {
            let fetchedOrders = try await getOrders(page: 1, search: "")
            let completedOrders = fetchedOrders.filter { $0.status == "completed" }
            let previousCompletedOrders = previousOrders.filter { $0.status == "completed" }
            let newCompletedOrders = completedOrders.filter { !previousCompletedOrders.contains($0) }

            for order in newCompletedOrders {
                NotificationManager.shared.scheduleOrderCompletionNotification(orderId: order.id, orderTotal: order.total)
            }
        } catch {
            print("Error checking for completed orders: \(error)")
        }
    }
}

