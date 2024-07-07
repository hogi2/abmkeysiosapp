//
//  ContentView.swift
//  abmkeys
//
//  Created by Hogan Alkahlan on 6/30/24.
//
import SwiftUI

struct ContentView: View {
    @State private var orders: [Order] = []
    @State private var latestProducts: [Product] = []
    @State private var dailySales: String = "No data"
    @State private var isLoading = true

    var body: some View {
        if isLoading {
            LoadingView()
                .onAppear {
                    fetchData()
                }
        } else {
            TabView {
                HomeView(orders: $orders, latestProducts: $latestProducts, dailySales: $dailySales)
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }

                OrderListView(orders: $orders)
                    .tabItem {
                        Label("Orders", systemImage: "list.bullet")
                    }

                ProductView(products: $latestProducts)
                    .tabItem {
                        Label("Products", systemImage: "cart")
                    }

                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
        }
    }

    private func fetchData() {
        let dispatchGroup = DispatchGroup()

        dispatchGroup.enter()
        WooCommerceService().getOrders(page: 1, search: "") { fetchedOrders in
            if let fetchedOrders = fetchedOrders {
                DispatchQueue.main.async {
                    self.orders = fetchedOrders
                }
            }
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        WooCommerceService().getProducts(page: 1, search: "") { fetchedProducts in
            if let fetchedProducts = fetchedProducts {
                DispatchQueue.main.async {
                    self.latestProducts = fetchedProducts
                }
            }
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        WooCommerceService().getDailySales { sales in
            DispatchQueue.main.async {
                self.dailySales = sales ?? "No data"
            }
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) {
            self.isLoading = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
