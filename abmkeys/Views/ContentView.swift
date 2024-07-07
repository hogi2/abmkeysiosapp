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
    @State private var isLoading = true
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        Group {
            if isLoading {
                LoadingView()
                    .onAppear {
                        Task {
                            await checkLoginAndFetchData()
                        }
                    }
            } else {
                TabView {
                    HomeView(orders: $orders, latestProducts: $latestProducts)
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
                .onAppear {
                    Task {
                        await checkForCompletedOrders()
                    }
                }
            }
        }
        .alert(isPresented: $showError) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }

    @MainActor
    private func checkLoginAndFetchData() async {
        if let credentials = KeychainHelper.getCredentials() {
            WooCommerceService.credentials = credentials
            await fetchData()
        } else {
            if let window = UIApplication.shared.windows.first {
                window.rootViewController = UIHostingController(rootView: LoginView())
                window.makeKeyAndVisible()
            }
        }
    }

    @MainActor
    private func fetchData() async {
        isLoading = true
        do {
            async let fetchedOrders = WooCommerceService().getOrders(page: 1, search: "")
            async let fetchedProducts = WooCommerceService().getProducts(page: 1, search: "")

            orders = try await fetchedOrders
            latestProducts = try await fetchedProducts
        } catch {
            showError = true
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    @MainActor
    private func checkForCompletedOrders() async {
        do {
            let previousOrders = orders
            try await WooCommerceService().checkForCompletedOrders(previousOrders: previousOrders)
        } catch {
            showError = true
            errorMessage = error.localizedDescription
        }
    }
}
