//
//  WooCommerceService.swift
//  abmkeys
//
//  Created by Hogan Alkahlan on 6/30/24.
//
import Foundation

class WooCommerceService {
    let baseUrl = "https://www.abmkeys.com/wp-json/wc/v3"
    let consumerKey = "ck_18453c71673b00be9945eff41029bf123128766a"
    let consumerSecret = "cs_65f96799de7dd4bdb3b6fcaabc27d44d78b4251f"

    func getOrders(page: Int, search: String, completion: @escaping ([Order]?) -> Void) {
        guard let url = URL(string: "\(baseUrl)/orders?consumer_key=\(consumerKey)&consumer_secret=\(consumerSecret)&page=\(page)&search=\(search)") else {
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching orders: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            let orders = try? JSONDecoder().decode([Order].self, from: data)
            completion(orders)
        }
        task.resume()
    }

    func getProducts(page: Int, search: String, completion: @escaping ([Product]?) -> Void) {
        guard let url = URL(string: "\(baseUrl)/products?consumer_key=\(consumerKey)&consumer_secret=\(consumerSecret)&page=\(page)&search=\(search)") else {
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching products: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            let products = try? JSONDecoder().decode([Product].self, from: data)
            completion(products)
        }
        task.resume()
    }

    func getProductDetails(productId: Int, completion: @escaping (ProductDetail?) -> Void) {
        guard let url = URL(string: "\(baseUrl)/products/\(productId)?consumer_key=\(consumerKey)&consumer_secret=\(consumerSecret)") else {
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching product details: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print("JSON Response: \(json)")
                let details = try JSONDecoder().decode(ProductDetail.self, from: data)
                completion(details)
            } catch {
                print("Error decoding product details: \(error.localizedDescription)")
                completion(nil)
            }
        }
        task.resume()
    }

    func getOrderDetails(orderId: Int, completion: @escaping (OrderDetails?) -> Void) {
        guard let url = URL(string: "\(baseUrl)/orders/\(orderId)?consumer_key=\(consumerKey)&consumer_secret=\(consumerSecret)") else {
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching order details: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print("JSON Response: \(json)")
                let details = try JSONDecoder().decode(OrderDetails.self, from: data)
                completion(details)
            } catch {
                print("Error decoding order details: \(error.localizedDescription)")
                completion(nil)
            }
        }
        task.resume()
    }

    func getDailySales(completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "\(baseUrl)/reports/sales?consumer_key=\(consumerKey)&consumer_secret=\(consumerSecret)&period=day") else {
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching sales data: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            if let salesReport = try? JSONDecoder().decode([SalesReport].self, from: data).first {
                completion(salesReport.totalSales)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }

    func checkForCompletedOrders(previousOrders: [Order]) {
        getOrders(page: 1, search: "") { fetchedOrders in
            guard let fetchedOrders = fetchedOrders else { return }
            let completedOrders = fetchedOrders.filter { $0.status == "completed" }
            let previousCompletedOrders = previousOrders.filter { $0.status == "completed" }
            let newCompletedOrders = completedOrders.filter { !previousCompletedOrders.contains($0) }
            for order in newCompletedOrders {
                NotificationManager.shared.scheduleOrderCompletionNotification(orderId: order.id, orderTotal: order.total)
            }
        }
    }
}
