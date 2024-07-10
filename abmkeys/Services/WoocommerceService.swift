//
//  WooCommerceService.swift
//  abmkeys
//
//  Created by Hogan Alkahlan on 6/30/24.
//

import Foundation

class WooCommerceService {
    static var credentials: WooCommerceCredentials?
    private let baseUrl = "https://www.abmkeys.com/wp-json/wc/v3"
    
    private enum Endpoint: String {
        case orders = "orders"
        case products = "products"
        case notes = "notes"
    }
    
    private func makeURL(endpoint: Endpoint, parameters: [String: String] = [:], id: Int? = nil) -> URL? {
        guard let credentials = WooCommerceService.credentials else { return nil }
        
        var urlString = "\(baseUrl)/\(endpoint.rawValue)"
        if let id = id {
            urlString += "/\(id)"
        }
        var urlComponents = URLComponents(string: urlString)
        var queryItems = [
            URLQueryItem(name: "consumer_key", value: credentials.consumerKey),
            URLQueryItem(name: "consumer_secret", value: credentials.consumerSecret)
        ]
        
        parameters.forEach { queryItems.append(URLQueryItem(name: $0.key, value: $0.value)) }
        urlComponents?.queryItems = queryItems
        
        let finalURL = urlComponents?.url?.absoluteString ?? "Invalid URL"
        print("API URL: \(finalURL)") // Add this line
        
        return urlComponents?.url
    }
    
    private func logResponse(_ data: Data?, _ response: URLResponse?, _ error: Error?) {
        if let error = error {
            print("Error: \(error.localizedDescription)")
        }
        if let httpResponse = response as? HTTPURLResponse {
            print("HTTP Status Code: \(httpResponse.statusCode)")
        }
        if let data = data, let jsonString = String(data: data, encoding: .utf8) {
            print("Response data: \(jsonString)")
        }
    }
    
    private func fetchData<T: Decodable>(from url: URL) async throws -> T {
        let (data, response) = try await URLSession.shared.data(from: url)
        logResponse(data, response, nil)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw URLError(.badServerResponse)
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("Failed to decode JSON: \(error.localizedDescription)")
            logResponse(data, response, error)
            throw error
        }
    }
    
    func getOrders(page: Int, search: String, status: String? = nil) async throws -> [Order] {
        var parameters: [String: String] = ["page": "\(page)", "search": search]
        if let status = status {
            parameters["status"] = status
        }
        
        guard let url = makeURL(endpoint: .orders, parameters: parameters) else {
            throw URLError(.badURL)
        }
        
        return try await fetchData(from: url)
    }
    
    func getProducts(page: Int, search: String) async throws -> [Product] {
        guard let url = makeURL(endpoint: .products, parameters: ["page": "\(page)", "search": search]) else {
            throw URLError(.badURL)
        }
        
        return try await fetchData(from: url)
    }
    
    func getProductDetails(productId: Int) async throws -> ProductDetail {
        guard let url = makeURL(endpoint: .products, id: productId) else {
            throw URLError(.badURL)
        }
        
        return try await fetchData(from: url)
    }
    
    func getOrderDetails(orderId: Int) async throws -> OrderDetails {
        guard let url = makeURL(endpoint: .orders, id: orderId) else {
            throw URLError(.badURL)
        }
        
        var orderDetails: OrderDetails = try await fetchData(from: url)
        
        // Fetch order notes
        if let notesURL = makeURL(endpoint: .orders, id: orderId)?.appendingPathComponent("notes") {
            let orderNotes: [OrderDetails.OrderNote] = try await fetchData(from: notesURL)
            orderDetails.orderNotes = orderNotes
        }
        
        return orderDetails
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
    
    func updateOrderStatus(orderId: Int, newStatus: String) async throws {
        guard let credentials = WooCommerceService.credentials else { return }
        guard let url = makeURL(endpoint: .orders, id: orderId) else { throw URLError(.badURL) }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["status": newStatus]
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        let (data, response) = try await URLSession.shared.data(for: request)
        logResponse(data, response, nil)

        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw URLError(.badServerResponse)
        }

        do {
            let updatedOrder = try JSONDecoder().decode(OrderDetails.self, from: data)
            print("Order status updated to: \(updatedOrder.status)")
        } catch {
            print("Failed to decode JSON: \(error.localizedDescription)")
            logResponse(data, response, error)
            throw error
        }
    }

}
